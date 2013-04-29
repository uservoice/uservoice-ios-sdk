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
#import "UVGradientButton.h"
#import "UVTruncatingLabel.h"

#define MARGIN 15

#define COMMENT_AVATAR_TAG 1000
#define COMMENT_NAME_TAG 1001
#define COMMENT_DATE_TAG 1002
#define COMMENT_TEXT_TAG 1003

@implementation UVSuggestionDetailsViewController

@synthesize suggestion;
@synthesize scrollView;
@synthesize statusBar;
@synthesize comments;
@synthesize titleLabel;
@synthesize votesLabel;
@synthesize descriptionLabel;
@synthesize creatorLabel;
@synthesize responseView;
@synthesize responseLabel;
@synthesize buttons;
@synthesize voteButton;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
    if ((self = [super init])) {
        self.suggestion = theSuggestion;
    }
    return self;
}

- (void)retrieveMoreComments {
    NSInteger page = ([self.comments count] / 10) + 1;
    [self showActivityIndicator];
    [UVComment getWithSuggestion:self.suggestion page:page delegate:self];
}

- (void)didRetrieveComments:(NSArray *)theComments {
    [self hideActivityIndicator];
    if ([theComments count] > 0) {
        [self.comments addObjectsFromArray:theComments];
        if ([self.comments count] >= self.suggestion.commentsCount) {
            allCommentsRetrieved = YES;
        }
    } else {
        allCommentsRetrieved = YES;
    }
    [self updateLayout];
}

- (void)didVoteForSuggestion:(UVSuggestion *)theSuggestion {
    [UVSession currentSession].user.votesRemaining = theSuggestion.votesRemaining;
    [UVSession currentSession].clientConfig.forum.suggestionsNeedReload = YES;
    self.suggestion = theSuggestion;
    [self hideActivityIndicator];
    [self updateVotesLabel];
}

#pragma mark ===== UITableView Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    BOOL selectable = YES;

    if (indexPath.row < [self.comments count]) {
        identifier = @"Comment";
        selectable = NO;
    } else {
        identifier = @"Load";
    }

    return [self createCellForIdentifier:identifier
                               tableView:theTableView
                               indexPath:indexPath
                                   style:style
                              selectable:selectable];
}

- (void)initCellForComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];

    UVImageView *avatar = [[[UVImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, 40, 40)] autorelease];
    avatar.tag = COMMENT_AVATAR_TAG;
    avatar.defaultImage = [UIImage imageNamed:@"uv_default_avatar.png"];
    [cell addSubview:avatar];

    UILabel *name = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN + 50, MARGIN, cell.bounds.size.width - 100, 15)] autorelease];
    name.tag = COMMENT_NAME_TAG;
    name.font = [UIFont boldSystemFontOfSize:13];
    name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    name.backgroundColor = [UIColor clearColor];
    name.textColor = [UIColor colorWithRed:0.19f green:0.20f blue:0.20f alpha:1.0f];
    [cell addSubview:name];

    UILabel *date = [[[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.width - MARGIN - 100, MARGIN, 100, 15)] autorelease];
    date.tag = COMMENT_DATE_TAG;
    date.font = [UIFont systemFontOfSize:12];
    date.textAlignment = UITextAlignmentRight;
    date.backgroundColor = [UIColor clearColor];
    date.textColor = [UIColor colorWithRed:0.58f green:0.58f blue:0.60f alpha:1.0f];
    date.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cell addSubview:date];

    UILabel *text = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN + 50, MARGIN + 20, cell.bounds.size.width - MARGIN * 2 - 50, cell.bounds.size.height - MARGIN * 2 - 20)] autorelease];
    text.tag = COMMENT_TEXT_TAG;
    text.numberOfLines = 0;
    text.font = [UIFont systemFontOfSize:13];
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    text.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [cell addSubview:text];
}

