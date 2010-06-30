//
//  UVRating.h
//  UserVoice
//
//  Created by UserVoice on 2/23/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVAnswer;

@interface UVQuestion : UVBaseModel {
	NSInteger questionId;
	UVAnswer *currentAnswer;
	NSString *text;
	NSString *flashMessage;
	NSString *flashType;
}

@property (assign) NSInteger questionId;
@property (nonatomic, retain) UVAnswer *currentAnswer;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *flashMessage;
@property (nonatomic, retain) NSString *flashType;

@end
