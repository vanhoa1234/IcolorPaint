//
//  KMJPZipLookUpClient.m
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUpClient.h"
#import "AFXMLRequestOperation.h"

static NSString * const kKMJPZipLookUpBaseURLString = @"http://zip.cgis.biz/xml/";
static NSString * const kKMJPZipLookUpRequestPath = @"zip.php";

@implementation KMJPZipLookUpClient

+ (instancetype)sharedClient
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kKMJPZipLookUpBaseURLString]];
    });
    return _instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFXMLRequestOperation class]];

    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"text/xml"];

    return self;
}

- (void)lookUpWithZipcode:(NSString *)zipcode
                  success:(void (^)(AFHTTPRequestOperation *, KMJPZipLookUpResponse *))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSString *zip = [zipcode stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [self getPath:kKMJPZipLookUpRequestPath
       parameters:@{@"zn": zip}
          success:^(AFHTTPRequestOperation *operation, NSXMLParser *XMLParser){
              @try {
                  KMJPZipLookUpParser *parser = [[KMJPZipLookUpParser alloc] init];
                  XMLParser.delegate = parser;
                  [XMLParser parse];
                  KMJPZipLookUpResponse *response = [parser response];
                  if (response && [response isSuccess]) {
                      if (success) {
                          success(operation, response);
                      }
                  } else {
                      NSDictionary *userInfo = @{NSLocalizedDescriptionKey: response.errorMessage};
                      NSError *error = [NSError errorWithDomain:KMJPZipLookUpErrorDomain code:KMJPZipLookUpErrorTypeAPIError userInfo:userInfo];
                      if (failure) {
                          failure(operation, error);
                      }
                  }
              }
              @catch (NSException *exception) {
                  NSLog(@"exception > %@", exception);
                  NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"住所検索機能エラー。\n時間をおいて再度お試しください。"};
                  NSError *error = [NSError errorWithDomain:KMJPZipLookUpErrorDomain code:KMJPZipLookUpErrorTypeAPIError userInfo:userInfo];
                  if (failure) {
                      failure(operation, error);
                  }
              }
          } failure:failure
     ];
}

- (BOOL)validateZipcode:(NSString *)zipcode withError:(NSError *__autoreleasing *)error
{
    static NSString * zipcodeEasyFormat = @"\\d{7}";

    NSString *message;
    if (![zipcode length]) {
        message = @"郵便番号を入力してください";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
        if (error) {
            *error = [NSError errorWithDomain:KMJPZipLookUpErrorDomain code:KMJPZipLookUpErrorTypeRequestParameterInvalid userInfo:userInfo];
        }
        return NO;
    }

    NSString *zip = [zipcode stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSRange match = [zip rangeOfString:zipcodeEasyFormat options:NSRegularExpressionSearch];
    if (match.location == NSNotFound) {
        message = @"郵便番号は7桁の半角数字で入力してください";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
        if (error) {
            *error = [NSError errorWithDomain:KMJPZipLookUpErrorDomain code:KMJPZipLookUpErrorTypeRequestParameterInvalid userInfo:userInfo];
        }
        return NO;
    }

    return YES;
}

@end
