//
//  FCModel.m
//
//  Created by Marco Arment on 7/18/13.
//  Copyright (c) 2013 Marco Arment. All rights reserved.
//

#import <objc/runtime.h>
#import <string.h>
#import "FCModel.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import <sqlite3.h>

NSString * const FCModelInsertNotification = @"FCModelInsertNotification";
NSString * const FCModelUpdateNotification = @"FCModelUpdateNotification";
NSString * const FCModelDeleteNotification = @"FCModelDeleteNotification";
NSString * const FCModelInstanceKey = @"FCModelInstanceKey";

static NSString * const FCModelReloadNotification = @"FCModelReloadNotification";
static NSString * const FCModelSaveNotification   = @"FCModelSaveNotification";
static NSString * const FCModelClassKey           = @"class";

static FMDatabaseQueue *g_databaseQueue = NULL;
static NSDictionary *g_fieldInfo = NULL;
static NSDictionary *g_primaryKeyFieldName = NULL;
static NSMutableDictionary *g_instances = NULL;
static dispatch_semaphore_t g_instancesReadLock;

@interface FMDatabase (HackForVAListsSinceThisIsPrivate)
- (FMResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;
- (BOOL)executeUpdate:(NSString*)sql error:(NSError**)outErr withArgumentsInArray:(NSArray*)arrayArgs orDictionary:(NSDictionary *)dictionaryArgs orVAList:(va_list)args;
@end


// FCFieldInfo is used for NULL/NOT NULL rules and default values
typedef NS_ENUM(NSInteger, FCFieldType) {
    FCFieldTypeOther = 0,
    FCFieldTypeText,
    FCFieldTypeInteger,
    FCFieldTypeDouble,
    FCFieldTypeBool
};

@interface FCFieldInfo : NSObject
@property (nonatomic, assign) BOOL nullAllowed;
@property (nonatomic, assign) FCFieldType type;
@property (nonatomic) id defaultValue;
@end
@implementation FCFieldInfo
- (NSString *)description
{
    return [NSString stringWithFormat:@"<FCFieldInfo {%@ %@, default=%@}>",
        (_type == FCFieldTypeText ? @"text" : (_type == FCFieldTypeInteger ? @"integer" : (_type == FCFieldTypeDouble ? @"double" : (_type == FCFieldTypeBool ? @"bool" : @"other")))),
        _nullAllowed ? @"NULL" : @"NOT NULL",
        _defaultValue ? _defaultValue : @"NULL"
    ];
}
@end


@interface FCModel () {
    BOOL existsInDatabase;
    BOOL primaryKeySet;
    BOOL deleted;
    BOOL primaryKeyLocked;
}
@property (nonatomic, strong) NSDictionary<Ignore> *databaseFieldNames;
@property (nonatomic, strong) NSMutableDictionary<Ignore> *changedProperties;
@property (nonatomic, copy) NSError<Ignore> *_lastSQLiteError;
@end


@implementation FCModel

- (NSError *)lastSQLiteError { return self._lastSQLiteError; }

#pragma mark - For subclasses to override

- (BOOL)shouldInsert { return YES; }
- (BOOL)shouldUpdate { return YES; }
- (BOOL)shouldDelete { return YES; }
- (void)didInsert { }
- (void)didUpdate { }
- (void)didDelete { }

#pragma mark - Instance tracking and uniquing

+ (void)uniqueMapInit
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        g_instancesReadLock = dispatch_semaphore_create(1);
        g_instances = [NSMutableDictionary dictionary];
    });
}

+ (instancetype)instanceWithPrimaryKey:(id)primaryKeyValue { return [self instanceWithPrimaryKey:primaryKeyValue databaseRowValues:nil createIfNonexistent:YES]; }
+ (instancetype)instanceWithPrimaryKey:(id)primaryKeyValue createIfNonexistent:(BOOL)create { return [self instanceWithPrimaryKey:primaryKeyValue databaseRowValues:nil createIfNonexistent:create]; }

+ (instancetype)instanceWithPrimaryKey:(id)primaryKeyValue databaseRowValues:(NSDictionary *)fieldValues createIfNonexistent:(BOOL)create
{
    if (! primaryKeyValue || primaryKeyValue == [NSNull null]) return [self new];
    [self uniqueMapInit];
    
    FCModel *instance = NULL;
    dispatch_semaphore_wait(g_instancesReadLock, DISPATCH_TIME_FOREVER);
    NSMapTable *classCache = g_instances[self];
    if (! classCache) classCache = g_instances[(id) self] = [NSMapTable strongToWeakObjectsMapTable];
    instance = [classCache objectForKey:primaryKeyValue];
    dispatch_semaphore_signal(g_instancesReadLock);
    
    if (! instance) {
        // Not in memory yet. Check DB.
        instance = fieldValues ? [[self alloc] initWithFieldValues:fieldValues existsInDatabaseAlready:YES] : [self instanceFromDatabaseWithPrimaryKey:primaryKeyValue];
        if (! instance && create) {
            // Create new with this key.
            instance = [[self alloc] initWithFieldValues:@{ g_primaryKeyFieldName[self] : primaryKeyValue } existsInDatabaseAlready:NO];
        }
        
        if (instance) {
            dispatch_semaphore_wait(g_instancesReadLock, DISPATCH_TIME_FOREVER);
            FCModel *racedInstance = [classCache objectForKey:primaryKeyValue];
            if (racedInstance) {
                instance = racedInstance;
            } else {
                [classCache setObject:instance forKey:primaryKeyValue];
            }
            dispatch_semaphore_signal(g_instancesReadLock);
        }
    }

    return instance;
}

