//
//  UVArticle.m
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVResponseDelegate.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVForum.h"

@implementation UVArticle

@synthesize question;
@synthesize answerHTML;
@synthesize articleId;

+ (void)initialize {
    [self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
    [self setBaseURL:[self siteURL]];
}

+ (NSArray *)getInstantAnswers:(NSString *)query delegate:(id)delegate {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"3", @"per_page",
                            [NSString stringWithFormat:@"%d", [UVSession currentSession].clientConfig.forum.forumId], @"forum_id",
                            query, @"query",
                            nil];

    return [self getPath:[self apiPath:@"/instant_answers/search.json"]
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveInstantAnswers:)];
}

+ (UVBaseModel *)modelForDictionary:(NSDictionary *)dict {
    NSString *type = [dict objectForKey:@"type"];
    if ([@"suggestion" isEqualToString:type])
        return [UVSuggestion modelForDictionary:dict];
    return [super modelForDictionary:dict];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        self.question = [self objectOrNilForDict:dict key:@"question"];
        self.answerHTML = [self objectOrNilForDict:dict key:@"answer_html"];
        self.articleId = [(NSNumber *)[self objectOrNilForDict:dict key:@"id"] integerValue];
    }
    return self;
}

- (void)dealloc {
    self.question = nil;
    self.answerHTML = nil;
    [super dealloc];
}

@end
