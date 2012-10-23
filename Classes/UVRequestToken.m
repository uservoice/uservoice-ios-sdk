//
//  UVRequestToken.m
//  UserVoice
//
//  Created by Austin Taylor on 10/23/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVRequestToken.h"
#import "YOAuthToken.h"
#import "UVResponseDelegate.h"
#import "UVSession.h"
#import "UVConfig.h"

@implementation UVRequestToken

@synthesize oauthToken;

+ (void)initialize {
    [self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
    
    NSRange range = [[UVSession currentSession].config.site rangeOfString:@".us.com"];
    BOOL useHttps = range.location == NSNotFound; // not pointing to a us.com (aka dev) url => use https
    [self setBaseURL:[self siteURLWithHTTPS:useHttps]];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.oauthToken = [YOAuthToken tokenWithDictionary:dict];
    }
    return self;
}

+ (id)getRequestTokenWithDelegate:(id)delegate {
    NSString *path = [[self class] apiPath:[NSString stringWithFormat:@"/oauth/request_token.json"]];
    
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveRequestToken:)];
}

@end