- (void)registerUniqueInstance
{
    id primaryKeyValue = self.primaryKey;
    if (! primaryKeyValue || primaryKeyValue == [NSNull null]) return;
    [self.class uniqueMapInit];

    dispatch_semaphore_wait(g_instancesReadLock, DISPATCH_TIME_FOREVER);
    NSMapTable *classCache = g_instances[self.class];
    if (! classCache) classCache = g_instances[(id) self.class] = [NSMapTable strongToWeakObjectsMapTable];
    [classCache setObject:self forKey:primaryKeyValue];
    dispatch_semaphore_signal(g_instancesReadLock);
}

- (void)removeUniqueInstance
{
    id primaryKeyValue = self.primaryKey;
    if (! primaryKeyValue || primaryKeyValue == [NSNull null]) return;
    [self.class uniqueMapInit];
    
    dispatch_semaphore_wait(g_instancesReadLock, DISPATCH_TIME_FOREVER);
    NSMapTable *classCache = g_instances[self.class];
    [classCache removeObjectForKey:primaryKeyValue];
    dispatch_semaphore_signal(g_instancesReadLock);
}

+ (instancetype)instanceFromDatabaseWithPrimaryKey:(id)key
{
    __block FCModel *model = NULL;
    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:[self expandQuery:@"SELECT * FROM \"$T\" WHERE \"$PK\"=?"], key];
        if (! s) [self queryFailedInDatabase:db];
        if ([s next]) model = [[self alloc] initWithFieldValues:s.resultDictionary existsInDatabaseAlready:YES];
        [s close];
    }];
    
    return model;
}

+ (void)dataWasUpdatedExternally
{
    [NSNotificationCenter.defaultCenter postNotificationName:FCModelReloadNotification object:nil userInfo:@{ FCModelClassKey : self }];
}

#pragma mark - Mapping properties to database fields

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:g_primaryKeyFieldName[self.class]]) primaryKeySet = YES;
    if (! primaryKeyLocked) return;
    NSObject *oldValue, *newValue;

    if ( (oldValue = change[NSKeyValueChangeOldKey]) && (newValue = change[NSKeyValueChangeNewKey]) ) {
        if ([oldValue isKindOfClass:[NSURL class]]) oldValue = ((NSURL *)oldValue).absoluteString;
        else if ([oldValue isKindOfClass:[NSDate class]]) oldValue = [NSNumber numberWithInteger:[(NSDate *)oldValue timeIntervalSince1970]];

        if ([newValue isKindOfClass:[NSURL class]]) newValue = ((NSURL *)newValue).absoluteString;
        else if ([newValue isKindOfClass:[NSDate class]]) newValue = [NSNumber numberWithInteger:[(NSDate *)newValue timeIntervalSince1970]];

        if ([oldValue isEqual:newValue]) return;
    }
    
    BOOL isPrimaryKey = [keyPath isEqualToString:[self.class primaryKeyFieldName]];
    if (existsInDatabase && isPrimaryKey) {
        if (primaryKeyLocked) [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot change primary key value for already-saved FCModel" userInfo:nil] raise];
    } else if (isPrimaryKey) {
        primaryKeySet = YES;
    }

    if (! isPrimaryKey && self.changedProperties && ! self.changedProperties[keyPath]) [self.changedProperties setObject:(oldValue ?: [NSNull null]) forKey:keyPath];
}

- (id)encodedValueForFieldName:(NSString *)fieldName
{
    id value = [self valueForKey:fieldName];
    if (! value) return [NSNull null];
    
    if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:NSDictionary.class]) {
        NSError *error = nil;
        NSData *bplist = [NSPropertyListSerialization dataWithPropertyList:value format:NSPropertyListBinaryFormat_v1_0 options:NSPropertyListImmutable error:&error];
        if (error) {
            [[NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:
                @"Cannot serialize %@ to plist for %@.%@: %@", NSStringFromClass(((NSObject *)value).class), NSStringFromClass(self.class), fieldName, error.localizedDescription
            ] userInfo:nil] raise];
        }
        return bplist;
    } else if ([value isKindOfClass:NSURL.class]) {
        return [(NSURL *)value absoluteString];
    } else if ([value isKindOfClass:NSDate.class]) {
        return [NSNumber numberWithInteger:[(NSDate *)value timeIntervalSince1970]];
    } else {
        return value;
    }
}

