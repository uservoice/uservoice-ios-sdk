//
//  UVSuggestionDetailsViewController.m
//  UserVoice
//
//  Created by UserVoice on 10/29/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionDetailsViewController.h"
#import "UVStyleSheet.h"
#import "UVSession.h"
#import "UVSuggestion.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVImageView.h"
#import "UVComment.h"
#import "UVCommentViewController.h"
#import "UVTruncatingLabel.h"
#import "UVCallback.h"
#import "UVBabayaga.h"
#import "UVDeflection.h"
#import "UVCategory.h"

#define MARGIN 15

#define COMMENT_AVATAR_TAG 1000
#define COMMENT_NAME_TAG 1001
#define COMMENT_DATE_TAG 1002
#define COMMENT_TEXT_TAG 1003
#define SUGGESTION_DESCRIPTION 20
#define ADMIN_RESPONSE 30

@implementation UVSuggestionDetailsViewController {
    
    BOOL suggestionExpanded;
    BOOL responseExpanded;
    BOOL _subscribing;
    UVCallback *_subscribeCallback;
    UVCallback *_showCommentControllerCallback;
    
}

@synthesize suggestion;
@synthesize comments;
@synthesize subscriberCount;
@synthesize instantAnswers;

- (id)init {
    self = [super init];
    
    if (self) {
        _subscribeCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(doSubscribe)];
        _showCommentControllerCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(presentCommentController)];
    }
    
    return self;
}

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
    self = [self init];

    if (self) {
        self.suggestion = theSuggestion;
    }

    return self;
}

- (void)retrieveMoreComments {
    NSInteger page = ([self.comments count] / 10) + 1;
    [UVComment getWithSuggestion:self.suggestion page:page delegate:self];
}

- (void)didRetrieveComments:(NSArray *)theComments {
    if ([theComments count] > 0) {
        [self.comments addObjectsFromArray:theComments];
        if ([self.comments count] >= self.suggestion.commentsCount) {
            allCommentsRetrieved = YES;
        }
    } else {
        allCommentsRetrieved = YES;
    }
    [self.tableView reloadData];
}

- (void)didSubscribe:(UVSuggestion *)theSuggestion {
    [UVBabayaga track:VOTE_IDEA id:theSuggestion.suggestionId];
    [UVBabayaga track:SUBSCRIBE_IDEA id:theSuggestion.suggestionId];
    if (instantAnswers) {
        [UVDeflection trackDeflection:@"subscribed" deflector:theSuggestion];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:_helpfulPrompt
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:_returnMessage, NSLocalizedStringFromTable(@"No, I'm done", @"UserVoice", nil), nil];
        [actionSheet showInView:self.view];
    }
    [self updateSuggestion:theSuggestion];
    _subscribing = NO;
}

- (void)didUnsubscribe:(UVSuggestion *)theSuggestion {
    [self updateSuggestion:theSuggestion];
}

- (void)updateSuggestion:(UVSuggestion *)theSuggestion {
    self.suggestion.subscribed = theSuggestion.subscribed;
    self.suggestion.subscriberCount = theSuggestion.subscriberCount;
    [self updateSubscriberCount];
}

- (void)updateSubscriberCount {
    if (self.suggestion.subscriberCount == 1) {
        self.subscriberCount.text = NSLocalizedStringFromTable(@"1 person", @"UserVoice", nil);
    } else {
        self.subscriberCount.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d people", @"UserVoice", nil), self.suggestion.subscriberCount];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (buttonIndex == 1) {
        [self dismissUserVoice];
    }
}

