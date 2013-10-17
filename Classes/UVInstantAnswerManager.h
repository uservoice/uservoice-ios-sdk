//
//  UVInstantAnswerManager.h
//  UserVoice
//
//  Created by Austin Taylor on 10/17/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UVInstantAnswersDelegate
/*
 * Called whenever there are new instant answer results
 */
- (void)didUpdateInstantAnswers; 
@end

@interface UVInstantAnswerManager : NSObject

@property (nonatomic,assign) id<UVInstantAnswersDelegate> delegate;
@property (nonatomic,assign) BOOL loading;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSString *runningQuery;

/*
 * An array of interleaved ideas and articles
 */
@property (nonatomic,retain) NSArray *instantAnswers;

/*
 * Just the ideas
 */
@property (nonatomic,retain) NSArray *ideas;

/*
 * Just the articles
 */
@property (nonatomic,retain) NSArray *articles;

/*
 * Text for searching
 * The search will execute 0.5 seconds after this has been changed,
 * unless it is updated again within that time.
 */
@property (nonatomic,retain) NSString *searchText;


/*
 * Call this to force the search to execute immediately
 */
- (void)search;

@end

