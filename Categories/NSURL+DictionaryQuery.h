//
//  NSURL+DictionaryQuery.h
//  UserVoice
//
//  Created by UserVoice on 1/12/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


// Mainly extends NSURL with functionality to parse query strings.
@interface NSURL (UVParseCategory)
- (NSDictionary *)queryDictionary;
@end
