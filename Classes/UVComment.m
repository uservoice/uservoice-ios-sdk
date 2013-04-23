//
//  UVComment.m
//  UserVoice
//
//  Created by UserVoice on 11/11/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVComment.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSuggestion.h"
#import "UVForum.h"
#import "NSString+HTMLEntities.h"


@implementation UVComment

@synthesize commentId;
@synthesize text;
@synthesize userName;
@synthesize userId;
@synthesize avatarUrl;
@synthesize karmaScore;
@synthesize createdAt;

+ (id)getWithSuggestion:(UVSuggestion *)suggestion page:(NSInteger)page delegate:(id)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/comments.json",
                                    suggestion.forumId,
                                    suggestion.suggestionId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSNumber numberWithInt:page] stringValue],
                            @"page",
                            nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveComments:)
                 rootKey:@"comments"];
}

+ (id)createWithSuggestion:(UVSuggestion *)suggestion text:(NSString *)text delegate:(id)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/comments.json",
                                    suggestion.forumId,
                                    suggestion.suggestionId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            text, @"comment[text]",
                            nil];
    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didCreateComment:)
                          rootKey:@"comment"];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.commentId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.text = [[self objectOrNilForDict:dict key:@"text"] stringByDecodingHTMLEntities];
        NSDictionary *user = [dict objectForKey:@"creator"];
        if (user && ![[NSNull null] isEqual:user]) {
            self.userName = [[user objectForKey:@"name"] stringByDecodingHTMLEntities];
            self.userId = [(NSNumber *)[user objectForKey:@"id"] integerValue];
            self.avatarUrl = [self objectOrNilForDict:user key:@"avatar_url"];
            self.karmaScore = [(NSNumber *)[user objectForKey:@"karma_score"] integerValue];
            self.createdAt = [self parseJsonDate:[dict objectForKey:@"created_at"]];
        }
    }
    return self;
}

- (void)dealloc {
    self.text = nil;
    self.userName = nil;
    self.avatarUrl = nil;
    self.createdAt = nil;
    [super dealloc];
}

@end
