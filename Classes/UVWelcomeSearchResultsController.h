//
//  UVWelcomeSearchResultsController.h
//  UserVoice
//
//  Created by Donny Davis on 9/5/16.
//  Copyright © 2016 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseSearchResultsViewController.h"
#import "UVInstantAnswerManager.h"

@interface UVWelcomeSearchResultsController : UVBaseSearchResultsViewController

@property (nonatomic, retain) UVInstantAnswerManager *instantAnswerManager;

@end