- (void)decodeFieldValue:(id)value intoPropertyName:(NSString *)propertyName
{
    if (value == [NSNull null]) value = nil;

    objc_property_t property = class_getProperty(self.class, [propertyName UTF8String]);
    if (property) {
        const char *attrs = property_getAttributes(property);
        if (attrs[0] == 'T' && attrs[1] == '@' && attrs[2] == '"') attrs = &(attrs[3]);

        if (value && strncmp(attrs, "NSURL", 5) == 0) {
            value = [NSURL URLWithString:value];
            if (! value) [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid URL" userInfo:nil] raise];
        } else if (value && strncmp(attrs, "NSDate", 6) == 0) {
            value = [NSDate dateWithTimeIntervalSince1970:[value integerValue]];
        } else if (value && strncmp(attrs, "NSDecimalNumber", 15) == 0) {
            value = [NSDecimalNumber decimalNumberWithString:[value stringValue]];
        } else if (value && strncmp(attrs, "NSDictionary", 12) == 0) {
            value = [NSPropertyListSerialization propertyListWithData:value options:kCFPropertyListImmutable format:NULL error:NULL];
            if (! value || ! [value isKindOfClass:NSDictionary.class]) value = @{};
        } else if (value && strncmp(attrs, "NSArray", 7) == 0) {
            value = [NSPropertyListSerialization propertyListWithData:value options:kCFPropertyListImmutable format:NULL error:NULL];
            if (! value || ! [value isKindOfClass:NSArray.class]) value = @[];
        }

        [self setValue:value forKeyPath:propertyName];
    }
}

+ (NSArray *)databaseFieldNames     { return [g_fieldInfo[self] allKeys]; }
+ (NSString *)primaryKeyFieldName { return g_primaryKeyFieldName[self]; }

#pragma mark - Find methods

+ (NSError *)executeUpdateQuery:(NSString *)query, ...
{
    va_list args;
    va_list *foolTheStaticAnalyzer = &args;
    va_start(args, query);

    __block BOOL success = NO;
    __block NSError *error = nil;
    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:[self expandQuery:query] error:nil withArgumentsInArray:nil orDictionary:nil orVAList:*foolTheStaticAnalyzer];
        if (! success) error = [db.lastError copy];
    }];

    va_end(args);
    if (success) [self dataWasUpdatedExternally];
    return error;
}

+ (id)_instancesWhere:(NSString *)query andArgs:(va_list)args orArgsArray:(NSArray *)argsArray orResultSet:(FMResultSet *)existingResultSet onlyFirst:(BOOL)onlyFirst keyed:(BOOL)keyed
{
    NSMutableArray *instances;
    NSMutableDictionary *keyedInstances;
    __block FCModel *instance = nil;
    
    if (! onlyFirst) {
        if (keyed) keyedInstances = [NSMutableDictionary dictionary];
        else instances = [NSMutableArray array];
    }
    
    void (^processResult)(FMResultSet *, BOOL *) = ^(FMResultSet *s, BOOL *stop){
        NSDictionary *rowDictionary = s.resultDictionary;
        instance = [self instanceWithPrimaryKey:rowDictionary[g_primaryKeyFieldName[self]] databaseRowValues:rowDictionary createIfNonexistent:NO];
        if (onlyFirst) {
            *stop = YES;
            return;
        }
        if (keyed) [keyedInstances setValue:instance forKey:[instance primaryKey]];
        else [instances addObject:instance];
    };
    
    if (existingResultSet) {
        BOOL stop = NO;
        while (! stop && [existingResultSet next]) processResult(existingResultSet, &stop);
    } else {
        [g_databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *s = [db
                executeQuery:(
                    query ?
                    [self expandQuery:[@"SELECT * FROM \"$T\" WHERE " stringByAppendingString:query]] :
                    [self expandQuery:@"SELECT * FROM \"$T\""]
                )
                withArgumentsInArray:argsArray
                orDictionary:nil
                orVAList:args
            ];
            if (! s) [self queryFailedInDatabase:db];
            BOOL stop = NO;
            while (! stop && [s next]) processResult(s, &stop);
            [s close];
        }];
    }
    
    return onlyFirst ? instance : (keyed ? keyedInstances : instances);
}

