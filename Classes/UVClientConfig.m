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
#import "UVUser.h"
#import "UVSubdomain.h"
#import "UVCustomField.h"
#import "UVSuggestion.h"
#import "UVArticle.h"
#import "UVConfig.h"

@implementation UVClientConfig

@synthesize ticketsEnabled;
@synthesize feedbackEnabled;
@synthesize subdomain;
@synthesize customFields;
@synthesize clientId;
@synthesize whiteLabel;
@synthesize defaultForumId;
@synthesize key;
@synthesize secret;

+ (id)getWithDelegate:(id)delegate {
    NSString *path = ([UVSession currentSession].config.key == nil) ? @"/clients/default.json" : @"/client.json";
    return [self getPath:[self apiPath:path]
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveClientConfig:)
                 rootKey:@"client"];
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

        NSDictionary *subdomainDict = [self objectOrNilForDict:dict key:@"subdomain"];
        UVSubdomain *theSubdomain = [[UVSubdomain alloc] initWithDictionary:subdomainDict];
        self.subdomain = theSubdomain;
        [theSubdomain release];

        self.defaultForumId = [[[self objectOrNilForDict:dict key:@"forum"] objectForKey:@"id"] intValue];
        self.customFields = [self arrayForJSONArray:[self objectOrNilForDict:dict key:@"custom_fields"] withClass:[UVCustomField class]];
        self.clientId = [(NSNumber *)[self objectOrNilForDict:dict key:@"id"] integerValue];
        self.key = [self objectOrNilForDict:dict key:@"key"];
        // secret is only available if we are using the default client
        self.secret = [self objectOrNilForDict:dict key:@"secret"];
    }
    return self;
}

- (void)dealloc {
    self.subdomain = nil;
    self.customFields = nil;
    self.key = nil;
    self.secret = nil;
    [super dealloc];
}

@end
