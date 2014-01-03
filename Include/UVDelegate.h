//
//  UVDelegate.h
//  UserVoice
//
//  Created by Austin Taylor on 1/13/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UVDelegate <NSObject>
@optional
- (void)userVoiceWasDismissed;
@end