+ (NSArray *)instancesFromResultSet:(FMResultSet *)rs { return [self _instancesWhere:nil andArgs:NULL orArgsArray:nil orResultSet:rs onlyFirst:NO keyed:NO]; }
+ (NSDictionary *)keyedInstancesFromResultSet:(FMResultSet *)rs { return [self _instancesWhere:nil andArgs:NULL orArgsArray:nil orResultSet:rs onlyFirst:NO keyed:YES]; }
+ (instancetype)firstInstanceFromResultSet:(FMResultSet *)rs { return [self _instancesWhere:nil andArgs:NULL orArgsArray:nil orResultSet:rs onlyFirst:YES keyed:NO]; }

+ (instancetype)firstInstanceWhere:(NSString *)query, ...
{
    va_list args;
    va_start(args, query);
    id result = [self _instancesWhere:query andArgs:args orArgsArray:nil orResultSet:nil onlyFirst:YES keyed:NO];
    va_end(args);
    return result;
}

+ (NSArray *)instancesWhere:(NSString *)query, ...
{
    va_list args;
    va_start(args, query);
    NSArray *results = [self _instancesWhere:query andArgs:args orArgsArray:nil orResultSet:nil onlyFirst:NO keyed:NO];
    va_end(args);
    return results;
}

+ (NSDictionary *)keyedInstancesWhere:(NSString *)query, ...
{
    va_list args;
    va_start(args, query);
    NSDictionary *results = [self _instancesWhere:query andArgs:args orArgsArray:nil orResultSet:nil onlyFirst:NO keyed:NO];
    va_end(args);
    return results;
}

+ (NSArray *)allInstances { return [self _instancesWhere:nil andArgs:NULL orArgsArray:nil orResultSet:nil onlyFirst:NO keyed:NO]; }
+ (NSDictionary *)keyedAllInstances { return [self _instancesWhere:nil andArgs:NULL orArgsArray:nil orResultSet:nil onlyFirst:NO keyed:YES]; }

+ (NSArray *)instancesWithPrimaryKeyValues:(NSArray *)primaryKeyValues
{
    if (primaryKeyValues.count == 0) return @[];
    
    __block int maxParameterCount = 0;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        maxParameterCount = sqlite3_limit(db.sqliteHandle, SQLITE_LIMIT_VARIABLE_NUMBER, -1);
    }];

    __block NSArray *allFoundInstances = nil;
    NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:MIN(primaryKeyValues.count, maxParameterCount)];
    NSMutableString *whereClause = [NSMutableString stringWithFormat:@"%@ IN (", g_primaryKeyFieldName[self]];
    
    void (^fetchChunk)() = ^{
        if (valuesArray.count == 0) return;
        [whereClause appendString:@")"];
        NSArray *newInstancesThisChunk = [self _instancesWhere:whereClause andArgs:NULL orArgsArray:valuesArray orResultSet:nil onlyFirst:NO keyed:NO];
        allFoundInstances = allFoundInstances ? [allFoundInstances arrayByAddingObjectsFromArray:newInstancesThisChunk] : newInstancesThisChunk;
        
        // reset state for next chunk
        [whereClause deleteCharactersInRange:NSMakeRange(7, whereClause.length - 7)];
        [valuesArray removeAllObjects];
    };
    
    for (id pkValue in primaryKeyValues) {
        [whereClause appendString:(valuesArray.count ? @",?" : @"?")];
        [valuesArray addObject:pkValue];
        if (valuesArray.count == maxParameterCount) fetchChunk();
    }
    fetchChunk();
    
    return allFoundInstances;
}

+ (NSDictionary *)keyedInstancesWithPrimaryKeyValues:(NSArray *)primaryKeyValues
{
    NSArray *instances = [self instancesWithPrimaryKeyValues:primaryKeyValues];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:instances.count];
    for (FCModel *instance in instances) [dictionary setObject:instance forKey:instance.primaryKey];
    return dictionary;
}

+ (NSArray *)firstColumnArrayFromQuery:(NSString *)query, ...
{
    NSMutableArray *columnArray = [NSMutableArray array];
    va_list args;
    va_list *foolTheStaticAnalyzer = &args;
    va_start(args, query);
    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:[self expandQuery:query] withArgumentsInArray:nil orDictionary:nil orVAList:*foolTheStaticAnalyzer];
        if (! s) [self queryFailedInDatabase:db];
        while ([s next]) [columnArray addObject:[s objectForColumnIndex:0]];
        [s close];
    }];
    va_end(args);
    return columnArray;
}

+ (NSArray *)resultDictionariesFromQuery:(NSString *)query, ...
{
    NSMutableArray *rows = [NSMutableArray array];
    va_list args;
    va_list *foolTheStaticAnalyzer = &args;
    va_start(args, query);
        [g_databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *s = [db executeQuery:[self expandQuery:query] withArgumentsInArray:nil orDictionary:nil orVAList:*foolTheStaticAnalyzer];
            if (! s) [self queryFailedInDatabase:db];
            while ([s next]) [rows addObject:s.resultDictionary];
            [s close];
        }];
    va_end(args);
    return rows;
}

