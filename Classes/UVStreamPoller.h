//
//  UVStreamPoller.h
//  UserVoice
//
//  Created by Scott Rutherford on 12/08/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVStreamPoller : NSObject {
	NSTimer *repeatingTimer;
	NSDate *lastPollTime;
}

@property (assign) NSTimer *repeatingTimer;
@property (nonatomic, retain) NSDate *lastPollTime;

+ (UVStreamPoller *)instance;

- (void)startTimer;
- (void)stopTimer;
- (void)pollServer:(NSTimer*)theTimer;
- (BOOL)timerIsRunning;

@end
