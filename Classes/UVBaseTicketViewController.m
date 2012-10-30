//
//  UVBaseTicketViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseTicketViewController.h"
#import "UVSession.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVArticleViewController.h"
#import "UVSuggestionDetailsViewController.h"

@implementation UVBaseTicketViewController

@synthesize text;
@synthesize timer;
@synthesize textView;
@synthesize instantAnswers;
@synthesize loadingInstantAnswers;

- (id)initWithText:(NSString *)theText {
    if (self = [self init]) {
        self.text = theText;
    }
    return self;
}

- (void)willLoadInstantAnswers {
}

- (void)didLoadInstantAnswers {
}

- (void)textViewDidChange:(UVTextView *)theTextEditor {
    if (self.text == self.textView.text)
        return;
    self.text = self.textView.text;
    [self.timer invalidate];
    if (self.textView.text.length == 0) {
        self.instantAnswers = [NSArray array];
        [self didLoadInstantAnswers];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadInstantAnswers:) userInfo:nil repeats:NO];
    }
}

- (void)loadInstantAnswers:(NSTimer *)timer {
    self.loadingInstantAnswers = YES;
    self.instantAnswers = [NSArray array];
    [self willLoadInstantAnswers];
    // It's a combined search, remember?
    [[UVSession currentSession] trackInteraction:@"sf"];
    [[UVSession currentSession] trackInteraction:@"si"];
    [UVArticle getInstantAnswers:self.textView.text delegate:self];
}

- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers {
    self.instantAnswers = theInstantAnswers;
    self.loadingInstantAnswers = NO;
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


- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    id model = [self.instantAnswers objectAtIndex:indexPath.row];
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

- (void)selectInstantAnswerAtIndex:(int)index {
    id model = [self.instantAnswers objectAtIndex:index];
    if ([model isMemberOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        [[UVSession currentSession] trackInteraction:@"cf" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:article.articleId], @"id", self.textView.text, @"t", nil]];
        UVArticleViewController *next = [[[UVArticleViewController alloc] initWithArticle:article] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        [[UVSession currentSession] trackInteraction:@"ci" details:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:suggestion.suggestionId], @"id", self.textView.text, @"t", nil]];
        UVSuggestionDetailsViewController *next = [[[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion] autorelease];
        [self.navigationController pushViewController:next animated:YES];
    }
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    self.instantAnswers = nil;
    self.textView = nil;
    self.text = nil;
    [super dealloc];
}

@end
