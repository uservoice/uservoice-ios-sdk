//
//  NSXMLDocument+Serialize.h
//  AIXMLSerialize
//
//  Created by Justin Palmer on 2/24/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AIXMLSerialization.h"


@interface NSXMLDocument (Serialize)
- (NSMutableDictionary *)toDictionary;
@end
