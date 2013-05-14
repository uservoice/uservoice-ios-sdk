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
#import "UVSuggestionListViewController.h"
#import "UVNavigationController.h"

@implementation UserVoice

+ (void) presentUserVoiceControllers:(NSArray *)viewControllers forParentViewController:(UIViewController *)parentViewController withConfig:(UVConfig *)config {
    [UVSession currentSession].config = config;
    [UVSession currentSession].isModal = YES;
    UINavigationController *navigationController = [[[UVNavigationController alloc] init] autorelease];
    navigationController.navigationBar.tintColor = [UVStyleSheet navigationBarTintColor];
    [navigationController.navigationBar setBackgroundImage:[UVStyleSheet navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    navigationController.viewControllers = viewControllers;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [parentViewController presentModalViewController:navigationController animated:YES];
}

+ (void) presentUserVoiceController:(UIViewController *)viewController forParentViewController:(UIViewController *)parentViewController withConfig:(UVConfig *)config {
    [self presentUserVoiceControllers:[NSArray arrayWithObject:viewController] forParentViewController:parentViewController withConfig:config];
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
    UIViewController *viewController = [[[UVRootViewController alloc] initWithViewToLoad:@"welcome"] autorelease];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController withConfig:config];
}

+ (void)presentUserVoiceContactUsFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    UIViewController *viewController = [[[UVRootViewController alloc] initWithViewToLoad:@"new_ticket"] autorelease];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController withConfig:config];
}

+ (void)presentUserVoiceNewIdeaFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    UIViewController *viewController = [[[UVRootViewController alloc] initWithViewToLoad:@"new_suggestion"] autorelease];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController withConfig:config];
}

+ (void)presentUserVoiceForumForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    UIViewController *viewController = [[[UVRootViewController alloc] initWithViewToLoad:@"suggestions"] autorelease];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController withConfig:config];
}

+ (void)setExternalId:(NSString *)identifier forScope:(NSString *)scope {
    [[UVSession currentSession] setExternalId:identifier forScope:scope];
}

static id<UVDelegate> userVoiceDelegate;
+ (void)setDelegate:(id<UVDelegate>)delegate {
    userVoiceDelegate = delegate;
}

+ (id<UVDelegate>)delegate {
    return userVoiceDelegate;
}

+ (NSString *)version {
    return @"2.0.10";
}


@end
