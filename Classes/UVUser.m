//
//  UVUser.m
//  UserVoice
//
//  Created by Mirko Froehlich on 10/26/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVUser.h"
#import "UVResponseDelegate.h"
#import "UVSuggestion.h"
#import "UVSession.h"
#import "UVToken.h"
#import "YOAuthToken.h"

@implementation UVUser

@synthesize userId;
@synthesize name;
@synthesize displayName;
@synthesize email;
@synthesize emailConfirmed;
@synthesize ideaScore;
@synthesize activityScore;
@synthesize karmaScore;
@synthesize url;
@synthesize avatarUrl;
@synthesize supportedSuggestions;
@synthesize createdSuggestions;
@synthesize supportedSuggestionsCount;
@synthesize createdSuggestionsCount;
@synthesize createdAt;
@synthesize suggestionsNeedReload;

+ (void)initialize {
	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
	[self setBaseURL:[self siteURL]];
}

+ (id)getWithUserId:(NSInteger)userId delegate:(id)delegate {
	NSString *key = [NSString stringWithFormat:@"%d", userId];
	NSLog(@"Checking cache for user with id: %@", key);
	id cachedUser = [[UVSession currentSession].userCache objectForKey:key];
	NSLog(@"Cache returned: %@", cachedUser);
	
	if (cachedUser && ![[NSNull null] isEqual:cachedUser]) {
		// gonna fake the call and pass the cached user back to the selector
		NSMethodSignature *sig = [delegate methodSignatureForSelector:@selector(didRetrieveUser:)];
		NSInvocation *callback = [[NSInvocation invocationWithMethodSignature:sig] retain];
		[callback setTarget:delegate];
		[callback setSelector:@selector(didRetrieveUser:)];
		[callback retainArguments];
		
		[UVUser didReturnModel:cachedUser callback:callback];
		return cachedUser;
		
	} else {
		NSString *path = [self apiPath:[NSString stringWithFormat:@"/users/%d.json", userId]];
		return [self getPath:path
				  withParams:nil
					  target:delegate
					selector:@selector(didRetrieveUser:)];
	}
}

+ (id)discoverWithEmail:(NSString *)email delegate:(id)delegate {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/users/discover.json?email=%@", email]];
	return [self getPath:path
			  withParams:nil
				  target:delegate
				selector:@selector(didDiscoverUser:)];
}

+ (id)discoverWithGUID:(NSString *)guid delegate:(id)delegate {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/users/discover.json?guid=%@", guid]];
	return [self getPath:path
			  withParams:nil
				  target:delegate
				selector:@selector(didDiscoverUser:)];
}

+ (id)retrieveCurrentUser:(id)delegate {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/users/current.json"]];
	return [self getPath:path
			  withParams:nil
				  target:delegate
				selector:@selector(didRetrieveCurrentUser:)];
}

// only called when instigated by the user, creates a local user
+ (id)createWithEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id)delegate {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/users.json"]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							aName == nil ? @"" : aName, @"user[display_name]",
							anEmail == nil ? @"" : anEmail, @"user[email]", 
							[UVSession currentSession].currentToken.oauthToken.key, @"request_token",
							nil];
	return [self postPath:path
			   withParams:params
				   target:delegate
				 selector:@selector(didCreateUser:)];
}

+ (id)createWithGUID:(NSString *)guid andEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id)delegate {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/users.json"]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							aName == nil ? @"" : aName, @"user[display_name]",
							anEmail == nil ? @"" : anEmail, @"user[email]", 
							[UVSession currentSession].currentToken.oauthToken.key, @"request_token",
							nil];
	return [self postPath:path
			  withParams:params
				  target:delegate
				selector:@selector(didCreateUser:)];
}

+ (id)createWithSsoToken:(NSString *)token andDelegate:(id)delegate {
	NSString *path = [self apiPath:[NSString stringWithFormat:@"/users.json"]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							token == nil ? @"" : token, @"sso", 
							[UVSession currentSession].currentToken.oauthToken.key, @"request_token",
							nil];
	return [self postPath:path
			  withParams:params
				  target:delegate
				selector:@selector(didCreateUser:)];
}

+ (void)processModel:(id)model {
	// add to the cache
	UVUser *user = model;
	NSString *key = [NSString stringWithFormat:@"%d", user.userId];
	
	if ([[UVSession currentSession].userCache objectForKey:key]==nil) {
		NSLog(@"Adding user to cache [%@]: %@", key, model);
		[[UVSession currentSession].userCache setObject:model forKey:key];
	}
}

- (id)updateName:(NSString *)newName email:(NSString *)newEmail delegate:(id)delegate {
	NSString *path = [UVUser apiPath:[NSString stringWithFormat:@"/users/%d.json",
									  [UVSession currentSession].user.userId]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							newName == nil ? @"" : newName, @"user[display_name]",
							newEmail == nil ? @"" : newEmail, @"user[email]",
							nil];
	return [[self class] putPath:path
					  withParams:params
						  target:delegate
						selector:@selector(didUpdateUser:)];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.userId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
		self.name = [self objectOrNilForDict:dict key:@"name"];
		self.displayName = [self objectOrNilForDict:dict key:@"name"];
		self.email = [self objectOrNilForDict:dict key:@"email"];
		self.emailConfirmed = [(NSNumber *)[dict objectForKey:@"email_confirmed"] boolValue];
		self.ideaScore = [(NSNumber *)[dict objectForKey:@"idea_score"] integerValue];
		self.activityScore = [(NSNumber *)[dict objectForKey:@"activity_score"] integerValue];
		self.karmaScore = [(NSNumber *)[dict objectForKey:@"karma_score"] integerValue];
		self.url = [self objectOrNilForDict:dict key:@"url"];
		self.avatarUrl = [self objectOrNilForDict:dict key:@"avatar_url"];
		self.createdAt = [self parseJsonDate:[dict objectForKey:@"created_at"]];
		self.createdSuggestionsCount = [(NSNumber *)[dict objectForKey:@"created_suggestions_count"] integerValue];
		self.supportedSuggestionsCount = [(NSNumber *)[dict objectForKey:@"supported_suggestions_count"] integerValue];
		
		if (self.createdSuggestionsCount+self.supportedSuggestionsCount==0) {
			// no point checking if nothing to get
			self.suggestionsNeedReload = NO;
		} else {			
			// otherwise load suggestions if profile is visited
			self.suggestionsNeedReload = YES;
		}
		self.createdSuggestions = [NSMutableArray array];
		self.supportedSuggestions = [NSMutableArray array];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"userId: %d\nname: %@\nemail: %@", self.userId, self.displayName, self.email];
}

- (BOOL)hasEmail {
	return self.email != nil && [self.email length] > 0;
}

- (BOOL)hasConfirmedEmail {
	return [self hasEmail] && self.emailConfirmed;
}

- (BOOL)hasUnconfirmedEmail {
	return [self hasEmail] && !self.emailConfirmed;
}

- (NSString *)nameOrAnonymous {
	return self.displayName ? self.displayName : @"Anonymous";
}

@end
