//
//  UVBaseModel.m
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "YOAuth.h"
#import "UVBaseModel.h"
#import "UVConfig.h"
#import "UVSession.h"
#import "UVToken.h"
#import "YOAuthToken.h"

@implementation UVBaseModel

+ (NSURL *)siteURLWithHTTPS:(BOOL)https {
	UVConfig *config = [UVSession currentSession].config;
	NSString *protocol = https ? @"https" : @"http";
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", protocol, config.site]];
}

+ (NSURL *)siteURL {
	return [self siteURLWithHTTPS:NO];
}

+ (NSString *)apiPrefix {
	return @"/api/v1";
}

+ (NSString *)apiPath:(NSString *)path {
	return [[self apiPrefix] stringByAppendingString:path];
}

+ (NSMutableDictionary *)headersForPath:(NSString *)path params:(NSDictionary *)params method:(NSString *)method {
	NSMutableDictionary *headers = [NSMutableDictionary dictionary];

	// Contrary to the docs, HTTPRiot doesn't automatically set the right content
	// type for (form-encoded) HTTP POST requests. Also note that we can't send
	// json or xml data, because the current OAuth spec only covers form-encoded
	// HTTP bodies. A new draft spec is trying to change this:
	// http://oauth.googlecode.com/svn/spec/ext/body_hash/1.0/drafts/3/spec.html
	// Last not least, our production server seems to have an issue with GET requests
	// without a content type, even though it should be irrelevant for GET.
	[headers setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [headers setObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"Accept-Language"];
	YOAuthToken *token = nil;
	
	// only store access tokens
	if ([UVToken exists]) {
		token = [UVSession currentSession].currentToken.oauthToken;
	}
	NSURL *url = [NSURL URLWithString:path relativeToURL:[self baseURL]];
	YOAuthRequest *yReq = [[YOAuthRequest alloc] initWithConsumer:[[UVSession currentSession] yOAuthConsumer]
														   andUrl:url
													andHTTPMethod:method
														 andToken:token
											   andSignatureMethod:nil];
	if (![@"PUT" isEqualToString:method])
		yReq.requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
	[yReq prepareRequest];
	NSString *authHeader = [yReq buildAuthorizationHeaderValue];
	[headers setObject:authHeader forKey:@"Authorization"];
	[yReq release];
	
	return headers;
}

+ (NSDictionary *)optionsForPath:(NSString *)path params:(NSDictionary *)params method:(NSString *)method {
	if (!params) {
		params = [NSDictionary dictionary];
	}
	
	NSMutableDictionary *headers = [self headersForPath:path params:params method:method];
	// Below is a workaround for HTTPRiot. According to the docs, it accepts HTTP
	// POST params in the "params" option and automatically sets the proper content
	// type in that case. In practice, we need to manually set the content type
	// (see headersForPath above) and pass the params in the "body" param.
	NSString *paramsKey = [@"GET" isEqualToString:method] ? @"params" : @"body";
	NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:params, paramsKey, headers, @"headers", nil];
	return opts;
}

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector {
	NSMethodSignature *sig = [target methodSignatureForSelector:selector];
	NSInvocation *callback = [NSInvocation invocationWithMethodSignature:sig];
	[callback setTarget:target];
	[callback setSelector:selector];
	[callback retainArguments];
	return callback;
}

+ (id)getPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector {
	NSInvocation *callback = [self invocationWithTarget:target selector:selector];
	NSDictionary *opts = [self optionsForPath:path params:params method:@"GET"];
	return [self getPath:path withOptions:opts object:callback];
}

+ (id)postPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector {
	NSInvocation *callback = [self invocationWithTarget:target selector:selector];
	NSDictionary *opts = [self optionsForPath:path params:params method:@"POST"];
	return [self postPath:path withOptions:opts object:callback];
}

+ (id)putPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector {
	NSInvocation *callback = [self invocationWithTarget:target selector:selector];
	NSDictionary *opts = [self optionsForPath:path params:params method:@"PUT"];
	return [self putPath:path withOptions:opts object:callback];
}

+ (void)processModel:(id)model {
	// Override in subclasses if necessary
}

+ (void)processModels:(NSArray *)models {
	// Override in subclasses if necessary
}

+ (void)didReturnModel:(id)model callback:(NSInvocation *)callback {
	[self processModel:model];
	
	if (callback.methodSignature.numberOfArguments > 2) {
		[callback setArgument:&model atIndex:2];
	}
	[callback invoke];
}

+ (void)didReturnModels:(NSArray *)models callback:(NSInvocation *)callback {
	[self processModels:models];
	
	if (callback.methodSignature.numberOfArguments > 2) {
		[callback setArgument:&models atIndex:2];
	}
	[callback invoke];
}

+ (void)didReceiveError:(NSError *)error callback:(NSInvocation *)callback {
	NSLog(@"[UVBaseModel didReceiveError]: %@", error);
	[callback.target performSelector:@selector(didReceiveError:) withObject:error];
}

- (id)initWithDictionary:(NSDictionary *)dict {
	return [super init];
}

- (id)objectOrNilForDict:(NSDictionary *)dict key:(id)key {
	id object = [dict objectForKey:key];
	if ([[NSNull null] isEqual:object]) {
		object = nil;
	}
	return object;
}

- (NSDate *)parseJsonDate:(NSString *)str {
	NSDate *date;

	@synchronized(self) {
		static NSDateFormatter* jsonDateFormatter = nil;
		if (!jsonDateFormatter) {
			jsonDateFormatter = [[NSDateFormatter alloc] init];
			[jsonDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss zzzzz"];
		}
		date = [jsonDateFormatter dateFromString:str];
	}
	
	return date;
}

@end
