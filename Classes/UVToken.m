//
//  UVToken.m
//  UserVoice
//
//  Created by Scott Rutherford on 16/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVToken.h"
#import "YOAuthToken.h"
#import "UVSession.h"
#import "UVResponseDelegate.h"
#import "UVConfig.h"

@implementation UVToken

@synthesize oauthToken;
@synthesize type;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	
	NSRange range = [[UVSession currentSession].config.site rangeOfString:@".us.com"];
	BOOL useHttps = range.location == NSNotFound; // not pointing to a us.com (aka dev) url => use https
	[self setBaseURL:[self siteURLWithHTTPS:useHttps]];
}

+ (BOOL) exists {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	return [prefs stringForKey:@"uv-iphone-k"] != nil;	
}

- (void)remove {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs removeObjectForKey:@"uv-iphone-k"];
	[prefs removeObjectForKey:@"uv-iphone-s"];
	[prefs synchronize];
}

- (id)revoke:(id) delegate {
	NSString *path = [UVToken apiPath:[NSString stringWithFormat:@"/oauth/revoke.json"]];
	
	return [[self class] getPath:path
					  withParams:nil
						  target:delegate
						selector:@selector(didRevokeToken:)];
}

// check to see if a token exists on the device and if so load it
// if not get a request token from the api
- (id)initWithExisting {
//	NSLog(@"Loading existing token");
	// existing token, load it
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//	NSLog(@"Loaded access token key: %@ secret: %@", 
//		  [prefs stringForKey:@"uv-iphone-k"], [prefs stringForKey:@"uv-iphone-s"]);
	
	return [self initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
									 [prefs stringForKey:@"uv-iphone-k"], @"oauth_token", 
									 [prefs stringForKey:@"uv-iphone-s"], @"oauth_token_secret", nil]];
}

+ (id)getRequestTokenWithDelegate:(id)delegate {
	NSString *path = [[self class] apiPath:[NSString stringWithFormat:@"/oauth/request_token.json"]];

//	NSLog(@"Requesting request token");
	return [self getPath:path
			  withParams:nil
				  target:delegate
				selector:@selector(didRetrieveRequestToken:)];
}

+ (id)getAccessTokenWithDelegate:(id)delegate andEmail:(NSString *)email andPassword:(NSString *)password {
	NSString *path = [[self class] apiPath:[NSString stringWithFormat:@"/oauth/authorize.json"]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							password, @"password",
							email, @"email", 
							[UVSession currentSession].currentToken.oauthToken.key, @"request_token", nil];
	
	return [self getPath:path
			  withParams:params
				  target:delegate
				selector:@selector(didRetrieveAccessToken:)];
}

// save token
- (void)persist {
//	NSLog(@"Persisting token");	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:self.oauthToken.key forKey:@"uv-iphone-k"];
	[prefs setObject:self.oauthToken.secret forKey:@"uv-iphone-s"];
	[prefs synchronize];
}

- (id)initWithDictionary:(NSDictionary *)dict {			
	if (self = [super init]) {
		self.oauthToken = [YOAuthToken tokenWithDictionary:dict];
	}
	return self;	
}

- (void)dealloc {
	self.oauthToken = nil;
    self.type = nil;
	[super dealloc];
}

@end
