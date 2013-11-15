//
//  UVSuggestion.m
//  UserVoice
//
//  Created by UserVoice on 10/27/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVSuggestion.h"
#import "UVSession.h"
#import "UVSubdomain.h"
#import "UVClientConfig.h"
#import "UVUser.h"
#import "UVForum.h"
#import "UVCategory.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVUtils.h"

@implementation UVSuggestion

@synthesize suggestionId;
@synthesize forumId;
@synthesize commentsCount;
@synthesize subscriberCount;
@synthesize title;
@synthesize abstract;
@synthesize text;
@synthesize status;
@synthesize statusHexColor;
@synthesize forumName;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize closedAt;
@synthesize creatorName;
@synthesize creatorId;
@synthesize responseText;
@synthesize responseUserName;
@synthesize responseUserAvatarUrl;
@synthesize responseUserId;
@synthesize responseUserTitle;
@synthesize responseCreatedAt;
@synthesize category;
@synthesize subscribed;

+ (id)getWithForum:(UVForum *)forum page:(NSInteger)page delegate:(id)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions.json", (int)forum.forumId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSNumber numberWithInt:page] stringValue], @"page",
                            @"public", @"filter",
                            [[UVSession currentSession].clientConfig.subdomain suggestionSort], @"sort",
                            //@"5", @"per_page",
                            nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveSuggestions:)
                 rootKey:@"suggestions"];
}

+ (id)searchWithForum:(UVForum *)forum query:(NSString *)query delegate:(id)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/search.json", (int)forum.forumId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            query, @"query",
                            nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didSearchSuggestions:)
                 rootKey:@"suggestions"];
}

+ (id)createWithForum:(UVForum *)forum
             category:(NSInteger)categoryId
                title:(NSString *)title
                 text:(NSString *)text
                votes:(NSInteger)votes
             callback:(UVCallback *)callback {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions.json", (int)forum.forumId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSNumber numberWithInteger:votes] stringValue], @"suggestion[votes]",
                            title, @"suggestion[title]",
                            text == nil ? @"" : text, @"suggestion[text]",
                            categoryId == 0 ? @"" : [NSString stringWithFormat:@"%d", (int)categoryId], @"suggestion[category_id]",
                            nil];
    return [[self class] postPath:path
                       withParams:params
                           target:callback
                         selector:@selector(invokeCallback:)
                          rootKey:@"suggestion"];
}

- (id)subscribe:(id)delegate {
    NSString *path = [UVSuggestion apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/watch.json", (int)self.forumId, (int)self.suggestionId]];
    NSDictionary *params = @{ @"subscribe" : @"true" };
    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didSubscribe:)
                          rootKey:@"suggestion"];
}

- (id)unsubscribe:(id)delegate {
    NSString *path = [UVSuggestion apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/watch.json", (int)self.forumId, (int)self.suggestionId]];
    NSDictionary *params = @{ @"subscribe" : @"false" };
    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didUnsubscribe:)
                          rootKey:@"suggestion"];
}

- (UIColor *)statusColor {
    return self.statusHexColor ? [UVUtils parseHexColor:self.statusHexColor] : [UIColor clearColor];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        self.suggestionId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.commentsCount = [(NSNumber *)[dict objectForKey:@"comments_count"] integerValue];
        self.subscriberCount = [(NSNumber *)[dict objectForKey:@"subscriber_count"] integerValue];
        self.title = [self objectOrNilForDict:dict key:@"title"];
        self.abstract = [self objectOrNilForDict:dict key:@"abstract"];
        self.text = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:dict key:@"text"]];
        self.createdAt = [self parseJsonDate:[dict objectForKey:@"created_at"]];
        self.subscribed = [(NSNumber *)[self objectOrNilForDict:dict key:@"subscribed"] boolValue];
        NSDictionary *statusDict = [self objectOrNilForDict:dict key:@"status"];
        if (statusDict)
        {
            self.status = [statusDict objectForKey:@"name"];
            self.statusHexColor = [statusDict objectForKey:@"hex_color"];
        }
        NSDictionary *creator = [self objectOrNilForDict:dict key:@"creator"];
        if (creator)
        {
            self.creatorName = [creator objectForKey:@"name"];
            self.creatorId = [(NSNumber *)[creator objectForKey:@"id"] integerValue];
        }
        NSDictionary *response = [self objectOrNilForDict:dict key:@"response"];
        if (response) {
            self.responseText = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:response key:@"text"]];
            NSDictionary *responseCreator = [self objectOrNilForDict:response key:@"creator"];
            if (responseCreator) {
                self.responseUserName = [self objectOrNilForDict:responseCreator key:@"name"];
                self.responseUserAvatarUrl = [self objectOrNilForDict:responseCreator key:@"avatar_url"];
                self.responseUserId = [(NSNumber *)[self objectOrNilForDict:responseCreator key:@"id"] integerValue];
                self.responseUserTitle = [self objectOrNilForDict:responseCreator key:@"title"];
            }
            self.responseCreatedAt = [self parseJsonDate:[response objectForKey:@"created_at"]];
        }

        NSDictionary *topic = [self objectOrNilForDict:dict key:@"topic"];
        if (topic)
        {
            NSDictionary *forum = [self objectOrNilForDict:topic key:@"forum"];
            if (forum) {
                self.forumId = [(NSNumber *)[forum objectForKey:@"id"] integerValue];
                self.forumName = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:forum key:@"name"]];
            }
        }

        NSDictionary *categoryDict = [self objectOrNilForDict:dict key:@"category"];
        if (categoryDict) {
            self.category = [[UVCategory alloc] initWithDictionary:categoryDict];
        }
    }
    return self;
}

- (NSString *)responseUserWithTitle {
    if ([responseUserTitle length] > 0) {
        return [NSString stringWithFormat:@"%@, %@", self.responseUserName, self.responseUserTitle];
    } else {
        return self.responseUserName;
    }
}

@end
