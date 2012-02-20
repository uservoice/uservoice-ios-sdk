//
//  UserVoice.h
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVStyleSheet.h"
#import "UVDelegate.h"

@interface UserVoice : NSObject {

}

// Modally present the UserVoice interface
+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret;

// Modally present the UserVoice interface with an SSO token
+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret
                                         andSsoToken:(NSString *)token;

// Modally present the UserVoice interface with user email, name, and GUID
+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController
                                             andSite:(NSString *)site
                                              andKey:(NSString *)key
                                           andSecret:(NSString *)secret
                                            andEmail:(NSString *)email
                                      andDisplayName:(NSString *)displayName
                                             andGUID:(NSString *)guid;

// Modally present the UserVoice contact form
+ (void)presentUserVoiceContactUsFormForParent:(UIViewController *)viewController
                                       andSite:(NSString *)site
                                        andKey:(NSString *)key
                                     andSecret:(NSString *)secret;

// Set a <UVDelegate> to receive callbacks
+ (void)setDelegate:(id<UVDelegate>)delegate;

// Get the current <UVDelegate>
+ (id<UVDelegate>)delegate;

@end
