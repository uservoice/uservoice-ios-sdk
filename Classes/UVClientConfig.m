//
//  UVClientConfig.m
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "HTTPRiot.h"
#import "UVClientConfig.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVUser.h"
#import "UVSubdomain.h"
#import "UVCustomField.h"
#import "UVSuggestion.h"
#import "UVArticle.h"

@implementation UVClientConfig

@synthesize ticketsEnabled;
@synthesize feedbackEnabled;
@synthesize forum;
@synthesize subdomain;
@synthesize customFields;
@synthesize topArticles;
@synthesize topSuggestions;
@synthesize clientId;
@synthesize whiteLabel;

+ (id)getWithDelegate:(id)delegate {
    return [self getPath:[self apiPath:@"/client.json"]
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveClientConfig:)
                 rootKey:@"client"];
}

+ (void)processModel:(id)model {
    [UVSession currentSession].clientConfig = model;
}

+ (CGFloat)getScreenWidth {
    UIViewController *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
    return root.presentedViewController.view.bounds.size.width;
}

+ (CGFloat)getScreenHeight {
    UIViewController *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
    return root.presentedViewController.view.bounds.size.height;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        if ([dict objectForKey:@"tickets_enabled"] != [NSNull null]) {
            self.ticketsEnabled = [(NSNumber *)[dict objectForKey:@"tickets_enabled"] boolValue];
        }
        if ([dict objectForKey:@"feedback_enabled"] != [NSNull null]) {
            self.feedbackEnabled = [(NSNumber *)[dict objectForKey:@"feedback_enabled"] boolValue];
        }
        if ([dict objectForKey:@"white_label"] != [NSNull null]) {
            self.whiteLabel = [(NSNumber *)[dict objectForKey:@"white_label"] boolValue];
        }

        if (feedbackEnabled) {
            // get the forum
            NSDictionary *forumDict = [self objectOrNilForDict:dict key:@"forum"];
            UVForum *theForum = [[UVForum alloc] initWithDictionary:forumDict];
            self.forum = theForum;
            [theForum release];
        }

        // get the subdomain
        NSDictionary *subdomainDict = [self objectOrNilForDict:dict key:@"subdomain"];
        UVSubdomain *theSubdomain = [[UVSubdomain alloc] initWithDictionary:subdomainDict];
        self.subdomain = theSubdomain;
        [theSubdomain release];

        self.customFields = [self arrayForJSONArray:[self objectOrNilForDict:dict key:@"custom_fields"] withClass:[UVCustomField class]];
        self.topArticles = [self arrayForJSONArray:[self objectOrNilForDict:dict key:@"top_articles"] withClass:[UVArticle class]];
        self.topSuggestions = [self arrayForJSONArray:[self objectOrNilForDict:dict key:@"top_suggestions"] withClass:[UVSuggestion class]];
        self.clientId = [(NSNumber *)[self objectOrNilForDict:dict key:@"id"] integerValue];
    }
    return self;
}

- (void)dealloc {
    self.forum = nil;
    self.subdomain = nil;
    self.customFields = nil;
    self.topArticles = nil;
    self.topSuggestions = nil;
    [super dealloc];
}

@end
