//
//  HTTPRiotFormatXML.m
//  HTTPRiot
//
//  Created by Justin Palmer on 2/8/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "HRFormatXML.h"
#import "AIXMLSerialization.h"

@implementation HRFormatXML
+ (NSString *)extension {
    return @"xml";
}

+ (NSString *)mimeType {
    return @"application/xml";
}

+ (id)decode:(NSData *)data error:(NSError **)error {
    NSError *parseError = nil;
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyXML error:&parseError] autorelease];
    
    if(parseError != nil) {        
        if(error != nil)
            *error = parseError;
        
        return nil;
    }
    
    return [doc toDictionary];
}

+ (NSString *)encode:(id)data error:(NSError **)error {
    NSAssert(true, @"XML Encoding is not supported.  Currently accepting patches");
    return nil;
}

@end
