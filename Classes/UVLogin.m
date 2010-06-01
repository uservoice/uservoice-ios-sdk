//
//  UVLogin.m
//  UserVoice
//
//  Created by Mirko Froehlich on 10/26/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <CommonCrypto/CommonDigest.h>
//#import "UVLogin.h"
//#import "UVResponseDelegate.h"
//#import "UVSession.h"
//#import "UVUser.h"
//#import "UVConfig.h"
//#import "YOAuth.h"
//
//@implementation UVLogin
//
//@synthesize user;
//@synthesize token;
//
//+ (void)initialize {
//	[self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
//	NSRange range = [[UVSession currentSession].config.site rangeOfString:@".us.com"];
//	BOOL useHttps = range.location == NSNotFound; // not pointing to a us.com (aka dev) url => use https
//	//BOOL useHttps = NO;
//	[self setBaseURL:[self siteURLWithHTTPS:useHttps]];
//}
//
//// Calculates a SHA1 digest.
//+ (NSString *)sha1:(NSString *)str {
//	const char *cStr = [str UTF8String];
//	unsigned char result[CC_SHA1_DIGEST_LENGTH];
//	CC_SHA1(cStr, strlen(cStr), result);
//	NSString *shaStr = [NSString  stringWithFormat:
//						@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//						result[0], result[1], result[2], result[3],
//						result[4], result[5], result[6], result[7],
//						result[8], result[9], result[10], result[11],
//						result[12], result[13], result[14], result[15],
//						result[16], result[17], result[18], result[19]];
//	return [shaStr lowercaseString];
//}
//
//// Returns a UUID that uniquely identifies the device. Rather than the actual UDID,
//// we are generating an MD5 digest, to remain compliant with Apple's guidelines.
//+ (NSString *)uuid {
//	static NSString *salt = @"UserVoice iPhone SDK";
//	NSString *str = [salt stringByAppendingString:[UIDevice currentDevice].uniqueIdentifier];
//	return [self sha1:str];
//}
//
//+ (id)loginWithDelegate:(id)delegate {
//	NSDictionary *params = [NSDictionary dictionaryWithObject:[self uuid] forKey:@"identifier"];
//	return [self getPath:[self iPhoneApiPath:@"/connect.json"]
//			  withParams:params
//				  target:delegate
//				selector:@selector(didLogin)];
//}
//
//+ (NSURLRequest *)editRequest {
//	NSString *path = [self iPhoneApiPath:@"/users/edit"];
//	NSDictionary *headers = [self headersForPath:path params:nil method:@"GET"];
//	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self siteURL], path]];
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//	[request setAllHTTPHeaderFields:headers];
//
//	return request;
//}
//
//+ (void)processModel:(id)model {
//	UVLogin *login = (UVLogin *)model;
//	[UVSession currentSession].user = login.user;
//	[UVSession currentSession].currentToken = login.token;
//}
//
//- (id)initWithDictionary:(NSDictionary *)dict {
//	if (self = [super init]) {
//		self.user = [[[UVUser alloc] initWithDictionary:[dict objectForKey:@"user"]] autorelease];
//		self.token = [YOAuthToken tokenWithDictionary:[dict objectForKey:@"access_token"]];
//	}
//	return self;
//}
//
//@end
