//
//  UserVoice.m
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UserVoice.h"
#import "UVConfig.h"
#import "UVClientConfig.h"
#import "UVWelcomeViewController.h"
#import "UVRootViewController.h"
#import "UVSession.h"
#import "UVNewTicketViewController.h"
#import "UVNewSuggestionViewController.h"

@implementation UserVoice

+ (void) presentUserVoiceController:(UIViewController *)viewController forParentViewController:(UIViewController *)parentViewController withConfig:(UVConfig *)config {
    [UVSession currentSession].config = config;
	[UVSession currentSession].isModal = YES;
    // Capture the launch orientation, then store it in NSDefaults for reference in all other UV view controller classes
    [UVClientConfig setOrientation];
	UINavigationController *userVoiceNav = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
	[parentViewController presentModalViewController:userVoiceNav animated:YES];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)parentViewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret {
    UVConfig *config = [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret] autorelease];
    [self presentUserVoiceInterfaceForParentViewController:parentViewController andConfig:config];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)parentViewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andSsoToken:(NSString *)token {
    UVConfig *config = [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret andSSOToken:token] autorelease];
    [self presentUserVoiceInterfaceForParentViewController:parentViewController andConfig:config];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)parentViewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andEmail:(NSString *)email andDisplayName:(NSString *)displayName andGUID:(NSString *)guid {
    UVConfig *config = [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret andEmail:email andDisplayName:displayName andGUID:guid] autorelease];
    [self presentUserVoiceInterfaceForParentViewController:parentViewController andConfig:config];
}

+ (void)presentUserVoiceInterfaceForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    UIViewController *viewController;
    if ([[UVSession currentSession] clientConfig])
        viewController = [[[UVWelcomeViewController alloc] init] autorelease];
    else
        viewController = [[[UVRootViewController alloc] init] autorelease];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController withConfig:config];
}

+ (void)presentUserVoiceContactUsFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    UIViewController *viewController = [[[UVNewTicketViewController alloc] initWithoutNavigation] autorelease];
	[self presentUserVoiceController:viewController forParentViewController:parentViewController withConfig:config];
}

+ (void)presentUserVoiceSuggestionFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    UIViewController *viewController;
    if ([[UVSession currentSession] clientConfig])
        viewController = [[[UVNewSuggestionViewController alloc] initWithoutNavigationWithForum:[UVSession currentSession].clientConfig.forum] autorelease];
    else
        viewController = [[[UVRootViewController alloc] initWithViewToLoad:@"new_suggestion"] autorelease];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController withConfig:config];
}

static id<UVDelegate> userVoiceDelegate;
+ (void)setDelegate:(id<UVDelegate>)delegate {
    userVoiceDelegate = delegate;
}

+ (id<UVDelegate>)delegate {
    return userVoiceDelegate;
}


@end