- (void)customizeCellForComment:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVComment *comment = [self.comments objectAtIndex:indexPath.row];
    cell.backgroundView.backgroundColor = indexPath.row % 2 == 0 ?
        [UIColor colorWithRed:0.99f green:1.00f blue:1.00f alpha:1.0f] :
        [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];

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
    cell.backgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:cell.frame] autorelease];
    label.text = NSLocalizedStringFromTable(@"Load more", @"UserVoice", nil);
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = UITextAlignmentCenter;
    [cell addSubview:label];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundView.backgroundColor = indexPath.row % 2 == 0 ?
        [UIColor colorWithRed:0.99f green:1.00f blue:1.00f alpha:1.0f] :
        [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [comments count] + (allCommentsRetrieved || [comments count] == 0 ? 0 : 1);
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.comments count]) {
        UVComment *comment = [self.comments objectAtIndex:indexPath.row];
        CGFloat labelWidth = tableView.bounds.size.width - MARGIN*2 - 50;
        CGSize size = [comment.text sizeWithFont:[UIFont systemFontOfSize:13]
                               constrainedToSize:CGSizeMake(labelWidth, 10000)
                                   lineBreakMode:UILineBreakModeWordWrap];
        return MAX(size.height + MARGIN*2 + 20, MARGIN*2 + 40);
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [self.comments count])
        [self retrieveMoreComments];
}

#pragma mark ===== Actions =====

- (void)disableButton:(int)index inActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *view in actionSheet.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (index == 0) {
                if ([view respondsToSelector:@selector(setEnabled:)]) {
                    UIButton* button = (UIButton*)view;
                    button.enabled = NO;
                    button.layer.opacity = 0.8;
                }
            }
            index--;
        }
    }
}

- (void)voteButtonTapped {
    [self requireUserSignedIn:@selector(openVoteActionSheet)];
}

- (void)openVoteActionSheet {
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] init] autorelease];
    int votesRemaining = [UVSession currentSession].user.votesRemaining;
    actionSheet.title = [NSString stringWithFormat:@"%@\n(%@)", NSLocalizedStringFromTable(@"How many votes would you like to use?", @"UserVoice", nil), [NSString stringWithFormat:NSLocalizedStringFromTable(@"You have %i votes left", @"UserVoice", nil), votesRemaining]];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"1 vote", @"UserVoice", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"2 votes", @"UserVoice", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"3 votes", @"UserVoice", nil)];
    if (suggestion.votesFor == 0) {
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
        actionSheet.cancelButtonIndex = 3;
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Remove votes", @"UserVoice", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)];
        actionSheet.destructiveButtonIndex = 3;
        actionSheet.cancelButtonIndex = 4;
        [self disableButton:(suggestion.votesFor - 1) inActionSheet:actionSheet];
    }
    if (votesRemaining < 3)
        [self disableButton:2 inActionSheet:actionSheet];
    if (votesRemaining < 2)
        [self disableButton:1 inActionSheet:actionSheet];
    if (votesRemaining < 1)
        [self disableButton:0 inActionSheet:actionSheet];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 4 || (suggestion.votesFor == 0 && buttonIndex == 3))
        return;
    int votes = (buttonIndex == 3) ? 0 : buttonIndex + 1;
    if (votes == suggestion.votesFor)
        return;

    [self showActivityIndicator];
    if (votes == 0) {
        [[UVSession currentSession].user didWithdrawSupportForSuggestion:suggestion];
    } else if (suggestion.votesFor == 0) {
        [[UVSession currentSession] trackInteraction:@"v"];
        [[UVSession currentSession].user didSupportSuggestion:suggestion];
    }

    suggestion.votesFor = votes;
    [suggestion vote:votes delegate:self];
}

- (void)commentButtonTapped {
    [self requireUserSignedIn:@selector(presentCommentController)];
}

- (void)presentCommentController {
    [self presentModalViewController:[[[UVCommentViewController alloc] initWithSuggestion:suggestion] autorelease]];
}

#pragma mark ===== Basic View Methods =====

- (void)sizeToFit:(UIView *)view {
    CGRect frame = view.frame;
    frame.size.width = scrollView.frame.size.width - MARGIN * 2;
    view.frame = frame;
    [view sizeToFit];
}

- (void)update:(UIView *)view after:(UIView *)aboveView space:(CGFloat)space {
    CGRect frame = view.frame;
    frame.origin.y = aboveView.frame.origin.y + aboveView.frame.size.height + space;
    view.frame = frame;
}

