//
//  UVSuggestionDetailsViewController.m
//  UserVoice
//
//  Created by UserVoice on 10/29/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVSuggestionDetailsViewController.h"
#import "UVCommentListViewController.h"
#import "UVProfileViewController.h"
#import "UVStyleSheet.h"
#import "UVSession.h"
#import "UVSuggestion.h"
#import "UVResponseViewController.h"
#import "UVSuggestionChickletView.h"
#import "UVUserButton.h"
#import "UVUser.h"
#import "UVClientConfig.h"
#import "UVSignInViewController.h"
#import "UVUIColorAdditions.h"
#import "UVImageView.h"

#define MARGIN 15

@implementation UVSuggestionDetailsViewController

@synthesize suggestion;
@synthesize scrollView;
@synthesize statusBar;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
    if ((self = [super init])) {
        self.suggestion = theSuggestion;
    }
    return self;
}

- (void)didVoteForSuggestion:(UVSuggestion *)theSuggestion {
    [UVSession currentSession].user.votesRemaining = theSuggestion.votesRemaining;
    [UVSession currentSession].clientConfig.forum.suggestionsNeedReload = YES;
    self.suggestion = theSuggestion;

    /* UILabel *votesLabel = (UILabel *)[self.view viewWithTag:VOTE_LABEL_TAG]; */
    /* [self setVoteLabelTextAndColorForLabel:votesLabel]; */
    [self hideActivityIndicator];
}

// Calculates the height of the text.
- (CGSize)textSize {
    CGFloat screenWidth = [UVClientConfig getScreenWidth];
    CGFloat margin = IPAD ? 45 : 10;
    // Probably doesn't matter, but we might want to cache this since we call it twice.
    return [self.suggestion.text
            sizeWithFont:[UIFont systemFontOfSize:13]
       constrainedToSize:CGSizeMake(screenWidth - 2 * margin, 10000)
            lineBreakMode:UILineBreakModeWordWrap];
}

// Calculates the height of the title.
- (CGSize)titleSize {
    CGFloat screenWidth = [UVClientConfig getScreenWidth];
    // Probably doesn't matter, but we might want to cache this since we call it twice.
    return [self.suggestion.title
            sizeWithFont:[UIFont boldSystemFontOfSize:18]
       constrainedToSize:CGSizeMake((screenWidth-(IPAD ? 130 : 85)), 10000)
           lineBreakMode:UILineBreakModeWordWrap];
}

- (NSString *)postDateString {
    static NSDateFormatter* dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    }
    return [dateFormatter stringFromDate:self.suggestion.createdAt];
}

#pragma mark ===== Basic View Methods =====

- (void)updateLayout {
    // title sizeToFit
    // move vote label
    // move description
    // if description expanded do that
    // move poster label
    // move admin response
    // admin response text sizeToFit
    // move buttons
    // move table
    // update table
    if (statusBar) {
        for (CALayer *layer in statusBar.layer.sublayers) {
            layer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y, statusBar.frame.size.width, layer.frame.size.height);
        }
    }
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = self.suggestion.title;
    self.scrollView = [[[UIScrollView alloc] initWithFrame:[self contentFrame]] autorelease];
    scrollView.backgroundColor = [UIColor colorWithRed:0.95f green:0.98f blue:1.00f alpha:1.0f];
    self.view = scrollView;
    if (suggestion.status) {
        self.statusBar = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, 27)] autorelease];
        self.statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        self.statusBar.backgroundColor = [UIColor colorWithHexString:suggestion.statusHexColor];
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
        label.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"Status:", @"UserVoice", nil), suggestion.status];
        [statusBar addSubview:label];
        [scrollView addSubview:statusBar];
    }

    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN, (statusBar ? 27 : 0) + 10, scrollView.bounds.size.width - MARGIN*2, 30)] autorelease];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = suggestion.title;
    [titleLabel sizeToFit];
    [scrollView addSubview:titleLabel];

    UILabel *votesLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN, titleLabel.frame.origin.y + titleLabel.frame.size.height + 2, scrollView.bounds.size.width, 15)] autorelease];
    votesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    votesLabel.backgroundColor = [UIColor clearColor];
    votesLabel.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    votesLabel.font = [UIFont systemFontOfSize:11];
    votesLabel.text = [NSString stringWithFormat:@"%i %@ • %i %@", suggestion.voteCount, NSLocalizedStringFromTable(@"votes", @"UserVoice", nil), suggestion.commentsCount, NSLocalizedStringFromTable(@"comments", @"UserVoice", nil)];
    [scrollView addSubview:votesLabel];

    UILabel *descriptionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN, votesLabel.frame.origin.y + votesLabel.frame.size.height + 10, scrollView.bounds.size.width - MARGIN * 2, 100)] autorelease];
    descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textColor = [UIColor colorWithRed:0.19f green:0.20f blue:0.20f alpha:1.0f];
    descriptionLabel.font = [UIFont systemFontOfSize:13];
    descriptionLabel.text = suggestion.text;
    descriptionLabel.numberOfLines = 3;
    [descriptionLabel sizeToFit];
    [scrollView addSubview:descriptionLabel];

    UILabel *creatorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN, descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 3, scrollView.bounds.size.width, 15)] autorelease];
    creatorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    creatorLabel.backgroundColor = [UIColor clearColor];
    creatorLabel.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    creatorLabel.font = [UIFont systemFontOfSize:11];
    creatorLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", NSLocalizedStringFromTable(@"Posted by", @"UserVoice", nil), suggestion.creatorName, NSLocalizedStringFromTable(@"on", @"UserVoice", nil), [NSDateFormatter localizedStringFromDate:suggestion.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]];
    [scrollView addSubview:creatorLabel];

    if (suggestion.responseText) {
        UIView *responseView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN, creatorLabel.frame.origin.y + creatorLabel.frame.size.height + 15, scrollView.bounds.size.width - MARGIN*2, 100)] autorelease];
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
        // TODO response date (we don't have this data in the model yet)
        UILabel *responseLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 48, responseView.bounds.size.width - 70, 100)] autorelease];
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

    // vote, comment buttons
    // comment table
    //   avatar, name, date, content (wraps)
    //   load more comments
    [self updateLayout];
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
    [super dealloc];
}

@end
