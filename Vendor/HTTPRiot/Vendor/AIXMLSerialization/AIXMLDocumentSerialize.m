//
//  NSXMLDocument+Serialize.m
//  AIXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import "AIXMLDocumentSerialize.h"
#import "AIXMLElementSerialize.h"

@implementation NSXMLDocument (Serialize)
/**
 * Convert NSXMLDocument to an NSDictionary
 * @see NSXMLElement#toDictionary
 */
- (NSMutableDictionary *)toDictionary
{
   return [[self rootElement] toDictionary];
}
@end
