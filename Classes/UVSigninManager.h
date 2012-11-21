//
//  UVSigninManager.h
//  UserVoice
//
//  Created by Austin Taylor on 11/20/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STATE_EMAIL 1
#define STATE_PASSWORD 2
#define STATE_FAILED 3


@interface UVSigninManager : NSObject<UITextFieldDelegate,UIAlertViewDelegate> {
    id delegate;
    SEL action;
    NSString *email;
    NSString *name;
    UIAlertView *alertView;
    NSInteger state;
}

+ (UVSigninManager *)manager;

- (void)signInWithDelegate:(id)theDelegate action:(SEL)theAction;
- (void)signInWithEmail:(NSString *)theEmail name:(NSString *)theName delegate:(id)theDelegate action:(SEL)theAction;

@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) UIAlertView *alertView;

@end
