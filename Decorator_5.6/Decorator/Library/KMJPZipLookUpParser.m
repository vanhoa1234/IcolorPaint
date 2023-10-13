//
//  KMJPZipLookUpParser.m
//  KMJPZipLookUp
//
//  Created by Kosuke Matsuda on 2013/04/23.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMJPZipLookUpParser.h"

@interface KMJPZipLookUpParser () {
    // ZipSearch
    KMJPZipLookUpResponse *_response;
    KMJPZipLookUpAddress *_address;
    NSError *_error;
}

@end

@implementation KMJPZipLookUpParser

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _response = nil;
    _address = nil;
    _error = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"ZIP_result"]) {
        _response = [[KMJPZipLookUpResponse alloc] init];
    }
    if ([elementName isEqualToString:@"ADDRESS_value"]) {
        _address = [[KMJPZipLookUpAddress alloc] init];
    }
    if ([elementName isEqualToString:@"result"]) {
        NSString *value;
        value = attributeDict[@"result_code"];
        if ([value length]) {
            _response.code = value;
        }
        value = attributeDict[@"request_zip_num"];
        if ([value length]) {
            _response.requestZipcode = value;
        }
        value = attributeDict[@"result_zip_num"];
        if ([value length]) {
            _response.resultZipcode = value;
        }
        value = attributeDict[@"result_values_count"];
        if ([value length]) {
            [_response prepareAddressesWithCapacity:[value intValue]];
        }
        // Error
        value = attributeDict[@"error_code"];
        if ([value length]) {
            _response.errorCode = value;
        }
        value = attributeDict[@"error_note"];
        if ([value length]) {
            _response.errorMessage = value;
        }
    }
    if ([elementName isEqualToString:@"value"]) {
        NSString *value;
        value = attributeDict[@"state"];
        if ([value length] && ![value isEqualToString:@"none"]) {
            _address.prefecture = value;
        }
        value = attributeDict[@"city"];
        if ([value length] && ![value isEqualToString:@"none"]) {
            _address.city = value;
        }
        value = attributeDict[@"address"];
        if ([value length] && ![value isEqualToString:@"none"]) {
            _address.address = value;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"ADDRESS_value"]) {
        if (_response && _address) {
            [_response addAddress:_address];
        }
        _address = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error: %i, Column: %i, Line: %i, Description: %@",
          [parseError code],
          [parser columnNumber],
          [parser lineNumber],
          [parseError description]);

    _error = parseError;
}

@end
