//
//  UVConfig.h
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVConfig : NSObject {
	NSString *site;
	NSString *key;
	NSString *secret;
}

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret;

@end