+ (id)firstValueFromQuery:(NSString *)query, ...
{
    __block id firstValue = nil;
    va_list args;
    va_list *foolTheStaticAnalyzer = &args;
    va_start(args, query);
    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:[self expandQuery:query] withArgumentsInArray:nil orDictionary:nil orVAList:*foolTheStaticAnalyzer];
        if (! s) [self queryFailedInDatabase:db];
        if ([s next]) firstValue = [[s objectForColumnIndex:0] copy];
        [s close];
    }];
    va_end(args);
    return firstValue;
}

+ (void)queryFailedInDatabase:(FMDatabase *)db
{
    [[NSException exceptionWithName:@"FCModelSQLiteException" reason:db.lastErrorMessage userInfo:nil] raise];
}

#pragma mark - Attributes and CRUD

+ (instancetype)new  { return [[self alloc] initWithFieldValues:@{} existsInDatabaseAlready:NO]; }
- (instancetype)init { return [self initWithFieldValues:@{} existsInDatabaseAlready:NO]; }

- (instancetype)initWithFieldValues:(NSDictionary *)fieldValues existsInDatabaseAlready:(BOOL)existsInDB
{
    if ( (self = [super init]) ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reload:) name:FCModelReloadNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(saveByNotification:) name:FCModelSaveNotification object:nil];
        existsInDatabase = existsInDB;
        deleted = NO;
        primaryKeyLocked = NO;
        primaryKeySet = existsInDatabase;
        
        [g_fieldInfo[self.class] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FCFieldInfo *info = (FCFieldInfo *)obj;
            if (info.defaultValue) [self setValue:info.defaultValue forKey:key];
            [self addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        }];

        [fieldValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self decodeFieldValue:obj intoPropertyName:key];
        }];
        
        primaryKeyLocked = YES;
        self.changedProperties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)saveByNotification:(NSNotification *)n
{
    Class targetedClass = n.userInfo[FCModelClassKey];
    if (targetedClass && ! [self isKindOfClass:targetedClass]) return;
    [self save];
}

- (void)reload:(NSNotification *)n
{
    Class targetedClass = n.userInfo[FCModelClassKey];
    if (targetedClass && ! [self isKindOfClass:targetedClass]) return;
    if (! self.existsInDatabase) return;

    if (self.hasUnsavedChanges) {
        [[NSException exceptionWithName:@"FCReloadConflict" reason:
            [NSString stringWithFormat:@"%@ ID %@ has unsaved changes during a write-consistency reload: %@", NSStringFromClass(self.class), self.primaryKey, self.changedProperties]
        userInfo:nil] raise];
    }
    
    __block NSDictionary *resultDictionary = nil;

    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *s = [db executeQuery:[self.class expandQuery:@"SELECT * FROM \"$T\" WHERE \"$PK\"=?"], self.primaryKey];
        if (! s) [self.class queryFailedInDatabase:db];
        if ([s next]) {
            // Update from new database values
            resultDictionary = [s.resultDictionary copy];
        } else {
            // This instance no longer exists in database
            deleted = YES;
            existsInDatabase = NO;
        }
        [s close];
    }];

    if (deleted) {
        [self didDelete];
        [NSNotificationCenter.defaultCenter postNotificationName:FCModelDeleteNotification object:self.class userInfo:@{ FCModelInstanceKey : self }];
    } else {
        __block BOOL didUpdate = NO;
        [resultDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *fieldName, id fieldValue, BOOL *stop) {
            if ([fieldName isEqualToString:g_primaryKeyFieldName[self.class]]) return;
            
            id existing = [self valueForKeyPath:fieldName];
            if (! [existing isEqual:fieldValue]) {
                // Conflict resolution
                
                BOOL valueIsStillChanged = NO;
                if (self.changedProperties[fieldName]) {
                    id newFieldValue = [self valueOfFieldName:fieldName byResolvingReloadConflictWithDatabaseValue:fieldValue];
                    valueIsStillChanged = ! [fieldValue isEqual:newFieldValue];
                    fieldValue = newFieldValue;
                }
                
                // NSLog(@"%@ %@ updating \"%@\" [%@]=>[%@]", NSStringFromClass(self.class), self.primaryKey, fieldName, existing, fieldValue);
                [self decodeFieldValue:fieldValue intoPropertyName:fieldName];
                if (! valueIsStillChanged) [self.changedProperties removeObjectForKey:fieldName];
                didUpdate = YES;
            }
        }];

        if (didUpdate) {
            [self didUpdate];
            [NSNotificationCenter.defaultCenter postNotificationName:FCModelUpdateNotification object:self.class userInfo:@{ FCModelInstanceKey : self }];
        }
    }
}

