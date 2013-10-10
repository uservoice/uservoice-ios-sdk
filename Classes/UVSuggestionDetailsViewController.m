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
#import "UVCallback.h"
#import "UVBabayaga.h"
#import "UVDeflection.h"

#define MARGIN 15

#define COMMENT_AVATAR_TAG 1000
#define COMMENT_NAME_TAG 1001
#define COMMENT_DATE_TAG 1002
#define COMMENT_TEXT_TAG 1003
#define SUGGESTION_DESCRIPTION 20

@implementation UVSuggestionDetailsViewController {
    
    BOOL suggestionExpanded;
    UVCallback *_showVotesCallback;
    UVCallback *_showCommentControllerCallback;
    
}

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
@synthesize instantAnswers;

- (id)init {
    self = [super init];
    
    if (self) {
        _showVotesCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(openVoteActionSheet)];
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

- (void)didSubscribe:(UVSuggestion *)theSuggestion {
    [UVBabayaga track:VOTE_IDEA id:theSuggestion.suggestionId];
    [UVBabayaga track:SUBSCRIBE_IDEA id:theSuggestion.suggestionId];
    [UVSession currentSession].forum.suggestionsNeedReload = YES;
    self.suggestion = theSuggestion;
    [self hideActivityIndicator];
    if (instantAnswers) {
        [UVDeflection trackDeflection:@"subscribed" deflector:theSuggestion];
    }
}

- (void)didUnsubscribe:(UVSuggestion *)theSuggestion {
    // TODO
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
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        identifier = @"Subscribe";
    } else if (indexPath.section == 1 && indexPath.row == 1) {
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

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *title = [[[UILabel alloc] init] autorelease];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.text = suggestion.title;
    title.numberOfLines = 0;
    title.preferredMaxLayoutWidth = 290;

    UVTruncatingLabel *desc = [[[UVTruncatingLabel alloc] init] autorelease];
    desc.font = [UIFont systemFontOfSize:13];
    desc.fullText = suggestion.text;
    desc.numberOfLines = 0;
    desc.delegate = self;
    desc.preferredMaxLayoutWidth = 290;
    desc.tag = SUGGESTION_DESCRIPTION;

    UILabel *creator = [[[UILabel alloc] init] autorelease];
    creator.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    creator.font = [UIFont systemFontOfSize:14];
    creator.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Posted by %@ on %@", @"UserVoice", nil), suggestion.creatorName, [NSDateFormatter localizedStringFromDate:suggestion.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
    creator.adjustsFontSizeToFitWidth = YES;
    creator.minimumFontSize = 10;

    title.translatesAutoresizingMaskIntoConstraints = NO;
    desc.translatesAutoresizingMaskIntoConstraints = NO;
    creator.translatesAutoresizingMaskIntoConstraints = NO;

    [cell.contentView addSubview:title];
    [cell.contentView addSubview:desc];
    [cell.contentView addSubview:creator];

    NSDictionary *views = NSDictionaryOfVariableBindings(title, desc, creator);
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[title]-|" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[desc]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[creator]-|" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[title]-[desc]-[creator]" options:0 metrics:nil views:views]];
    if (indexPath == nil) {
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[creator]-|" options:0 metrics:nil views:views]];
    }
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVTruncatingLabel *desc = (UVTruncatingLabel *)[cell.contentView viewWithTag:SUGGESTION_DESCRIPTION];
    if (suggestionExpanded)
        [desc expand];
}

- (void)initCellForResponse:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UIView *statusColor = [[[UIView alloc] init] autorelease];
    statusColor.backgroundColor = suggestion.statusColor;

    UILabel *status = [[[UILabel alloc] init] autorelease]; 
    status.font = [UIFont systemFontOfSize:12];
    status.text = suggestion.status.uppercaseString;
    status.textColor = suggestion.statusColor;

    UILabel *date = [[[UILabel alloc] init] autorelease];
    date.font = [UIFont systemFontOfSize:12];
    date.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    date.text = [NSDateFormatter localizedStringFromDate:suggestion.responseCreatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];

    UVImageView *avatar = [[[UVImageView alloc] init] autorelease];
    avatar.URL = suggestion.responseUserAvatarUrl;

    UILabel *text = [[[UILabel alloc] init] autorelease];
    text.font = [UIFont systemFontOfSize:13];
    text.text = suggestion.responseText;
    text.numberOfLines = 0;
    text.preferredMaxLayoutWidth = 236;

    UILabel *admin = [[[UILabel alloc] init] autorelease];
    admin.font = [UIFont systemFontOfSize:14];
    admin.text = suggestion.responseUserWithTitle;
    admin.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    admin.adjustsFontSizeToFitWidth = YES;
    admin.minimumFontSize = 10;

    // NSArray *constraints = @[
    //     @"|-16-[statusColor(==10)]-[status]-|",
    //     @"[date]-|",
    //     @"|-16-[avatar(==40)]-[text]-|",
    //     @"[avatar]-[admin]-|",
    //     @"V:|-14-[statusColor(==10)]",
    //     @"V:|-12-[status]",
    //     @"V:|-12-[date]-[avatar(==40)]",
    //     @"V:[date]-[text]-[admin]"
    // ];
    // [self configureView:cell.contentView
    //            subviews:NSDictionaryOfVariableBindings(statusColor, status, date, text, admin, avatar)
    //         constraints:constraints
    //      finalCondition:indexPath == nil
    //     finalConstraint:@"V:[admin]-|"];


    statusColor.translatesAutoresizingMaskIntoConstraints = NO;
    status.translatesAutoresizingMaskIntoConstraints = NO;
    date.translatesAutoresizingMaskIntoConstraints = NO;
    text.translatesAutoresizingMaskIntoConstraints = NO;
    admin.translatesAutoresizingMaskIntoConstraints = NO;
    avatar.translatesAutoresizingMaskIntoConstraints = NO;

    [cell.contentView addSubview:statusColor];
    [cell.contentView addSubview:status];
    [cell.contentView addSubview:date];
    [cell.contentView addSubview:text];
    [cell.contentView addSubview:admin];
    [cell.contentView addSubview:avatar];

    NSDictionary *views = NSDictionaryOfVariableBindings(statusColor, status, date, text, admin, avatar);
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[statusColor(==10)]-[status]-|" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[date]-|" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[avatar(==40)]-[text]-|" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[avatar]-[admin]-|" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-14-[statusColor(==10)]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[status]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[date]-[avatar(==40)]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[date]-[text]-[admin]" options:0 metrics:nil views:views]];
    if (indexPath == nil) {
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[admin]-|" options:0 metrics:nil views:views]];
    }
}

