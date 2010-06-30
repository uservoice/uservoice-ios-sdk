//
//  UVBaseModel.h
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRiot.h"

@interface UVBaseModel : HRRestModel {

}

+ (NSURL *)siteURLWithHTTPS:(BOOL)https;
+ (NSURL *)siteURL;
+ (NSString *)apiPrefix;
+ (NSString *)apiPath:(NSString *)path;

// Perform a GET, POST, and PUT respectively
+ (id)getPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
+ (id)postPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;
+ (id)putPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector;

// Exposed for subclasses that need to implement their own requests
+ (NSMutableDictionary *)headersForPath:(NSString *)path params:(NSDictionary *)params method:(NSString *)method;

// Override in subclasses if neccessary
+ (void)processModel:(id)model;
+ (void)processModels:(NSArray *)models;

// Processes the returned model(s) and invokes the specified callback. Should not
// need to be overridden in subclasses. Override processModel(s) instead.
+ (void)didReturnModel:(id)model callback:(NSInvocation *)callback;
+ (void)didReturnModels:(NSArray *)models callback:(NSInvocation *)callback;

// Any of the different types of HTTPRiot errors result in this method being
// called. Invokes the didReceiveError: selector on the callback target. Can be
// overridden in subclasses that need more specific error handling.
+ (void)didReceiveError:(NSError *)error callback:(NSInvocation *)callback;

// Should be overriden in subclasses to populate themselves based on the
// returned resource.
- (id)initWithDictionary:(NSDictionary *)dict;

// Returns the dictionary object for the specified key, or nil if it does not
// exist or is NSNull.
- (id)objectOrNilForDict:(NSDictionary *)dict key:(id)key;

// Parses an ISO-8601 date string (as returned by our Rails apps) into an NSDate.
- (NSDate *)parseJsonDate:(NSString *)str;


@end
