//
//  UVBaseSuggestionListViewController.h
//  UserVoice
//
//  Created by Mirko Froehlich on 11/12/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"


// Base class for all UserVoice views that display a list of suggestions.
@interface UVBaseSuggestionListViewController : UVBaseViewController {
	NSMutableArray *suggestions;
}

@property (nonatomic, retain) NSMutableArray *suggestions;

@end
