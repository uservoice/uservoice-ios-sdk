//
//  UVBaseInstantAnswersViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/26/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVBaseInstantAnswersViewController.h"
#import "UVSession.h"
#import "UVArticleViewController.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVSuggestionDetailsViewController.h"

@implementation UVBaseInstantAnswersViewController

@synthesize instantAnswersTimer;
@synthesize instantAnswers;
@synthesize instantAnswersQuery;
@synthesize articleHelpfulPrompt;
@synthesize articleReturnMessage;

- (void)willLoadInstantAnswers {
}

- (void)didLoadInstantAnswers {
}

- (void)searchInstantAnswers:(NSString *)query {
    if ([[self.instantAnswersQuery lowercaseString] isEqualToString:[query lowercaseString]])
        return;
    self.instantAnswersQuery = query;
    [self cleanupInstantAnswersTimer];
    if (query.length == 0) {
        self.instantAnswers = [NSArray array];
        [self didLoadInstantAnswers];
    } else {
        self.instantAnswersTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadInstantAnswers:) userInfo:nil repeats:NO];
    }
}

- (void)fireInstantAnswersTimer {
    if (instantAnswersTimer) {
        [instantAnswersTimer fire];
        [instantAnswersTimer invalidate];
        self.instantAnswersTimer = nil;
    }
}

- (void)loadInstantAnswers:(NSTimer *)timer {
    loadingInstantAnswers = YES;
    self.instantAnswers = [NSArray array];
    [self willLoadInstantAnswers];
    // It's a combined search, remember?
    [[UVSession currentSession] trackInteraction:@"sf"];
    [[UVSession currentSession] trackInteraction:@"si"];
    [UVArticle getInstantAnswers:self.instantAnswersQuery delegate:self];
}

- (void)loadInstantAnswers {
    [self loadInstantAnswers:nil];
}

- (void)selectInstantAnswerAtIndex:(int)index {
    id model = [self.instantAnswers objectAtIndex:index];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        [[UVSession currentSession] trackInteraction:@"cf" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:article.articleId], @"id", self.instantAnswersQuery, @"t", nil]];
        UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article helpfulPrompt:articleHelpfulPrompt returnMessage:articleReturnMessage] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        [[UVSession currentSession] trackInteraction:@"ci" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:suggestion.suggestionId], @"id", self.instantAnswersQuery, @"t", nil]];
        UVSuggestionDetailsViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    }
}

- (UIBarButtonItem *)barButtonItem:(NSString *)label withAction:(SEL)selector {
    return [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(label, @"UserVoice", nil)
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:selector] autorelease];
}

- (void)addSpinnerAndXTo:(UIView *)view atCenter:(CGPoint)center {
    UIImageView *x = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_x.png"]] autorelease];
    x.center = center;
    x.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    x.tag = TICKET_VIEW_X_TAG;
    [view addSubview:x];
    
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    spinner.center = center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    spinner.tag = TICKET_VIEW_SPINNER_TAG;
    [spinner startAnimating];
    [view addSubview:spinner];
}

- (void)updateSpinnerAndXIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated {
    UILabel *label = (UILabel *)[view viewWithTag:TICKET_VIEW_IA_LABEL_TAG];
    UIView *spinner = [view viewWithTag:TICKET_VIEW_SPINNER_TAG];
    UIView *x = [view viewWithTag:TICKET_VIEW_X_TAG];
    if ([instantAnswers count] > 0)
      label.text = [self instantAnswersFoundMessage:toggled];
    void (^update)() = ^{
        if (loadingInstantAnswers) {
            spinner.layer.opacity = 1.0;
            x.layer.opacity = 0.0;
        } else {
            spinner.layer.opacity = 0.0;
            x.layer.opacity = toggled ? 1.0 : 0.0;
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.3 animations:update];
    } else {
        update();
    }
}

- (void)addSpinnerAndArrowTo:(UIView *)view atCenter:(CGPoint)center {
    UIImageView *arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uv_arrow.png"]] autorelease];
    arrow.center = center;
    arrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    arrow.tag = TICKET_VIEW_ARROW_TAG;
    [view addSubview:arrow];
    
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    spinner.center = center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    spinner.tag = TICKET_VIEW_SPINNER_TAG;
    [spinner startAnimating];
    [view addSubview:spinner];
}

- (void)updateSpinnerAndArrowIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated {
    UILabel *label = (UILabel *)[view viewWithTag:TICKET_VIEW_IA_LABEL_TAG];
    UIView *spinner = [view viewWithTag:TICKET_VIEW_SPINNER_TAG];
    UIView *arrow = [view viewWithTag:TICKET_VIEW_ARROW_TAG];
    if ([instantAnswers count] > 0)
      label.text = [self instantAnswersFoundMessage:toggled];
    void (^update)() = ^{
        if (loadingInstantAnswers) {
            spinner.layer.opacity = 1.0;
            arrow.layer.opacity = 0.0;
        } else {
            spinner.layer.opacity = 0.0;
            arrow.layer.opacity = 1.0;
            if (toggled) {
                arrow.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                arrow.layer.transform = CATransform3DIdentity;
            }
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.3 animations:update];
    } else {
        update();
    }
}

- (NSString *)instantAnswersFoundMessage:(BOOL)toggled {
    BOOL foundArticles = NO;
    BOOL foundIdeas = NO;
    for (id answer in instantAnswers) {
        if ([answer isKindOfClass:[UVArticle class]])
            foundArticles = YES;
        else if ([answer isKindOfClass:[UVSuggestion class]])
            foundIdeas = YES;
    }
    if (foundArticles && foundIdeas)
        return toggled ? NSLocalizedStringFromTable(@"Matching articles and ideas", @"UserVoice", nil) : NSLocalizedStringFromTable(@"View matching articles and ideas", @"UserVoice", nil);
    else if (foundArticles)
        return toggled ? NSLocalizedStringFromTable(@"Matching articles", @"UserVoice", nil) : NSLocalizedStringFromTable(@"View matching articles", @"UserVoice", nil);
    else if (foundIdeas)
        return toggled ? NSLocalizedStringFromTable(@"Matching ideas", @"UserVoice", nil) : NSLocalizedStringFromTable(@"View matching ideas", @"UserVoice", nil);
    else
        return @"";
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index {
    cell.backgroundColor = [UIColor whiteColor];
    id model = [instantAnswers objectAtIndex:index];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        cell.textLabel.text = article.question;
        cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        cell.textLabel.text = suggestion.title;
        cell.imageView.image = [UIImage imageNamed:@"uv_idea.png"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
}

- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers {
    self.instantAnswers = [theInstantAnswers subarrayWithRange:NSMakeRange(0, MIN(3, [theInstantAnswers count]))];
    loadingInstantAnswers = NO;
    [self didLoadInstantAnswers];
    
    // This seems like the only way to do justice to tracking the number of results from the combined search
    NSMutableArray *articleIds = [NSMutableArray arrayWithCapacity:[theInstantAnswers count]];
    for (id answer in theInstantAnswers) {
        if ([answer isKindOfClass:[UVArticle class]]) {
            [articleIds addObject:[NSNumber numberWithInt:[((UVArticle *)answer) articleId]]];
        }
    }
    [[UVSession currentSession] trackInteraction:[articleIds count] > 0 ? @"rfp" : @"rfz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[articleIds count]], @"count", articleIds, @"ids", nil]];
    
    NSMutableArray *suggestionIds = [NSMutableArray arrayWithCapacity:[theInstantAnswers count]];
    for (id answer in theInstantAnswers) {
        if ([answer isKindOfClass:[UVSuggestion class]]) {
            [suggestionIds addObject:[NSNumber numberWithInt:[((UVSuggestion *)answer) suggestionId]]];
        }
    }
    [[UVSession currentSession] trackInteraction:[suggestionIds count] > 0 ? @"rip" : @"riz" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[suggestionIds count]], @"count", suggestionIds, @"ids", nil]];
}

- (void)cleanupInstantAnswersTimer {
    [instantAnswersTimer invalidate];
    self.instantAnswersTimer = nil;
}

- (void)dealloc {
    [self cleanupInstantAnswersTimer];
    self.instantAnswers = nil;
    self.instantAnswersQuery = nil;
    self.articleHelpfulPrompt = nil;
    self.articleReturnMessage = nil;
    [super dealloc];
}

@end
