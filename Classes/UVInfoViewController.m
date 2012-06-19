//
//  UVInfoViewController.m
//  UserVoice
//
//  Created by Scott Rutherford 05/26/10
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVInfoViewController.h"
#import "UVConfig.h"
#import "UVSession.h"
#import "UVInfo.h"
#import "UVStyleSheet.h"
#import "UVClientConfig.h"
#import "UserVoice.h"

#define UV_INFO_SECTION_ABOUT 0
#define UV_INFO_SECTION_MOTIVATION 1

@implementation UVInfoViewController


- (void)openGithub {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/uservoice/uservoice-iphone-sdk"]];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createCellForIdentifier:@"Version"
                               tableView:tableView
                               indexPath:indexPath
                                   style:UITableViewCellStyleValue1
                              selectable:NO];
}

- (void)customizeCellForVersion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = NSLocalizedStringFromTable(@"Version", @"UserVoice", nil);
    cell.detailTextLabel.text = [UserVoice version];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"UserVoice iOS SDK";
}

#pragma mark ===== Basic View Methods =====

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    self.navigationItem.title = @"About UserVoice";

    CGRect frame = [self contentFrame];
    self.view = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UVStyleSheet backgroundColor];

    UIImageView *logo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_logo.png"]] autorelease];
    logo.center = CGPointMake(frame.size.width/2, 40);
    logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:logo];

    int margin = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 53 : 18;
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(margin, 70, frame.size.width - 2 * margin, 24)] autorelease];
    title.text = NSLocalizedStringFromTable(@"Feedback and Helpdesk Software", @"UserVoice", nil);
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    title.textColor = [UVStyleSheet tableViewHeaderColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:17];
    title.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    title.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:title];

    int rows = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2 : (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ? 3 : 4);
    UILabel *paragraph = [[[UILabel alloc] initWithFrame:CGRectMake(margin, title.frame.origin.y + title.frame.size.height + 8, frame.size.width - 2 * margin, 16 * rows + 6)] autorelease];
    paragraph.text = NSLocalizedStringFromTable(@"UserVoice creates simple feedback and help desk software. Our insight and support platforms enable businesses to understand and engage with customers with ease.", @"UserVoice", nil);
    paragraph.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    paragraph.textColor = [UVStyleSheet tableViewHeaderColor];
    paragraph.backgroundColor = [UIColor clearColor];
    paragraph.font = [UIFont systemFontOfSize:14];
    paragraph.numberOfLines = 5;
    paragraph.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    paragraph.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:paragraph];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, paragraph.frame.origin.y + paragraph.frame.size.height + 8, frame.size.width, 100) style:UITableViewStyleGrouped] autorelease];
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    [self.view addSubview:self.tableView];

    int y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 5;
    NSString *downloadText = NSLocalizedStringFromTable(@"You can download the SDK on ", @"UserVoice", nil);
    int downloadWidth = [downloadText sizeWithFont:[UIFont systemFontOfSize:14]].width;
    UILabel *downloadLabel = [[[UILabel alloc] initWithFrame:CGRectMake(margin, y, downloadWidth, 20)] autorelease];
    downloadLabel.text = downloadText;
    downloadLabel.backgroundColor = [UIColor clearColor];
    downloadLabel.textColor = [UVStyleSheet tableViewHeaderColor];
    downloadLabel.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    downloadLabel.shadowOffset = CGSizeMake(0, 1);
    downloadLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:downloadLabel];

    NSString *githubText = @"GitHub";
    int githubWidth = [githubText sizeWithFont:[UIFont boldSystemFontOfSize:14]].width;
    UIButton *githubButton = [[[UIButton alloc] initWithFrame:CGRectMake(margin + downloadWidth, y, githubWidth, 20)] autorelease];
    [githubButton setTitle:githubText forState:UIControlStateNormal];
    [githubButton setTitleColor:[UVStyleSheet tableViewHeaderColor] forState:UIControlStateNormal];
    [githubButton setTitleShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.8] forState:UIControlStateNormal];
    githubButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    githubButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [githubButton addTarget:self action:@selector(openGithub) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:githubButton];

    UILabel *periodLabel = [[[UILabel alloc] initWithFrame:CGRectMake(margin + downloadWidth + githubWidth, y, 20, 20)] autorelease];
    periodLabel.text = @".";
    periodLabel.backgroundColor = [UIColor clearColor];
    periodLabel.textColor = [UVStyleSheet tableViewHeaderColor];
    periodLabel.shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.8];
    periodLabel.shadowOffset = CGSizeMake(0, 1);
    periodLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:periodLabel];

    [((UIScrollView *)self.view) setContentSize:CGSizeMake(0, periodLabel.frame.origin.y + periodLabel.frame.size.height + 10)];
}

@end
