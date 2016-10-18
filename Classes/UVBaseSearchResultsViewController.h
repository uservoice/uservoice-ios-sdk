//
//  UVBaseSearchResultsViewController.h
//  UserVoice
//
//  Created by Donny Davis on 9/25/16.
//  Copyright © 2016 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@interface UVBaseSearchResultsViewController : UVBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *searchResults;

- (UIView *)displayNoResults;

@end
