//
//  HRFormatJSON.m
//  HTTPRiot
//
//  Created by Justin Palmer on 2/8/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "HRFormatJSON.h"

@implementation HRFormatJSON

+ (NSString *)extension {
    return @"json";
}

+ (NSString *)mimeType {
    return @"application/json";
}

+ (id)decode:(NSData *)data error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

+ (NSString *)encode:(id)object error:(NSError **)error {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:error];
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

@end