- (id)valueOfFieldName:(NSString *)fieldName byResolvingReloadConflictWithDatabaseValue:(id)valueInDatabase
{
    // A very simple subclass implementation could just always accept the locally modified value:
    //     return [self valueForKeyPath:fieldName]
    //
    // ...or always accept the database value:
    //     return valueInDatabase;
    //
    // But this is a decision that you should really make knowingly and deliberately in each case.

    [[NSException exceptionWithName:@"FCReloadConflict" reason:
        [NSString stringWithFormat:@"%@ ID %@ cannot resolve reload conflict for \"%@\"", NSStringFromClass(self.class), self.primaryKey, fieldName]
    userInfo:nil] raise];
    return nil;
}

- (FCModelSaveResult)revertUnsavedChanges
{
    if (self.changedProperties.count == 0) return FCModelSaveNoChanges;
    [self.changedProperties enumerateKeysAndObjectsUsingBlock:^(NSString *fieldName, id oldValue, BOOL *stop) {
        [self setValue:(oldValue == [NSNull null] ? nil : oldValue) forKeyPath:fieldName];
    }];
    [self.changedProperties removeAllObjects];
    return FCModelSaveSucceeded;
}

- (FCModelSaveResult)revertUnsavedChangeToFieldName:(NSString *)fieldName
{
    id oldValue = self.changedProperties[fieldName];
    if (oldValue) {
        [self setValue:(oldValue == [NSNull null] ? nil : oldValue) forKeyPath:fieldName];
        [self.changedProperties removeObjectForKey:fieldName];
        return FCModelSaveSucceeded;
    } else {
        return FCModelSaveNoChanges;
    }
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:FCModelReloadNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:FCModelSaveNotification object:nil];

    [g_fieldInfo[self.class] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self removeObserver:self forKeyPath:key];
    }];
}

- (BOOL)existsInDatabase  { return existsInDatabase; }
- (BOOL)hasUnsavedChanges { return ! existsInDatabase || self.changedProperties.count; }

- (FCModelSaveResult)save
{
    if (deleted) [[NSException exceptionWithName:@"FCAttemptToSaveAfterDelete" reason:@"Cannot save deleted instance" userInfo:nil] raise];
    BOOL dirty = self.changedProperties.count;
    if (! dirty && existsInDatabase) return FCModelSaveNoChanges;
    
    BOOL update = existsInDatabase;
    NSArray *columnNames;
    NSMutableArray *values;
    
    NSString *tableName = NSStringFromClass(self.class);
    NSString *pkName = g_primaryKeyFieldName[self.class];
    id primaryKey = primaryKeySet ? [self encodedValueForFieldName:pkName] : nil;
    if (! primaryKey) {
        NSAssert1(! update, @"Cannot update %@ without primary key", NSStringFromClass(self.class));
        primaryKey = [NSNull null];
    }

    // Validate NOT NULL columns
    [g_fieldInfo[self.class] enumerateKeysAndObjectsUsingBlock:^(id key, FCFieldInfo *info, BOOL *stop) {
        if (info.nullAllowed) return;
    
        id value = [self valueForKey:key];
        if (! value || value == [NSNull null]) {
            [[NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Cannot save NULL to NOT NULL property %@.%@", tableName, key] userInfo:nil] raise];
        }
    }];
    
    if (update) {
        if (! [self shouldUpdate]) return FCModelSaveRefused;
        columnNames = [self.changedProperties allKeys];
    } else {
        if (! [self shouldInsert]) return FCModelSaveRefused;
        NSMutableSet *columnNamesMinusPK = [[NSSet setWithArray:[g_fieldInfo[self.class] allKeys]] mutableCopy];
        [columnNamesMinusPK removeObject:pkName];
        columnNames = [columnNamesMinusPK allObjects];
    }

    values = [NSMutableArray arrayWithCapacity:columnNames.count];
    [columnNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [values addObject:[self encodedValueForFieldName:obj]];
    }];
    [values addObject:primaryKey];

    NSString *query;
    if (update) {
        query = [NSString stringWithFormat:
            @"UPDATE \"%@\" SET \"%@\"=? WHERE \"%@\"=?",
            tableName,
            [columnNames componentsJoinedByString:@"\"=?,\""],
            pkName
        ];
    } else {
        if (columnNames.count > 0) {
            query = [NSString stringWithFormat:
                @"INSERT INTO \"%@\" (\"%@\",\"%@\") VALUES (%@?)",
                tableName,
                [columnNames componentsJoinedByString:@"\",\""],
                pkName,
                [@"" stringByPaddingToLength:(columnNames.count * 2) withString:@"?," startingAtIndex:0]
            ];
        } else {
            query = [NSString stringWithFormat:
                @"INSERT INTO \"%@\" (\"%@\") VALUES (?)",
                tableName,
                pkName
            ];
        }
    }

    __block BOOL success = NO;
    __block sqlite_int64 lastInsertID;
    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:query withArgumentsInArray:values];
        if (success) {
            lastInsertID = [db lastInsertRowId];
            self._lastSQLiteError = nil;
        } else {
            self._lastSQLiteError = db.lastError;
        }
    }];
    
    if (! success) return FCModelSaveFailed;

    if (! primaryKey || primaryKey == [NSNull null]) {
        [self setValue:[NSNumber numberWithUnsignedLongLong:lastInsertID] forKey:g_primaryKeyFieldName[self.class]];
        [self registerUniqueInstance];
    }
    
    [self.changedProperties removeAllObjects];
    primaryKeySet = YES;
    existsInDatabase = YES;
    
    if (update) {
        [self didUpdate];
        [NSNotificationCenter.defaultCenter postNotificationName:FCModelUpdateNotification object:self.class userInfo:@{ FCModelInstanceKey : self }];
    } else {
        [self didInsert];
        [NSNotificationCenter.defaultCenter postNotificationName:FCModelInsertNotification object:self.class userInfo:@{ FCModelInstanceKey : self }];
    }
    
    return FCModelSaveSucceeded;
}

