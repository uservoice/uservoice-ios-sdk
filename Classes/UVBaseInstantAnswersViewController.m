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
#import "UVHighlightingLabel.h"

#define HIGHLIGHTING_LABEL_TAG 100

@implementation UVBaseInstantAnswersViewController

@synthesize instantAnswersTimer;
@synthesize instantAnswers;
@synthesize instantAnswersQuery;
@synthesize articleHelpfulPrompt;
@synthesize articleReturnMessage;
@synthesize searchPattern;

- (void)willLoadInstantAnswers {
}

- (void)didLoadInstantAnswers {
}

- (void)updatePattern {
    NSRegularExpression *termPattern = [NSRegularExpression regularExpressionWithPattern:@"\\b\\w+\\b" options:0 error:nil];
    NSMutableString *pattern = [NSMutableString stringWithString:@"\\b("];
    NSString *query = instantAnswersQuery;
    __block NSString *lastTerm = nil;
    [termPattern enumerateMatchesInString:query options:0 range:NSMakeRange(0, [query length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        if (lastTerm) {
            [pattern appendString:lastTerm];
            [pattern appendString:@"|"];
        }
        lastTerm = [query substringWithRange:[match range]];
    }];
    if (lastTerm) {
        [pattern appendString:lastTerm];
        [pattern appendString:@")"];
        self.searchPattern = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    } else {
        self.searchPattern = nil;
    }
}

- (void)searchInstantAnswers:(NSString *)query {
    if ([[self.instantAnswersQuery lowercaseString] isEqualToString:[query lowercaseString]])
        return;
    self.instantAnswersQuery = query;
    [self updatePattern];
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
    [self updatePattern];
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

- (void)initCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UVHighlightingLabel *label = [[[UVHighlightingLabel alloc] initWithFrame:CGRectMake(IPAD ? 75 : 50, 12, cell.bounds.size.width - (IPAD ? 130 : 80), 20)] autorelease];
    label.numberOfLines = 2;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:13.0];
    label.tag = HIGHLIGHTING_LABEL_TAG;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index {
    id model = [instantAnswers objectAtIndex:index];
    UVHighlightingLabel *label = (UVHighlightingLabel *)[cell viewWithTag:HIGHLIGHTING_LABEL_TAG];
    label.pattern = searchPattern;
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        label.text = article.question;
        cell.imageView.image = [UIImage imageNamed:@"uv_article.png"];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        label.text = suggestion.title;
        cell.imageView.image = [UIImage imageNamed:@"uv_idea.png"];
    }
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
    self.searchPattern = nil;
    [super dealloc];
}

@end
