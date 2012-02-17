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
	BOOL ticketsEnabled;
	UVForum *forum;
	UVSubdomain *subdomain;
	NSArray *customFields;
}

@property (assign) BOOL ticketsEnabled;
@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UVSubdomain *subdomain;
@property (nonatomic, retain) NSArray *customFields;

+ (id)getWithDelegate:(id)delegate;
+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;
+ (UIDeviceOrientation)getOrientation;
+ (void)setOrientation;

@end
