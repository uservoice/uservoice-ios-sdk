//
//  UVResponseViewController.h
//  UserVoice
//
//  Created by UserVoice on 11/10/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVSuggestion;

@interface UVResponseViewController : UVBaseViewController {
	UVSuggestion *suggestion;
}

@property (nonatomic, retain) UVSuggestion *suggestion;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;

@end
