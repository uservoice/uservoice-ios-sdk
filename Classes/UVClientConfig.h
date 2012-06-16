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
    BOOL feedbackEnabled;
	UVForum *forum;
	UVSubdomain *subdomain;
	NSArray *customFields;
    NSArray *topArticles;
    NSArray *topSuggestions;
    NSInteger clientId;
}

@property (assign) BOOL ticketsEnabled;
@property (assign) BOOL feedbackEnabled;
@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UVSubdomain *subdomain;
@property (nonatomic, retain) NSArray *customFields;
@property (nonatomic, retain) NSArray *topArticles;
@property (nonatomic, retain) NSArray *topSuggestions;
@property (assign) NSInteger clientId;

+ (id)getWithDelegate:(id)delegate;
+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;
+ (UIInterfaceOrientation)getOrientation;
+ (void)setOrientation;

@end
