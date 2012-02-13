//
//  UVResponseDelegate.m
//  UserVoice
//
//  Created by UserVoice on 10/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVResponseDelegate.h"
#import "UVBaseModel.h"
#import "UVToken.h"
#import "UVSession.h"
#import "UVCustomField.h"

@implementation UVResponseDelegate

@synthesize modelClass;

- (id)initWithModelClass:(Class)clazz {
	if (self = [super init]) {
		self.modelClass = clazz;
	}
	return self;
}

- (UVBaseModel *)modelForDictionary:(NSDictionary *)dict {
	UVBaseModel *model = [[[self.modelClass alloc] initWithDictionary:dict] autorelease];
	//NSLog(@"Unmarshaled model: %@", model);
	return model;
}

#pragma mark - HRResponseDelegate Methods

- (void)restConnection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response object:(id)object {
	//NSLog(@"DidReceiveResponse: %@", response);
	//HttpRiot ignores the status code if a JSON body is present and sends didReturnResource"
	statusCode = [response statusCode];
}

- (void)restConnection:(NSURLConnection *)connection didReturnResource:(id)resource object:(id)object {
	//NSLog(@"didReturnResource: %@", resource);

	if (statusCode >= 400) {
		NSDictionary *userInfo = nil;

        if ([resource respondsToSelector:@selector(objectForKey:)])
            userInfo = [resource objectForKey:@"errors"];
		
		NSError *error = [NSError errorWithDomain:@"uservoice" code:statusCode userInfo:userInfo];
		[modelClass didReceiveError:error callback:object];
		
	} else {
		// here we get one root node of the response class (response node has been removed for JSON)
		if ([resource respondsToSelector:@selector(objectForKey:)]) {	
			NSMutableDictionary *mutableResource = (NSMutableDictionary *) resource;
			// now remove the responseData node
			[mutableResource removeObjectForKey:@"response_data"];
						
			NSArray *nodes = [mutableResource allKeys];						
			if ([nodes count] > 1) {
				// aggregate returned
				NSLog(@"Aggregate %@", nodes);
				
				// also check for any tokens returned and set a current on session
				// we will not persist them here though leave that to the calling controller
				// only really useful for user creation and this SUCKS, refactor
				NSDictionary *token = [mutableResource objectForKey:@"token"];
				[mutableResource removeObjectForKey:@"token"];
				[UVSession currentSession].currentToken = [[[UVToken alloc] initWithDictionary:token] autorelease];				
			}
			// reload keys
			nodes = [mutableResource allKeys];
			
			// ok finished buggering about with aggregate responses, should be good to go
			if ([[mutableResource objectForKey:[nodes objectAtIndex:0]] isKindOfClass:[NSArray class]]) { 
				NSMutableArray *models = [NSMutableArray array];
				for (id item in [mutableResource objectForKey:[nodes objectAtIndex:0]]) {
					[models addObject:[self modelForDictionary:item]];
				}
				[modelClass didReturnModels:models callback:object];
				
			} else {
				NSDictionary *dict = [mutableResource objectForKey:[nodes objectAtIndex:0]];
				
				[modelClass didReturnModel:[self modelForDictionary:dict] callback:object];
			}
		}
	}
}

- (void)restConnection:(NSURLConnection *)connection didFailWithError:(NSError *)error object:(id)object {
	// Handle connection errors.  Failures to connect to the server, etc.
	NSLog(@"Error (HTTP connection failed): %@", error);
	[modelClass didReceiveError:error callback:object];
}

- (void)restConnection:(NSURLConnection *)connection didReceiveParseError:(NSError *)error responseBody:(NSString *)string object:(id)object {
	// Request was successful, but couldn't parse the data returned by the server. 
	NSLog(@"Error parsing response: %@", error);
	NSLog(@"Response Body: %@\n", string);
	[modelClass didReceiveError:error callback:object];
}

@end
