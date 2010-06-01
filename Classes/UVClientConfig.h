//
//  UVClientConfig.h
//  UserVoice
//
//  Created by Mirko Froehlich on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVForum;
@class UVSubdomain;

@interface UVClientConfig : UVBaseModel {
	BOOL questionsEnabled;
	UVForum *forum;
	UVSubdomain *subdomain;
	NSString *welcome;
	NSString *itunesApplicationId;
	NSArray *questions;
}

@property (assign) BOOL questionsEnabled;
@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UVSubdomain *subdomain;
@property (nonatomic, retain) NSString *welcome;
@property (nonatomic, retain) NSString *itunesApplicationId;
@property (nonatomic, retain) NSArray *questions;

+ (id)getWithDelegate:(id)delegate;

@end
