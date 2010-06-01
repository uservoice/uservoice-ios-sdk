//
//  HRFormatJSON.m
//  HTTPRiot
//
//  Created by Justin Palmer on 2/8/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "HRFormatJSON.h"
#import "JSON.h"

@implementation HRFormatJSON
+ (NSString *)extension {
    return @"json";
}

+ (NSString *)mimeType {
    return @"application/json";
}

+ (id)decode:(NSData *)data error:(NSError **)error {
    NSString *rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // If we failed to decode the data using UTF8 attempt to use ASCII encoding.
    if(rawString == nil && ([data length] > 0)) {
        rawString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    NSError *parseError = nil;
    SBJSON *parser = [[SBJSON alloc] init];
    id results = [parser objectWithString:rawString error:&parseError];
    [parser release];
    [rawString release];
    
    if(parseError && !results) {  
        if(error != nil)      
            *error = parseError;
        return nil;
    }
    
    return results;
}

+ (NSString *)encode:(id)data error:(NSError **)error {
    return [data JSONRepresentation];
}
@end
