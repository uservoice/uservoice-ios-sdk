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

@class UVSubdomain;

@interface UVClientConfig : UVBaseModel {
    BOOL ticketsEnabled;
    BOOL feedbackEnabled;
    BOOL whiteLabel;
    UVSubdomain *subdomain;
    NSArray *customFields;
    NSArray *topArticles;
    NSArray *topSuggestions;
    NSInteger clientId;
    NSInteger defaultForumId;
}

@property (nonatomic, assign) BOOL ticketsEnabled;
@property (nonatomic, assign) BOOL feedbackEnabled;
@property (nonatomic, assign) BOOL whiteLabel;
@property (nonatomic, retain) UVSubdomain *subdomain;
@property (nonatomic, retain) NSArray *customFields;
@property (nonatomic, retain) NSArray *topArticles;
@property (nonatomic, retain) NSArray *topSuggestions;
@property (nonatomic, assign) NSInteger clientId;
@property (nonatomic, assign) NSInteger defaultForumId;

+ (id)getWithDelegate:(id)delegate;
+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;

@end
