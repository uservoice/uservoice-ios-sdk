//
//  UVWelcomeView.h
//  UserVoice
//
//  Created by Scott Rutherford on 01/07/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UVBaseViewController;
@class UVForum;
@class UVQuestion;

@interface UVWelcomeView : UIView <UITableViewDelegate, UITableViewDataSource> {
	UVBaseViewController *_controller;
	UVForum *_forum;
	UVQuestion *_question;
	
	UITableView *_tableView;
	NSArray *_questions;
}

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UVQuestion *question;
@property (nonatomic, retain) NSArray *questions;
@property (nonatomic, retain) UITableView *tableView;
@property (assign) UVBaseViewController *controller;

+ (CGFloat)heightForView;
+ (UVWelcomeView *)welcomeViewForController:(UVBaseViewController *)controller;

- (void)reloadView;
- (UITableViewCell *)createCellForIdentifier:(NSString *)identifier
								   tableView:(UITableView *)theTableView
								   indexPath:(NSIndexPath *)indexPath
									   style:(UITableViewCellStyle)style
								  selectable:(BOOL)selectable;

@end