- (void)initCellForSubscribe:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *want = [[[UILabel alloc] init] autorelease]; 
    want.font = [UIFont systemFontOfSize:18];
    want.text = NSLocalizedStringFromTable(@"I want this!", @"UserVoice", nil);

    UIImageView *heart = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_heart.png"]] autorelease];

    UILabel *count = [[[UILabel alloc] init] autorelease];
    count.font = [UIFont systemFontOfSize:12];
    count.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    count.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d people want this", @"UserVoice", nil), suggestion.subscriberCount];
    // TODO hold onto this so we can update it

    UISwitch *toggle = [[[UISwitch alloc] init] autorelease];
    // TODO listeners, check if already subscribed, etc

    want.translatesAutoresizingMaskIntoConstraints = NO;
    heart.translatesAutoresizingMaskIntoConstraints = NO;
    count.translatesAutoresizingMaskIntoConstraints = NO;
    toggle.translatesAutoresizingMaskIntoConstraints = NO;

    [cell.contentView addSubview:want];
    [cell.contentView addSubview:heart];
    [cell.contentView addSubview:count];
    [cell.contentView addSubview:toggle];

    NSDictionary *views = NSDictionaryOfVariableBindings(want, heart, count, toggle);
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[want]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[heart(==9)]-4-[count]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[toggle]-|" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[toggle]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-14-[want]-6-[heart(==9)]" options:0 metrics:nil views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[want]-3-[count]" options:0 metrics:nil views:views]];
    if (indexPath == nil) {
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[count]-14-|" options:0 metrics:nil views:views]];
    }
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
        return 2;
    } else {
        return [comments count] + (allCommentsRetrieved || [comments count] == 0 ? 0 : 1);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row < [self.comments count]) {
        UVComment *comment = [self.comments objectAtIndex:indexPath.row];
        CGFloat labelWidth = tableView.bounds.size.width - MARGIN*2 - 50;
        CGSize size = [comment.text sizeWithFont:[UIFont systemFontOfSize:13]
                               constrainedToSize:CGSizeMake(labelWidth, 10000)
                                   lineBreakMode:UILineBreakModeWordWrap];
        return MAX(size.height + MARGIN*2 + 20, MARGIN*2 + 40);
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Suggestion" indexPath:indexPath];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Response" indexPath:indexPath];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Subscribe" indexPath:indexPath];
    } else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2 && self.suggestion.commentsCount > 0) {
        if (self.suggestion.commentsCount == 1) {
            return NSLocalizedStringFromTable(@"1 comment", @"UserVoice", nil);
        } else {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d comments", @"UserVoice", nil), self.suggestion.commentsCount];
        }
    } else {
        return nil;
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
    [self requireUserSignedIn:_showVotesCallback];
}

- (void)openVoteActionSheet {
    // TODO subscribe, rather
}

- (void)commentButtonTapped {
    [self requireUserSignedIn:_showCommentControllerCallback];
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
    suggestionExpanded = YES;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)loadView {
    [super loadView];
    [UVBabayaga track:VIEW_IDEA id:suggestion.suggestionId];
    self.view = [[[UIView alloc] initWithFrame:[self contentFrame]] autorelease];
    self.view.autoresizesSubviews = YES;
    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    scrollView.backgroundColor = [UIColor colorWithRed:0.95f green:0.98f blue:1.00f alpha:1.0f];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];

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

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, buttons.frame.origin.y + buttons.frame.size.height + 10, scrollView.frame.size.width, 1000) style:UITableViewStyleGrouped] autorelease];
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

- (void)initNavigationItem {}

- (void)reloadComments {
    allCommentsRetrieved = NO;
    self.comments = [NSMutableArray arrayWithCapacity:10];
    [self retrieveMoreComments];
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
    
    [_showVotesCallback invalidate];
    [_showVotesCallback release];
    [_showCommentControllerCallback invalidate];
    [_showCommentControllerCallback release];
    
    [super dealloc];
}

@end
