//
//  NSString+HTMLEntities.h
//  UserVoice
//
//  Created by Austin Taylor on 12/29/11.
//  Copyright (c) 2011 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTMLEntities)

- (NSString *)stringByDecodingHTMLEntities;

@end
