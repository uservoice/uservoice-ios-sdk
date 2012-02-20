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

@implementation UserVoice

+ (void)showUserVoice:(UIViewController *)rootViewController forController:(UIViewController *)viewController {
	[UVSession currentSession].isModal = YES;
	UINavigationController *userVoiceNav = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
	[viewController presentModalViewController:userVoiceNav animated:YES];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController 
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret {
	[UVSession currentSession].config = [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret] autorelease];
 	
	UIViewController *rootViewController;
	if ([[UVSession currentSession] clientConfig])
	{
		rootViewController = [[[UVWelcomeViewController alloc] init] autorelease];
	}
	else
	{
		rootViewController = [[[UVRootViewController alloc] init] autorelease];
	}
	
	// Capture the launch orientation, then store it in NSDefaults for reference in all other UV view controller classes
	[UVClientConfig setOrientation];
	
	[self showUserVoice:rootViewController forController:viewController];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController 
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret
										 andSsoToken:(NSString *)token {
	[UVSession currentSession].config = [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret] autorelease];
	
	// always use the sso token to ensure details are updated	
	UIViewController *rootViewController;
    rootViewController = [[[UVRootViewController alloc] initWithSsoToken:token] autorelease];
	
	// Capture the launch orientation, then store it in NSDefaults for reference in all other UV view controller classes
	[UVClientConfig setOrientation];
	
	[self showUserVoice:rootViewController forController:viewController];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController 
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret
											andEmail:(NSString *)email
									  andDisplayName:(NSString *)displayName
											 andGUID:(NSString *)guid {
	[UVSession currentSession].config = [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret] autorelease];
	
	UIViewController *rootViewController;
	if ([[UVSession currentSession] clientConfig])
	{
		rootViewController = [[[UVWelcomeViewController alloc] init] autorelease];
	}
	else
	{
		rootViewController = [[[UVRootViewController alloc] initWithEmail:email 
																  andGUID:guid 
																  andName:displayName] autorelease];
	}
	
	// Capture the launch orientation, then store it in NSDefaults for reference in all other UV view controller classes
	[UVClientConfig setOrientation];
	
	[self showUserVoice:rootViewController forController:viewController];
	
}

+ (void)presentUserVoiceContactUsFormForParent:(UIViewController *)viewController
                                       andSite:(NSString *)site
                                        andKey:(NSString *)key
                                     andSecret:(NSString *)secret {
	[UVSession currentSession].config = [[[UVConfig alloc] initWithSite:site andKey:key andSecret:secret] autorelease];
	UIViewController *rootViewController = [[[UVNewTicketViewController alloc] initWithoutNavigation] autorelease];
	[UVClientConfig setOrientation];
	[self showUserVoice:rootViewController forController:viewController];
}

static id<UVDelegate> userVoiceDelegate;
+ (void)setDelegate:(id<UVDelegate>)delegate {
    userVoiceDelegate = delegate;
}

+ (id<UVDelegate>)delegate {
    return userVoiceDelegate;
}


@end
