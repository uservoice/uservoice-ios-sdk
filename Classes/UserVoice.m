//
//  UserVoice.m
//  UserVoice
//
//  Created by Mirko Froehlich on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UserVoice.h"
#import "UVConfig.h"
#import "UVClientConfig.h"
#import "UVWelcomeViewController.h"
#import "UVRootViewController.h"
#import "UVSession.h"

@implementation UserVoice

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController 
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret {
	[UVSession currentSession].config = [[UVConfig alloc] initWithSite:site andKey:key andSecret:secret];
 	
	UIViewController *rootViewController;
	if ([[UVSession currentSession] clientConfig])
	{
		rootViewController = [[[UVWelcomeViewController alloc] init] autorelease];
	}
	else
	{
		rootViewController = [[[UVRootViewController alloc] init] autorelease];
	}
	[self showUserVoice:rootViewController forController:viewController];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController 
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret
										 andSsoToken:(NSString *)token {
	[UVSession currentSession].config = [[UVConfig alloc] initWithSite:site andKey:key andSecret:secret];
	
	// exchange the sso token for an access token, store it then load up the root view	
	UIViewController *rootViewController;
	if ([[UVSession currentSession] clientConfig])
	{
		rootViewController = [[[UVWelcomeViewController alloc] init] autorelease];
	}
	else
	{
		rootViewController = [[[UVRootViewController alloc] initWithSsoToken:token] autorelease];
	}
	[self showUserVoice:rootViewController forController:viewController];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController 
											 andSite:(NSString *)site
											  andKey:(NSString *)key
										   andSecret:(NSString *)secret
											andEmail:(NSString *)email
									  andDisplayName:(NSString *)displayName
											 andGUID:(NSString *)guid {
	[UVSession currentSession].config = [[UVConfig alloc] initWithSite:site andKey:key andSecret:secret];
	
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
	[self showUserVoice:rootViewController forController:viewController];
	
}

+ (void)showUserVoice:(UIViewController *)rootViewController forController:(UIViewController *)viewController {
	[UVSession currentSession].isModal = YES;
	UINavigationController *userVoiceNav = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
	[viewController presentModalViewController:userVoiceNav animated:YES];
}

@end