#pragma mark ===== UITableView Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    BOOL selectable = NO;

    if (indexPath.section == 0 && indexPath.row == 0) {
        identifier = @"Suggestion";
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        identifier = @"Response";
    } else if (indexPath.section == 1) {
        identifier = @"AddComment";
        selectable = YES;
    } else if (indexPath.row < [self.comments count]) {
        identifier = @"Comment";
    } else {
        identifier = @"Load";
        selectable = YES;
    }

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (void)initCellForComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVImageView *avatar = [UVImageView new];
    avatar.tag = COMMENT_AVATAR_TAG;

    UILabel *name = [UILabel new];
    name.tag = COMMENT_NAME_TAG;
    name.font = [UIFont boldSystemFontOfSize:13];
    name.textColor = [UIColor colorWithRed:0.19f green:0.20f blue:0.20f alpha:1.0f];

    UILabel *date = [UILabel new];
    date.tag = COMMENT_DATE_TAG;
    date.font = [UIFont systemFontOfSize:12];
    date.textColor = [UIColor colorWithRed:0.58f green:0.58f blue:0.60f alpha:1.0f];

    UILabel *text = [UILabel new];
    text.tag = COMMENT_TEXT_TAG;
    text.numberOfLines = 0;
    text.font = [UIFont systemFontOfSize:13];
    text.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];

    NSArray *constraints = @[
        @"|-16-[avatar(==40)]-[name]",
        @"[date]-|",
        @"[avatar]-[text]-|",
        @"V:|-14-[avatar(==40)]",
        @"V:|-14-[name]-[text]",
        @"V:|-14-[date]"
    ];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(avatar, name, date, text)
            constraints:constraints
         finalCondition:indexPath == nil
        finalConstraint:@"V:[text]-14-|"];
}

- (void)customizeCellForComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVComment *comment = [self.comments objectAtIndex:indexPath.row];

    UVImageView *avatar = (UVImageView *)[cell viewWithTag:COMMENT_AVATAR_TAG];
    avatar.URL = comment.avatarUrl;

    UILabel *name = (UILabel *)[cell viewWithTag:COMMENT_NAME_TAG];
    name.text = comment.userName;

    UILabel *date = (UILabel *)[cell viewWithTag:COMMENT_DATE_TAG];
    date.text = [NSDateFormatter localizedStringFromDate:comment.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];

    UILabel *text = (UILabel *)[cell viewWithTag:COMMENT_TEXT_TAG];
    text.text = comment.text;
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.frame];
    label.text = NSLocalizedStringFromTable(@"Load more", @"UserVoice", nil);
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:label];
}

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *category = [UILabel new];
    category.font = [UIFont systemFontOfSize:13];
    category.text = suggestion.category.name;
    category.adjustsFontSizeToFitWidth = YES;
    category.minimumScaleFactor = 0.5;
    category.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];

    UILabel *title = [UILabel new];
    title.font = [UIFont boldSystemFontOfSize:17];
    title.text = suggestion.title;
    title.numberOfLines = 0;

    UVTruncatingLabel *desc = [UVTruncatingLabel new];
    desc.font = [UIFont systemFontOfSize:14];
    desc.fullText = suggestion.text;
    desc.numberOfLines = 0;
    desc.delegate = self;
    desc.tag = SUGGESTION_DESCRIPTION;

    NSArray *constraints = @[
        @"|-16-[category]-|",
        @"|-16-[title]-|",
        @"|-16-[desc]-|",
        @"V:|-12-[category]-8-[title]-[desc]"
    ];
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(category, title, desc)
            constraints:constraints
         finalCondition:indexPath == nil
        finalConstraint:@"V:[desc]-|"];
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVTruncatingLabel *desc = (UVTruncatingLabel *)[cell.contentView viewWithTag:SUGGESTION_DESCRIPTION];
    if (suggestionExpanded)
        [desc expand];
}

