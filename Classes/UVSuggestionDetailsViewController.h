//
//  UVSuggestionDetailsViewController.h
//  UserVoice
//
//  Created by UserVoice on 10/29/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVSuggestion.h"

@interface UVSuggestionDetailsViewController : UVBaseViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	UVSuggestion *suggestion;
}

@property (nonatomic, retain) UVSuggestion *suggestion;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;
- (void)setVoteLabelTextAndColorForLabel:(UILabel *)label;

@end
