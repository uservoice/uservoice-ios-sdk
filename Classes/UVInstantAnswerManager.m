//
//  UVInstantAnswerManager.m
//  UserVoice
//
//  Created by Austin Taylor on 10/17/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVInstantAnswerManager.h"

@implementation UVInstantAnswerManager

@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSString *runningQuery;

- (void)setSearchText:(NSString *)newText {
    if ([_searchText.lowercaseString isEqualToString:newText.lowercaseString]) {
        return;
    }
    [_searchText release];
    _searchText = [newText retain];
    [self invalidateTimer];
    if (_searchText == nil || _searchText.length == 0) {
        self.instantAnswers = self.ideas = self.articles = [NSArray array];
        [_delegate didLoadInstantAnswers];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doSearch:) userInfo:nil repeats:NO];
    }
}

- (void)search {
    [_timer fire];
    [self invalidateTimer];
}

- (void)invalidateTimer {
    [_timer invalidate];
    self.timer = nil;
}

- (void)doSearch:(NSTimer *)timer {
    _loading = YES;
    self.runningQuery = _searchText;
    [UVDeflection setSearchText:_searchText];
    [UVArticle getInstantAnswers:_searchText delegate:self];
}

- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers {
    self.instantAnswers = theInstantAnswers;
    self.ideas = [theInstantAnswers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@", [UVSuggestion class]]];
    self.articles = [theInstantAnswers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@", [UVArticle class]]];
    _loading = NO;
    [self didLoadInstantAnswers];
    
    NSMutableArray *articleIds = [NSMutableArray arrayWithCapacity:_articles.count];
    for (id answer in _articles) {
        [articleIds addObject:@(((UVArticle *)answer).articleId)];
    }
    [UVBabayaga track:SEARCH_ARTICLES searchText:_runningQuery ids:articleIds];
    
    NSMutableArray *ideaIds = [NSMutableArray arrayWithCapacity:_ideas.count];
    for (id answer in _ideas) {
        [ideaIds addObject:@(((UVSuggestion *)answer).suggestionId)];
    }
    [UVBabayaga track:SEARCH_IDEAS searchText:_runningQuery ids:ideaIds];
    // note: UVDeflection should be called later with the actual objects displayed to the user
}

- (void)dealloc {
    [self invalidateTimer];
    self.instantAnswers = nil;
    self.ideas = nil;
    self.articles = nil;
    self.searchText = nil;
    self.runningQuery = nil;
    [super dealloc];
}

@end