- (FCModelSaveResult)delete
{
    if (deleted) return FCModelSaveNoChanges;
    if (! [self shouldDelete]) return FCModelSaveRefused;
    
    __block BOOL success = NO;
    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *query = [self.class expandQuery:@"DELETE FROM \"$T\" WHERE \"$PK\" = ?"];
        success = [db executeUpdate:query, [self primaryKey]];
        self._lastSQLiteError = success ? nil : db.lastError;
    }];

    if (! success) return FCModelSaveFailed;
    
    deleted = YES;
    existsInDatabase = NO;
    [self didDelete];
    [NSNotificationCenter.defaultCenter postNotificationName:FCModelDeleteNotification object:self.class userInfo:@{ FCModelInstanceKey : self }];
    [self removeUniqueInstance];
    
    return FCModelSaveSucceeded;
}

+ (void)saveAll
{
    [NSNotificationCenter.defaultCenter postNotificationName:FCModelSaveNotification object:nil userInfo:@{ FCModelClassKey : self }];
}

#pragma mark - Utilities

- (id)primaryKey { return [self valueForKey:g_primaryKeyFieldName[self.class]]; }

+ (NSString *)expandQuery:(NSString *)query
{
    if (self == FCModel.class) return query;
    query = [query stringByReplacingOccurrencesOfString:@"$PK" withString:g_primaryKeyFieldName[self]];
    return [query stringByReplacingOccurrencesOfString:@"$T" withString:NSStringFromClass(self)];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@#%@: 0x%p>", NSStringFromClass(self.class), self.primaryKey, self];
}

- (NSDictionary *)allFields
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [[self.class databaseFieldNames] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = [self valueForKey:obj];
        if (value) [dictionary setObject:value forKey:obj];
    }];
    return dictionary;
}

- (NSUInteger)hash
{
    return ((NSObject *)self.primaryKey).hash;
}

#pragma mark - Database management

+ (void)openDatabaseAtPath:(NSString *)path withSchemaBuilder:(void (^)(FMDatabase *db, int *schemaVersion))schemaBuilder { [self openDatabaseAtPath:path withDatabaseInitializer:nil schemaBuilder:schemaBuilder]; }