- (void)initCellForResponse:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UIView *statusColor = [UIView new];
    statusColor.backgroundColor = suggestion.statusColor;

    UILabel *status = [UILabel new]; 
    status.font = [UIFont systemFontOfSize:12];
    status.text = suggestion.status.uppercaseString;
    status.textColor = suggestion.statusColor;

    UILabel *date = [UILabel new];
    date.font = [UIFont systemFontOfSize:12];
    date.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    date.text = [NSDateFormatter localizedStringFromDate:suggestion.responseCreatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    
    if ([suggestion.responseText length] > 0) {
        UVImageView *avatar = [UVImageView new];
        avatar.URL = suggestion.responseUserAvatarUrl;

        UVTruncatingLabel *text = [UVTruncatingLabel new];
        text.font = [UIFont systemFontOfSize:13];
        text.fullText = suggestion.responseText;
        text.numberOfLines = 0;
        text.delegate = self;
        text.tag = ADMIN_RESPONSE;

        UILabel *admin = [UILabel new];
        admin.font = [UIFont systemFontOfSize:12];
        admin.text = suggestion.responseUserWithTitle;
        admin.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
        admin.adjustsFontSizeToFitWidth = YES;
        admin.minimumScaleFactor = 0.5;

        NSArray *constraints = @[
            @"|-16-[statusColor(==10)]-[status]-|",
            @"[date]-|",
            @"|-16-[text]-[avatar(==40)]-|",
            @"|-16-[admin]-|",
            @"V:|-14-[statusColor(==10)]",
            @"V:|-12-[status]",
            @"V:|-12-[date]-[avatar(==40)]",
            @"V:[date]-[text]-[admin]"
        ];
        [self configureView:cell.contentView
                   subviews:NSDictionaryOfVariableBindings(statusColor, status, date, text, admin, avatar)
                constraints:constraints
             finalCondition:indexPath == nil
            finalConstraint:@"V:[admin]-12-|"];
    } else {
        NSArray *constraints = @[
            @"|-16-[statusColor(==10)]-[status]-|",
            @"[date]-|",
            @"V:|-14-[statusColor(==10)]",
            @"V:|-12-[status]",
            @"V:|-12-[date]",
        ];
        [self configureView:cell.contentView
                   subviews:NSDictionaryOfVariableBindings(statusColor, status, date)
                constraints:constraints
             finalCondition:indexPath == nil
            finalConstraint:@"V:[status]-12-|"];
    }
}

- (void)customizeCellForResponse:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVTruncatingLabel *text = (UVTruncatingLabel *)[cell.contentView viewWithTag:ADMIN_RESPONSE];
    if (responseExpanded)
        [text expand];
}

- (void)initCellForAddComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = NSLocalizedStringFromTable(@"Add a comment", @"UserVoice", nil);
    if (IOS7) {
        cell.textLabel.textColor = cell.textLabel.tintColor;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.suggestion.status || self.suggestion.responseText ? 2 : 1;
    } else if (section == 1) {
        return 1;
    } else {
        return [comments count] + (allCommentsRetrieved || [comments count] == 0 ? 0 : 1);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return instantAnswers ? 1 : 3;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row < [self.comments count]) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Comment" indexPath:indexPath];
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Suggestion" indexPath:indexPath];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Response" indexPath:indexPath];
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self requireUserSignedIn:_showCommentControllerCallback];
    } else if (indexPath.section == 2 && indexPath.row == [self.comments count]) {
        [self retrieveMoreComments];
    }
}

#pragma mark ===== Actions =====

- (void)toggleSubscribed {
    if (suggestion.subscribed) {
        [self unsubscribe];
    } else {
        [self subscribe];
    }
}

- (void)subscribe {
    if (_subscribing) return;
    _subscribing = YES;
    [self requireUserSignedIn:_subscribeCallback];
}

- (void)presentCommentController {
    [self presentModalViewController:[[UVCommentViewController alloc] initWithSuggestion:suggestion]];
}

- (void)doSubscribe {
    [suggestion subscribe:self];
}

- (void)unsubscribe {
    [suggestion unsubscribe:self];
}

#pragma mark ===== Basic View Methods =====

