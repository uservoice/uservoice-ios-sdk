//
//  UVUser.m
//  UserVoice
//
//  Created by UserVoice on 10/26/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVUser.h"
#import "UVRequestToken.h"
#import "UVSuggestion.h"
#import "UVSession.h"
#import "YOAuthToken.h"
#import "UVConfig.h"
#import "UVClientConfig.h"
#import "UVForum.h"
#import "NSString+HTMLEntities.h"

@implementation UVUser

@synthesize userId;
@synthesize name;
@synthesize displayName;
@synthesize email;
@synthesize ideaScore;
@synthesize activityScore;
@synthesize karmaScore;
@synthesize url;
@synthesize avatarUrl;
@synthesize supportedSuggestions;
@synthesize createdSuggestions;
@synthesize createdAt;
@synthesize suggestionsNeedReload;
@synthesize votesRemaining;
@synthesize visibleForumsDict;

+ (id)discoverWithEmail:(NSString *)email delegate:(id)delegate {
    NSString *path = [self apiPath:@"/users/discover.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: email, @"email", nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didDiscoverUser:)
                 rootKey:@"user"];
}

+ (id)retrieveCurrentUser:(id)delegate {
    NSString *path = [self apiPath:@"/users/current.json"];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveCurrentUser:)
                 rootKey:@"user"];
}

// only called when instigated by the user, creates a global user
+ (id)findOrCreateWithEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id)delegate {
    NSString *path = [self apiPath:@"/users.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            aName == nil ? @"" : aName, @"user[display_name]",
                            anEmail == nil ? @"" : anEmail, @"user[email]",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token",
                            nil];
    return [self postPath:path
               withParams:params
                   target:delegate
                 selector:@selector(didCreateUser:)
                  rootKey:@"user"];
}

// two methods for creating with the client, create local users
+ (id)findOrCreateWithGUID:(NSString *)aGUID andEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id)delegate {
    NSString *path = [self apiPath:@"/users/find_or_create.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            aGUID, @"user[guid]",
                            aName == nil ? @"" : aName, @"user[display_name]",
                            anEmail == nil ? @"" : anEmail, @"user[email]",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token",
                            nil];
    return [self postPath:path
              withParams:params
                  target:delegate
                selector:@selector(didCreateUser:)
                 rootKey:@"user"
                 context:@"local-sso"];
}

+ (id)findOrCreateWithSsoToken:(NSString *)aToken delegate:(id)delegate {
    NSString *path = [self apiPath:@"/users/find_or_create.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            aToken, @"sso",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token",
                            nil];
    return [self postPath:path
               withParams:params
                   target:delegate
                 selector:@selector(didCreateUser:)
                  rootKey:@"user"
                  context:@"sso"];
}

+ (id)forgotPassword:(NSString *)email delegate:(id)delegate {
    NSString *path = [self apiPath:@"/users/forgot_password.json"];
    NSDictionary *params = @{@"user[email]" : email};
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didSendForgotPassword:)
                 rootKey:@"user"];
}

- (id)identify:(NSString *)externalId withScope:(NSString *)externalScope delegate:(id)delegate {
    NSString *path = [UVUser apiPath:@"/users/identify.json"];
    NSDictionary *payload = @{
        @"external_scope" : externalScope,
        @"upsert" : [NSNumber numberWithBool:TRUE],
        @"identifications" : @[
            @{
                @"id" : [NSString stringWithFormat:@"%d", self.userId],
                @"external_id" : externalId
            }
        ]
    };
    
    return [[self class] putPath:path
                        withJSON:payload
                          target:delegate
                        selector:@selector(didIdentifyUser:)
                         rootKey:@"identifications"];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.userId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.name = [[self objectOrNilForDict:dict key:@"name"] stringByDecodingHTMLEntities];
        self.displayName = [self objectOrNilForDict:dict key:@"name"];
        self.email = [self objectOrNilForDict:dict key:@"email"];
        self.ideaScore = [(NSNumber *)[dict objectForKey:@"idea_score"] integerValue];
        self.activityScore = [(NSNumber *)[dict objectForKey:@"activity_score"] integerValue];
        self.karmaScore = [(NSNumber *)[dict objectForKey:@"karma_score"] integerValue];
        self.url = [self objectOrNilForDict:dict key:@"url"];
        self.avatarUrl = [self objectOrNilForDict:dict key:@"avatar_url"];
        self.createdAt = [self parseJsonDate:[dict objectForKey:@"created_at"]];
        createdSuggestionsCount = [(NSNumber *)[dict objectForKey:@"created_suggestions_count"] integerValue];
        supportedSuggestionsCount = [(NSNumber *)[dict objectForKey:@"supported_suggestions_count"] integerValue];

        if (createdSuggestionsCount+supportedSuggestionsCount==0) {
            // no point checking if nothing to get
            self.suggestionsNeedReload = NO;
        } else {
            // otherwise load suggestions if profile is visited
            self.suggestionsNeedReload = YES;
        }
        self.createdSuggestions = [NSMutableArray array];
        self.supportedSuggestions = [NSMutableArray array];
        
        self.visibleForumsDict = [self objectOrNilForDict:dict key:@"visible_forums"];
        if ([UVSession currentSession].clientConfig.forum)
          [self updateVotesRemaining];
    }
    return self;
}

