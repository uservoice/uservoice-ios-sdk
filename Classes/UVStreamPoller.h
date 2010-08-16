//
//  UVStreamPoller.h
//  UserVoice
//
//  Created by Scott Rutherford on 12/08/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UVBaseViewController;

@interface UVStreamPoller : NSObject {
	NSTimer *repeatingTimer;
	NSDate *lastPollTime;
	UVBaseViewController *tableViewController;
}

@property (assign) NSTimer *repeatingTimer;
@property (nonatomic, retain) NSDate *lastPollTime;
@property (nonatomic, retain) UVBaseViewController *tableViewController;

+ (UVStreamPoller *)instance;

- (void)startTimer;
- (void)stopTimer;
- (void)pollServer:(NSTimer*)theTimer;
- (BOOL)timerIsRunning;

@end