+ (void)openDatabaseAtPath:(NSString *)path withDatabaseInitializer:(void (^)(FMDatabase *db))databaseInitializer schemaBuilder:(void (^)(FMDatabase *db, int *schemaVersion))schemaBuilder
{
    g_databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    NSMutableDictionary *mutableFieldInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutablePrimaryKeyFieldName = [NSMutableDictionary dictionary];
    
    [g_databaseQueue inDatabase:^(FMDatabase *db) {
        if (databaseInitializer) databaseInitializer(db);
        
        int startingSchemaVersion = 0;
        FMResultSet *rs = [db executeQuery:@"SELECT value FROM _FCModelMetadata WHERE key = 'schema_version'"];
        if ([rs next]) {
            startingSchemaVersion = [rs intForColumnIndex:0];
        } else {
            [db executeUpdate:@"CREATE TABLE _FCModelMetadata (key TEXT, value TEXT, PRIMARY KEY (key))"];
            [db executeUpdate:@"INSERT INTO _FCModelMetadata VALUES ('schema_version', 0)"];
        }
        [rs close];
        
        int newSchemaVersion = startingSchemaVersion;
        schemaBuilder(db, &newSchemaVersion);
        if (newSchemaVersion != startingSchemaVersion) {
            [db executeUpdate:@"UPDATE _FCModelMetadata SET value = ? WHERE key = 'schema_version'", @(newSchemaVersion)];
        }
        
        // Read schema for field names and primary keys
        FMResultSet *tablesRS = [db executeQuery:
            @"SELECT DISTINCT tbl_name FROM (SELECT * FROM sqlite_master UNION ALL SELECT * FROM sqlite_temp_master) WHERE type != 'meta' AND name NOT LIKE 'sqlite_%' AND name != '_FCModelMetadata'"
        ];
        while ([tablesRS next]) {
            NSString *tableName = [tablesRS stringForColumnIndex:0];
            Class tableModelClass = NSClassFromString(tableName);
            if (! tableModelClass || ! [tableModelClass isSubclassOfClass:self]) continue;
            
            NSString *primaryKeyName = nil;
            BOOL isMultiColumnPrimaryKey = NO;
            NSMutableDictionary *fields = [NSMutableDictionary dictionary];
            FMResultSet *columnsRS = [db executeQuery:[NSString stringWithFormat: @"PRAGMA table_info('%@')", tableName]];
            while ([columnsRS next]) {
                NSString *fieldName = [columnsRS stringForColumnIndex:1];
                if (NULL == class_getProperty(tableModelClass, [fieldName UTF8String])) {
                    NSLog(@"[FCModel] ignoring column %@.%@, no matching model property", tableName, fieldName);
                    continue;
                }
                
                int isPK = [columnsRS intForColumnIndex:5];
                if (isPK == 1) primaryKeyName = fieldName;
                else if (isPK > 1) isMultiColumnPrimaryKey = YES;

                NSString *fieldType = [columnsRS stringForColumnIndex:2];
                FCFieldInfo *info = [FCFieldInfo new];
                info.nullAllowed = ! [columnsRS boolForColumnIndex:3];
                
                // Type-parsing algorithm from SQLite's column-affinity rules: http://www.sqlite.org/datatype3.html
                // except the addition of BOOL as its own recognized type
                if ([fieldType rangeOfString:@"INT"].location != NSNotFound) {
                    info.type = FCFieldTypeInteger;
                    if ([fieldType rangeOfString:@"UNSIGNED"].location != NSNotFound) {
                        info.defaultValue = [NSNumber numberWithUnsignedLongLong:[columnsRS unsignedLongLongIntForColumnIndex:4]];
                    } else {
                        info.defaultValue = [NSNumber numberWithLongLong:[columnsRS longLongIntForColumnIndex:4]];
                    }
                } else if ([fieldType rangeOfString:@"BOOL"].location != NSNotFound) {
                    info.type = FCFieldTypeBool;
                    info.defaultValue = [NSNumber numberWithBool:[columnsRS boolForColumnIndex:4]];
                } else if (
                    [fieldType rangeOfString:@"TEXT"].location != NSNotFound ||
                    [fieldType rangeOfString:@"CHAR"].location != NSNotFound ||
                    [fieldType rangeOfString:@"CLOB"].location != NSNotFound
                ) {
                    info.type = FCFieldTypeText;
                    info.defaultValue = [[[columnsRS stringForColumnIndex:4]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]]
                        stringByReplacingOccurrencesOfString:@"''" withString:@"'"
                    ];
                } else if (
                    [fieldType rangeOfString:@"REAL"].location != NSNotFound ||
                    [fieldType rangeOfString:@"FLOA"].location != NSNotFound ||
                    [fieldType rangeOfString:@"DOUB"].location != NSNotFound
                ) {
                    info.type = FCFieldTypeDouble;
                    info.defaultValue = [NSNumber numberWithDouble:[columnsRS doubleForColumnIndex:4]];
                } else {
                    info.type = FCFieldTypeOther;
                    info.defaultValue = nil;
                }
                
                if (isPK) info.defaultValue = nil;
                else if ([[columnsRS stringForColumnIndex:4] isEqualToString:@"NULL"]) info.defaultValue = nil;

                [fields setObject:info forKey:fieldName];
            }
            
            if (! primaryKeyName || isMultiColumnPrimaryKey) {
                [[NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"FCModel tables must have a single-column primary key, not found in %@", tableName] userInfo:nil] raise];
            }
            
            id classKey = tableModelClass;
            [mutableFieldInfo setObject:fields forKey:classKey];
            [mutablePrimaryKeyFieldName setObject:primaryKeyName forKey:classKey];
            [columnsRS close];
        }
        [tablesRS close];
    
        g_fieldInfo = [mutableFieldInfo copy];
        g_primaryKeyFieldName = [mutablePrimaryKeyFieldName copy];
    }];
}

// Note: use of +closeDatabase is unsupported for apps - it's purely to enable unit testing
+ (void)closeDatabase
{
    [g_databaseQueue close];
    g_databaseQueue = nil;
    g_primaryKeyFieldName = nil;
    g_fieldInfo = nil;
    [g_instances removeAllObjects];
}

+ (FMDatabaseQueue *)databaseQueue { return g_databaseQueue; }

@end