- (void)updateVotesRemaining {
    for (NSDictionary *forum in self.visibleForumsDict) {
        if ([(NSNumber *)[forum valueForKey:@"id"] integerValue] == [UVSession currentSession].clientConfig.forum.forumId) {
            NSDictionary *activity = [self objectOrNilForDict:forum key:@"forum_activity"];
            self.votesRemaining = [(NSNumber *)[activity valueForKey:@"votes_available"] integerValue];
        }
    }
    self.visibleForumsDict = nil;
}

- (NSInteger)supportedSuggestionsCount {
    return suggestionsNeedReload ? supportedSuggestionsCount : [supportedSuggestions count];
}

- (NSInteger)createdSuggestionsCount {
    return suggestionsNeedReload ? createdSuggestionsCount : [createdSuggestions count];
}

- (void)didWithdrawSupportForSuggestion:(UVSuggestion *)suggestion {
    if (suggestionsNeedReload == NO) {
        int i = 0;
        int indexToRemove = -1;
        for (UVSuggestion *it in supportedSuggestions) {
            if (it.suggestionId == suggestion.suggestionId)
                indexToRemove = i;
            i++;
        }
        if (indexToRemove != -1)
            [supportedSuggestions removeObjectAtIndex:indexToRemove];
    } else {
        supportedSuggestionsCount -= 1;
    }
}

- (void)didSupportSuggestion:(UVSuggestion *)suggestion {
    if (suggestionsNeedReload == NO) {
        [supportedSuggestions addObject:suggestion];
    } else {
        supportedSuggestionsCount += 1;
    }
}

- (void)didCreateSuggestion:(UVSuggestion *)suggestion {
    if (suggestionsNeedReload == NO) {
        [supportedSuggestions addObject:suggestion];
        [createdSuggestions addObject:suggestion];
    } else {
        createdSuggestionsCount += 1;
        supportedSuggestionsCount += 1;
    }
}

- (void)didLoadSuggestions:(NSArray *)suggestions {
    [supportedSuggestions removeAllObjects];
    [createdSuggestions removeAllObjects];
    if (suggestions && ![[NSNull null] isEqual:suggestions]) {
        for (UVSuggestion *suggestion in suggestions) {
            [supportedSuggestions addObject:suggestion];
            if (suggestion.creatorId == userId) {
                [createdSuggestions addObject:suggestion];
            }
        }
    }
    suggestionsNeedReload = NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"userId: %d\nname: %@\nemail: %@", self.userId, self.displayName, self.email];
}

- (BOOL)hasEmail {
    return self.email != nil && [self.email length] > 0;
}

- (NSString *)nameOrAnonymous {
    return self.displayName ? self.displayName : NSLocalizedStringFromTable(@"Anonymous", @"UserVoice", nil);
}

- (void)dealloc {
    self.name = nil;
    self.displayName = nil;
    self.email = nil;
    self.url = nil;
    self.avatarUrl = nil;
    self.supportedSuggestions = nil;
    self.createdSuggestions = nil;
    self.createdAt = nil;
    self.visibleForumsDict = nil;
    [super dealloc];
}

@end
