//
//  UVDeflection.m
//  UserVoice
//
//  Created by Austin Taylor on 9/19/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVDeflection.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVBabayaga.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSubdomain.h"

@implementation UVDeflection

static NSString *searchText;
static NSInteger interactionIdentifier;

+ (void)trackDeflection:(NSString *)kind deflectingType:(NSString *)deflectingType deflector:(UVBaseModel *)model {
    NSMutableDictionary *params = [self deflectionParams];
    [params setObject:kind forKey:@"kind"];
    [params setObject:deflectingType forKey:@"deflecting_type"];
    if ([model isKindOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        [params setObject:@"Faq" forKey:@"deflector_type"];
        [params setObject:[NSString stringWithFormat:@"%d", article.articleId] forKey:@"deflector_id"];
    } else if ([model isKindOfClass:[UVSuggestion class]]) {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        [params setObject:@"Suggestion" forKey:@"deflector_type"];
        [params setObject:[NSString stringWithFormat:@"%d", suggestion.suggestionId] forKey:@"deflector_id"];
    }
    [self sendDeflection:@"/clients/widgets/omnibox/deflections/upsert.json" params:params];
}

+ (void)trackSearchDeflection:(NSArray *)results deflectingType:(NSString *)deflectingType {
    NSMutableDictionary *params = [self deflectionParams];
    [params setObject:@"list" forKey:@"kind"];
    [params setObject:deflectingType forKey:@"deflecting_type"];
    if ([results count] == 0) {
        [params setObject:@"true" forKey:@"no_results"];
    } else {
        NSMutableArray *resultHashes = [NSMutableArray array];
        int index = 0;
        for (id model in results) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [result setObject:[NSString stringWithFormat:@"%d", index++] forKey:@"position"];
            [result setObject:[NSString stringWithFormat:@"%d", [model weight]] forKey:@"weight"];
            if ([model isKindOfClass:[UVArticle class]]) {
                UVArticle *article = (UVArticle *)model;
                [result setObject:[NSString stringWithFormat:@"%d", article.articleId] forKey:@"deflector_id"];
                [result setObject:@"Faq" forKey:@"deflector_type"];
            } else if ([model isKindOfClass:[UVSuggestion class]]) {
                UVSuggestion *suggestion = (UVSuggestion *)model;
                [result setObject:[NSString stringWithFormat:@"%d", suggestion.suggestionId] forKey:@"deflector_id"];
                [result setObject:@"Suggestion" forKey:@"deflector_type"];
            }
            [resultHashes addObject:result];
        }
        [params setObject:resultHashes forKey:@"results[]"];
    }
    [self sendDeflection:@"/clients/widgets/omnibox/deflections/list_view.json" params:params];
}

+ (void)setSearchText:(NSString *)query {
    if ([query isEqualToString:searchText]) return;
    [searchText release];
    searchText = [query retain];
    interactionIdentifier = [self interactionIdentifier] + 1;
}

+ (void)sendDeflection:(NSString *)path params:(NSDictionary *)params {
    NSDictionary *opts = @{
        kHRClassAttributesBaseURLKey  : [UVBaseModel baseURL],
        kHRClassAttributesDelegateKey : [NSValue valueWithNonretainedObject:self],
        @"params" : params
    };
    [HRRequestOperation requestWithMethod:HRRequestMethodGet path:path options:opts object:nil];
}

+ (NSInteger)interactionIdentifier {
    if (!interactionIdentifier) {
        interactionIdentifier = [[[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] substringFromIndex:4] integerValue];
    }
    return interactionIdentifier;
}

+ (NSMutableDictionary *)deflectionParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[UVBabayaga instance].uvts forKey:@"uvts"];
    [params setObject:@"ios" forKey:@"channel"];
    [params setObject:searchText forKey:@"search_term"];
    [params setObject:[NSString stringWithFormat:@"%d", [self interactionIdentifier]] forKey:@"interaction_identifier"];
    [params setObject:[NSString stringWithFormat:@"%d", [UVSession currentSession].clientConfig.subdomain.subdomainId] forKey:@"subdomain_id"];
    return params;
}

@end
