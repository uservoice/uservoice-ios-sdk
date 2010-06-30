//
//  UVCategorySelectViewController.h
//  UserVoice
//
//  Created by UserVoice on 2/6/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVForum;
@class UVCategory;

@interface UVCategorySelectViewController : UVBaseViewController <UITableViewDelegate, UITableViewDataSource> {
	UVForum *forum;
	NSArray *categories;
	UVCategory *selectedCategory;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) UVCategory *selectedCategory;

- (id)initWithForum:(UVForum *)theForum andSelectedCategory:(UVCategory *)category;

@end
