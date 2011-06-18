//
//  UVClientConfig.h
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "UVBaseModel.h"

@class UVForum;
@class UVSubdomain;

@interface UVClientConfig : UVBaseModel {
	BOOL questionsEnabled, ticketsEnabled;
	UVForum *forum;
	UVSubdomain *subdomain;
	NSString *welcome;
	NSString *itunesApplicationId;
	NSArray *questions;
	NSArray *ticketSubjects;
}

@property (assign) BOOL questionsEnabled, ticketsEnabled;
@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UVSubdomain *subdomain;
@property (nonatomic, retain) NSString *welcome;
@property (nonatomic, retain) NSString *itunesApplicationId;
@property (nonatomic, retain) NSArray *questions;
@property (nonatomic, retain) NSArray *ticketSubjects;

+ (id)getWithDelegate:(id)delegate;
+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;
+ (UIDeviceOrientation)getOrientation;
+ (void)setOrientation;

@end