- (void)updateLayout {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self sizeToFit:titleLabel];
    [self update:descriptionLabel after:titleLabel space:10];
    [self sizeToFit:descriptionLabel];
    [self update:creatorLabel after:descriptionLabel space:3];
    if (responseView) {
        [self update:responseView after:creatorLabel space:15];
        [self sizeToFit:responseView];
        responseLabel.frame = CGRectMake(60, 48, responseView.bounds.size.width - 70, 100);
        [responseLabel sizeToFit];
        responseView.frame = CGRectMake(responseView.frame.origin.x, responseView.frame.origin.y, responseView.frame.size.width, responseLabel.frame.origin.y + responseLabel.frame.size.height + 15);
        CALayer *border = (CALayer *)[responseView.layer.sublayers objectAtIndex:0];
        border.frame = responseView.bounds;
    }
    [self update:buttons after:(responseView ? responseView : creatorLabel) space:10];
    [self update:votesLabel after:buttons space:10];

    tableView.frame = CGRectMake(0, votesLabel.frame.origin.y + votesLabel.frame.size.height + 10, scrollView.frame.size.width, 1000);

    if (statusBar) {
        for (CALayer *layer in statusBar.layer.sublayers) {
            layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y, statusBar.frame.size.width, layer.frame.size.height);
        }
    }
    [tableView reloadData];
    tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.contentSize.height);
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, tableView.frame.origin.y + tableView.contentSize.height);
    [CATransaction commit];
}

- (void)updateVotesLabel {
    NSString *votesString = nil;
    if (suggestion.voteCount == 0)
        votesString = NSLocalizedStringFromTable(@"0 votes", @"UserVoice", nil);
    else if (suggestion.voteCount == 1)
        votesString = NSLocalizedStringFromTable(@"1 vote", @"UserVoice", nil);
    else
        votesString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ votes", @"UserVoice", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:suggestion.voteCount] numberStyle:NSNumberFormatterDecimalStyle]];

    NSString *commentsString = nil;
    if (suggestion.commentsCount == 0)
        commentsString = NSLocalizedStringFromTable(@"0 comments", @"UserVoice", nil);
    else if (suggestion.commentsCount == 1)
        commentsString = NSLocalizedStringFromTable(@"1 comment", @"UserVoice", nil);
    else
        commentsString = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ comments", @"UserVoice", nil), [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:suggestion.commentsCount] numberStyle:NSNumberFormatterDecimalStyle]];

    votesLabel.text = [NSString stringWithFormat:@"%@  •  %@", votesString, commentsString];

    NSString *title;
    if (suggestion.votesFor == 1)
        title = NSLocalizedStringFromTable(@"1 vote", @"UserVoice", nil);
    else if (suggestion.votesFor == 2)
        title = NSLocalizedStringFromTable(@"2 votes", @"UserVoice", nil);
    else if (suggestion.votesFor == 3)
        title = NSLocalizedStringFromTable(@"3 votes", @"UserVoice", nil);
    else
        title = NSLocalizedStringFromTable(@"Vote", @"UserVoice", nil);
    [voteButton setTitle:title forState:UIControlStateNormal];
}

- (CGRect)nextRectWithHeight:(CGFloat)height space:(CGFloat)space {
    CGFloat offset;
    if ([scrollView.subviews count] == 0) {
        offset = 0;
    } else {
        UIView *lastView  = (UIView *)[scrollView.subviews lastObject];
        offset = lastView.frame.origin.y + lastView.frame.size.height;
    }
    return CGRectMake(MARGIN, offset + space, scrollView.bounds.size.width - MARGIN*2, height);
}

