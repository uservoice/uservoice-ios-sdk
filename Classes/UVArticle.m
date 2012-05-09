//
//  UVArticle.m
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVArticle.h"

@implementation UVArticle

@synthesize question;
@synthesize answerHTML;

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        self.question = [self objectOrNilForDict:dict key:@"question"];
        self.answerHTML = [self objectOrNilForDict:dict key:@"answer_html"];
    }
    return self;
}

- (void)dealloc {
    self.question = nil;
    self.answerHTML = nil;
    [super dealloc];
}

@end
