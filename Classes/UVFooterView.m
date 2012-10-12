//
//  UVFooterView.m
//  UserVoice
//
//  Created by UserVoice on 1/12/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVFooterView.h"
#import "UVBaseViewController.h"
#import "UVUser.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVProfileViewController.h"
#import "UVSignInViewController.h"
#import "UVInfoViewController.h"
#import "UVNewTicketViewController.h"
#import "UVSuggestion.h"
#import "UVSubdomain.h"
#import "UVStyleSheet.h"
#import <QuartzCore/QuartzCore.h>

#define UV_FOOTER_TAG_NAME_VIEW 1
#define UV_FOOTER_TAG_NAME_LABEL 2
#define UV_FOOTER_TAG_NAME_ICON 3

@implementation UVFooterView

@synthesize controller;
@synthesize tableView;

- (void)infoButtonTapped {
    UVInfoViewController *next = [[UVInfoViewController alloc] init];
    [self.controller.navigationController pushViewController:next animated:YES];
    [next release];
}

+ (UVFooterView *)footerViewForController:(UVBaseViewController *)controller {
    CGFloat screenWidth = [UVClientConfig getScreenWidth];
    UVFooterView *footer = [[[UVFooterView alloc ]initWithFrame:CGRectMake(0, 0, screenWidth, 110)] autorelease];
    footer.controller = controller;

    UITableView *theTableView = [[UITableView alloc] initWithFrame:footer.bounds style:UITableViewStyleGrouped];
    theTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    theTableView.scrollEnabled = NO;
    theTableView.delegate = footer;
    theTableView.dataSource = footer;
    theTableView.sectionHeaderHeight = 10.0;
    theTableView.sectionFooterHeight = 8.0;
    theTableView.backgroundColor = [UIColor clearColor];

    // Fix background color on iPad
    if ([theTableView respondsToSelector:@selector(setBackgroundView:)])
        [theTableView setBackgroundView:nil];

    UIView *tableFooter = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 25)] autorelease];
    UILabel *poweredBy = [[[UILabel alloc] initWithFrame:CGRectMake(30, 8, (screenWidth-80), 16)] autorelease];
    poweredBy.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    poweredBy.text = NSLocalizedStringFromTable(@"Feedback powered by UserVoice", @"UserVoice", nil);
    poweredBy.font = [UIFont systemFontOfSize:14.0];
    poweredBy.textColor = [UVStyleSheet tableViewHeaderColor];
    poweredBy.backgroundColor = [UIColor clearColor];
    poweredBy.textAlignment = UITextAlignmentCenter;
    [tableFooter addSubview:poweredBy];

    //TODO: make the info button light if the background color is dark
    UIView *infoContainer = [[[UIView alloc] initWithFrame:CGRectMake(screenWidth/2, 0, screenWidth/2, 30)] autorelease];
    infoContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.center = CGPointMake(110, 14);
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [infoButton addTarget:footer action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [infoContainer addSubview:infoButton];
    [tableFooter addSubview:infoContainer];

    theTableView.tableFooterView = tableFooter;

    footer.tableView = theTableView;
    [footer addSubview:theTableView];
    [theTableView release];

    return footer;
}


- (void)reloadFooter {
    [self.tableView reloadData];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    CGFloat margin = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 45 : 10;

    if ([UVSession currentSession].loggedIn) {
        cell.textLabel.text = NSLocalizedStringFromTable(@"My profile", @"UserVoice", nil);
        UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 13, cell.bounds.size.width - 100 - margin, 18)] autorelease];
        nameLabel.textColor = [UVStyleSheet signedInUserTextColor];
        nameLabel.textAlignment = UITextAlignmentRight;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        nameLabel.font = [UIFont systemFontOfSize:14.0];
        nameLabel.text = [[UVSession currentSession].user nameOrAnonymous];
        nameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:nameLabel];
    } else {
        cell.textLabel.text = NSLocalizedStringFromTable(@"Sign in", @"UserVoice", nil);
        cell.textLabel.textAlignment = UITextAlignmentLeft;
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *next = nil;

    if ([UVSession currentSession].loggedIn) {
        UVUser *user = [UVSession currentSession].user;
        next = [[UVProfileViewController alloc] initWithUVUser:user];
    } else {
        next = [[UVSignInViewController alloc] init];
    }

    if (next) {
        [self.controller.navigationController pushViewController:next animated:YES];
        [next release];
    }
}

- (void)dealloc {
    self.tableView = nil;
    [super dealloc];
}

@end
