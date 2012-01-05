//
//  UVAnswer.h
//  UserVoice
//
//  Created by Scott Rutherford on 30/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVQuestion;

@interface UVAnswer : UVBaseModel {
	NSInteger answerId;
	NSInteger value;
}

@property (assign) NSInteger answerId;
@property (assign) NSInteger value;

+ (id)createWithQuestion:(UVQuestion *)theQuestion andValue:(NSInteger)theValue andDelegate:(id)delegate;

@end