- (void)labelExpanded:(UVTruncatingLabel *)label {
    if (label.tag == SUGGESTION_DESCRIPTION) {
        suggestionExpanded = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        responseExpanded = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)loadView {
    [super loadView];
    [UVBabayaga track:VIEW_IDEA id:suggestion.suggestionId];
    self.view = [[UIView alloc] initWithFrame:[self contentFrame]];

    CGFloat footerHeight = instantAnswers ? 46 : 66;
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [UIView new];
    table.contentInset = UIEdgeInsetsMake(0, 0, footerHeight, 0);
    table.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, footerHeight, 0);
    self.tableView = table;

    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    UIView *border = [UIView new];
    border.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    if (instantAnswers) {
        UILabel *people = [UILabel new];
        people.font = [UIFont systemFontOfSize:14];
        people.textColor = [UIColor colorWithRed:0.58f green:0.58f blue:0.60f alpha:1.0f];
        self.subscriberCount = people;

        UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_heart.png"]];

        UILabel *this = [UILabel new];
        this.text = NSLocalizedStringFromTable(@"this idea", @"UserVoice", nil);
        this.font = people.font;
        this.textColor = people.textColor;

        UIButton *want = [UIButton new];
        [want setTitle:NSLocalizedStringFromTable(@"I want this", @"UserVoice", nil) forState:UIControlStateNormal];
        [want setTitleColor:want.tintColor forState:UIControlStateNormal];
        [want addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];

        NSArray *constraints = @[
            @"|[border]|", @"V:|[border(==1)]",
            @"|-[people]-4-[heart(==12)]-4-[this]", @"[want]-|",
            @"V:|-14-[people]", @"V:|-18-[heart(==11)]", @"V:|-14-[this]", @"V:|-6-[want]"
        ];
        [self configureView:footer
                   subviews:NSDictionaryOfVariableBindings(border, want, people, heart, this)
                constraints:constraints];
    } else {
        UILabel *want = [UILabel new];
        want.text = NSLocalizedStringFromTable(@"I want this!", @"UserVoice", nil);
        want.font = [UIFont systemFontOfSize:16];

        UILabel *people = [UILabel new];
        people.font = [UIFont systemFontOfSize:13];
        people.textColor = [UIColor colorWithRed:0.58f green:0.58f blue:0.60f alpha:1.0f];
        self.subscriberCount = people;

        UIImageView *heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_heart.png"]];

        UILabel *this = [UILabel new];
        this.text = NSLocalizedStringFromTable(@"this", @"UserVoice", nil);
        this.font = people.font;
        this.textColor = people.textColor;

        UISwitch *toggle = [UISwitch new];
        if (self.suggestion.subscribed) {
            toggle.on = YES;
        }
        [toggle addTarget:self action:@selector(toggleSubscribed) forControlEvents:UIControlEventValueChanged];

        NSArray *constraints = @[
            @"|[border]|", @"V:|[border(==1)]",
            @"|-[want]", @"|-[people]-4-[heart(==12)]-4-[this]", @"[toggle]-|",
            @"V:|-14-[want]-2-[people]", @"V:[want]-6-[heart(==11)]", @"V:[want]-2-[this]", @"V:|-16-[toggle]"
        ];
        [self configureView:footer
                   subviews:NSDictionaryOfVariableBindings(border, want, people, heart, this, toggle)
                constraints:constraints];
    }

    [self configureView:self.view
               subviews:NSDictionaryOfVariableBindings(table, footer)
            constraints:@[@"V:|[table]|", @"V:[footer]|", @"|[table]|", @"|[footer]|"]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:footer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:footerHeight]];
    [self.view bringSubviewToFront:footer];
    [self reloadComments];
    [self updateSubscriberCount];
}

- (void)initNavigationItem {}

- (void)reloadComments {
    allCommentsRetrieved = NO;
    self.comments = [NSMutableArray arrayWithCapacity:10];
    [self retrieveMoreComments];
}

- (void)dealloc {
    [_subscribeCallback invalidate];
    [_showCommentControllerCallback invalidate];
}

@end
