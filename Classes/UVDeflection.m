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

@implementation UVDeflection

static NSString *searchText;
static NSInteger interactionIdentifier;

+ (void)trackDeflection:(NSString *)kind deflector:(UVBaseModel *)model {
    NSMutableDictionary *params = [self deflectionParams];
    [params setObject:kind forKey:@"kind"];
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

+ (void)trackSearchDeflection:(NSArray *)results {
    NSMutableDictionary *params = [self deflectionParams];
    [params setObject:@"list" forKey:@"kind"];
    NSMutableArray *articleIds = [NSMutableArray array];
    NSMutableArray *suggestionIds = [NSMutableArray array];
    for (id model in results) {
        if ([model isKindOfClass:[UVArticle class]]) {
            UVArticle *article = (UVArticle *)model;
            [articleIds addObject:[NSString stringWithFormat:@"%d", article.articleId]];
        } else if ([model isKindOfClass:[UVSuggestion class]]) {
            UVSuggestion *suggestion = (UVSuggestion *)model;
            [suggestionIds addObject:[NSString stringWithFormat:@"%d", suggestion.suggestionId]];
        }
    }
    [params setObject:articleIds forKey:@"faq_ids[]"];
    [params setObject:suggestionIds forKey:@"suggestion_ids[]"];
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
    return params;
}

@end
