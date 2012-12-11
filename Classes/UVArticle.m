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
#import "UVHelpTopic.h"
#import "UVConfig.h"

@implementation UVArticle

@synthesize question;
@synthesize answerHTML;
@synthesize articleId;

+ (void)initialize {
    [self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
    [self setBaseURL:[self siteURL]];
}

+ (id)getArticlesWithTopicId:(int)topicId delegate:(id)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/topics/%d/articles.json", topicId]];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveArticles:)];
}

+ (id)getArticlesWithDelegate:(id)delegate {
    NSString *path = [self apiPath:@"/articles.json"];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveArticles:)];
}

+ (NSArray *)getInstantAnswers:(NSString *)query delegate:(id)delegate {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
        @"per_page" : @"3",
        @"forum_id" : [NSString stringWithFormat:@"%d", [UVSession currentSession].clientConfig.forum.forumId],
           @"query" : query
    }];

    if ([UVSession currentSession].config.topicId)
        [params setObject:[NSString stringWithFormat:@"%d", [UVSession currentSession].config.topicId] forKey:@"topic_id"];

    return [self getPath:[self apiPath:@"/instant_answers/search.json"]
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveInstantAnswers:)];
}

+ (UVBaseModel *)modelForDictionary:(NSDictionary *)dict {
    if ([@"suggestion" isEqualToString:[dict objectForKey:@"type"]])
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