- (void)labelExpanded:(UVTruncatingLabel *)label {
    [self updateLayout];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = self.suggestion.title;
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.autoresizesSubviews = YES;
    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    scrollView.backgroundColor = [UIColor colorWithRed:0.95f green:0.98f blue:1.00f alpha:1.0f];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    if (suggestion.status) {
        self.statusBar = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, 27)] autorelease];
        self.statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        self.statusBar.backgroundColor = [suggestion statusColor];
        UIColor *light = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        UIColor *zero = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.0];
        UIColor *dark = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
        UIColor *darkest = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        CALayer *top = [CALayer layer];
        top.frame = CGRectMake(0, 0, scrollView.bounds.size.width, 1);
        top.backgroundColor = light.CGColor;
        [self.statusBar.layer addSublayer:top];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 1, scrollView.bounds.size.width, 25);
        gradient.colors = @[(id)dark.CGColor, (id)zero.CGColor, (id)light.CGColor];
        [self.statusBar.layer addSublayer:gradient];
        CALayer *bottom = [CALayer layer];
        bottom.frame = CGRectMake(0, 26, scrollView.bounds.size.width, 1);
        bottom.backgroundColor = darkest.CGColor;
        [self.statusBar.layer addSublayer:bottom];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN, 4, statusBar.bounds.size.width, 17)] autorelease];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        label.shadowOffset = CGSizeMake(0, -1);
        label.font = [UIFont boldSystemFontOfSize:13];
        label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Status: %@", @"UserVoice", nil), suggestion.status];
        [statusBar addSubview:label];
        [scrollView addSubview:statusBar];
    }

    self.titleLabel = [[[UILabel alloc] initWithFrame:[self nextRectWithHeight:30 space:10]] autorelease];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = suggestion.title;
    titleLabel.numberOfLines = 0;
    [titleLabel sizeToFit];
    [scrollView addSubview:titleLabel];

    self.descriptionLabel = [[[UVTruncatingLabel alloc] initWithFrame:[self nextRectWithHeight:100 space:10]] autorelease];
    descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textColor = [UIColor colorWithRed:0.19f green:0.20f blue:0.20f alpha:1.0f];
    descriptionLabel.font = [UIFont systemFontOfSize:13];
    descriptionLabel.fullText = suggestion.text;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.delegate = self;
    [descriptionLabel sizeToFit];
    [scrollView addSubview:descriptionLabel];

    self.creatorLabel = [[[UILabel alloc] initWithFrame:[self nextRectWithHeight:15 space:3]] autorelease];
    creatorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    creatorLabel.backgroundColor = [UIColor clearColor];
    creatorLabel.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    creatorLabel.font = [UIFont systemFontOfSize:11];
    creatorLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Posted by %@ on %@", @"UserVoice", nil), suggestion.creatorName, [NSDateFormatter localizedStringFromDate:suggestion.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
    [scrollView addSubview:creatorLabel];

    if (suggestion.responseText) {
        self.responseView = [[[UIView alloc] initWithFrame:[self nextRectWithHeight:100 space:15]] autorelease];
        responseView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        responseView.backgroundColor = [UIColor whiteColor];
        responseView.layer.cornerRadius = 2.0;
        responseView.layer.masksToBounds = YES;
        CALayer *border = [CALayer layer];
        border.cornerRadius = 2.0;
        border.masksToBounds = YES;
        border.borderColor = [UIColor colorWithRed:0.82f green:0.84f blue:0.86f alpha:1.0f].CGColor;
        border.borderWidth = 1.0;
        border.frame = responseView.bounds;
        [responseView.layer addSublayer:border];
        UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, responseView.bounds.size.width, 21)] autorelease];
        header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        header.backgroundColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
        UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, header.bounds.size.width - 20, 15)] autorelease];
        headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:9];
        headerLabel.text = NSLocalizedStringFromTable(@"ADMIN RESPONSE", @"UserVoice", nil);
        [header addSubview:headerLabel];
        [responseView addSubview:header];
        UVImageView *avatarView = [[[UVImageView alloc] initWithFrame:CGRectMake(10, 31, 40, 40)] autorelease];
        avatarView.URL = suggestion.responseUserAvatarUrl;
        avatarView.defaultImage = [UIImage imageNamed:@"uv_default_avatar.png"];
        [responseView addSubview:avatarView];
        UILabel *adminLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 31, 120, 15)] autorelease];
        adminLabel.backgroundColor = [UIColor clearColor];
        adminLabel.textColor = [UIColor colorWithRed:0.19f green:0.20f blue:0.20f alpha:1.0f];
        adminLabel.font = [UIFont boldSystemFontOfSize:14];
        adminLabel.text = suggestion.responseUserName;
        [responseView addSubview:adminLabel];
        UILabel *createdAt = [[[UILabel alloc] initWithFrame:CGRectMake(responseView.bounds.size.width - 100, 30, 90, 15)] autorelease];
        createdAt.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        createdAt.backgroundColor = [UIColor clearColor];
        createdAt.textAlignment = UITextAlignmentRight;
        createdAt.font = [UIFont systemFontOfSize:12];
        createdAt.textColor = [UIColor colorWithRed:0.60f green:0.61f blue:0.62f alpha:1.0f];
        createdAt.text = [NSDateFormatter localizedStringFromDate:suggestion.responseCreatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        [responseView addSubview:createdAt];
        self.responseLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 48, responseView.bounds.size.width - 70, 100)] autorelease];
        responseLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        responseLabel.backgroundColor = [UIColor clearColor];
        responseLabel.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
        responseLabel.font = [UIFont systemFontOfSize:13];
        responseLabel.text = suggestion.responseText;
        responseLabel.numberOfLines = 0;
        [responseLabel sizeToFit];
        [responseView addSubview:responseLabel];
        responseView.frame = CGRectMake(responseView.frame.origin.x, responseView.frame.origin.y, responseView.frame.size.width, responseLabel.frame.origin.y + responseLabel.frame.size.height + 15);
        border.frame = responseView.bounds;
        [scrollView addSubview:responseView];
    }

    self.buttons = [[[UIView alloc] initWithFrame:[self nextRectWithHeight:40 space:10]] autorelease];
    buttons.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.voteButton = [[[UVGradientButton alloc] initWithFrame:CGRectMake(0, 0, buttons.bounds.size.width/2 - 5, buttons.bounds.size.height)] autorelease];
    voteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    [voteButton setTitle:NSLocalizedStringFromTable(@"Vote", @"UserVoice", nil) forState:UIControlStateNormal];
    [voteButton addTarget:self action:@selector(voteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttons addSubview:voteButton];
    UIButton *commentButton = [[[UVGradientButton alloc] initWithFrame:CGRectMake(buttons.bounds.size.width/2 + 5, 0, buttons.bounds.size.width/2 - 5, buttons.bounds.size.height)] autorelease];
    commentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    [commentButton setTitle:NSLocalizedStringFromTable(@"Comment", @"UserVoice", nil) forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttons addSubview:commentButton];
    [scrollView addSubview:buttons];
    
    self.votesLabel = [[[UILabel alloc] initWithFrame:[self nextRectWithHeight:25 space:10]] autorelease];
    votesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    votesLabel.backgroundColor = [UIColor clearColor];
    votesLabel.textColor = [UIColor colorWithRed:0.30f green:0.34f blue:0.42f alpha:1.0f];
    votesLabel.font = [UIFont boldSystemFontOfSize:13];
    votesLabel.textAlignment = UITextAlignmentCenter;
    [scrollView addSubview:votesLabel];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, buttons.frame.origin.y + buttons.frame.size.height + 10, scrollView.frame.size.width, 1000) style:UITableViewStylePlain] autorelease];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor colorWithRed:0.76f green:0.78f blue:0.80f alpha:1.0f];
    UIView *border = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)] autorelease];
    border.backgroundColor = [UIColor colorWithRed:0.76f green:0.78f blue:0.80f alpha:1.0f];
    border.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tableView addSubview:border];
    [scrollView addSubview:tableView];

    [self reloadComments];
    [self updateLayout];
}

- (void)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)initNavigationItem {
    [super initNavigationItem];
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"UserVoice", nil)
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(dismiss)] autorelease];
    }
}

- (void)reloadComments {
    allCommentsRetrieved = NO;
    self.comments = [NSMutableArray arrayWithCapacity:10];
    [self updateVotesLabel];
    [self retrieveMoreComments];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.layer.masksToBounds = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.layer.masksToBounds = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateLayout];
}

- (void)dealloc {
    self.suggestion = nil;
    self.scrollView = nil;
    self.statusBar = nil;
    self.comments = nil;
    self.titleLabel = nil;
    self.votesLabel = nil;
    self.descriptionLabel = nil;
    self.creatorLabel = nil;
    self.responseView = nil;
    self.responseLabel = nil;
    self.buttons = nil;
    self.voteButton = nil;
    [super dealloc];
}

@end
