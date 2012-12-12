//
//  UVBaseInstantAnswersViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/26/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"

#define TICKET_VIEW_ARROW_TAG 1000
#define TICKET_VIEW_SPINNER_TAG 1001
#define TICKET_VIEW_X_TAG 1002
#define TICKET_VIEW_IA_LABEL_TAG 1003

#define HIGHLIGHTING_LABEL_TAG 100

#define IA_FILTER_ALL 0
#define IA_FILTER_ARTICLES 1
#define IA_FILTER_IDEAS 2

@interface UVBaseInstantAnswersViewController : UVBaseViewController {
    NSTimer *instantAnswersTimer;
    NSArray *instantAnswers;
    NSString *instantAnswersQuery;
    NSString *articleHelpfulPrompt;
    NSString *articleReturnMessage;
    NSRegularExpression *searchPattern;
    BOOL loadingInstantAnswers;
    int filter;
}

@property (nonatomic,retain) NSTimer *instantAnswersTimer;
@property (nonatomic,retain) NSArray *instantAnswers;
@property (nonatomic,retain) NSString *instantAnswersQuery;
@property (nonatomic,retain) NSString *articleHelpfulPrompt;
@property (nonatomic,retain) NSString *articleReturnMessage;
@property (nonatomic,retain) NSRegularExpression *searchPattern;
@property (assign) int filter;

- (void)selectInstantAnswerAtIndex:(int)index;
- (void)initCellForInstantAnswer:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index;
- (void)addSpinnerAndXTo:(UIView *)view atCenter:(CGPoint)center;
- (void)updateSpinnerAndXIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated;
- (UIBarButtonItem *)barButtonItem:(NSString *)label withAction:(SEL)selector;
- (NSString *)instantAnswersFoundMessage:(BOOL)toggled;
- (int)maxInstantAnswerResults;

/**
 * Reset the instant answers timer for 0.5 seconds
 */
- (void)searchInstantAnswers:(NSString *)query;

/**
 * Query for instant answers immediately
 * Set instantAnsewrsQuery before calling
 */
- (void)loadInstantAnswers;

/**
 * Callback called before loading instant answers
 */
- (void)willLoadInstantAnswers;

/**
 * Callback called after loading instant answers
 */
- (void)didLoadInstantAnswers;

/**
 * Remove the timer and free memory
 */
- (void)cleanupInstantAnswersTimer;

/**
 * Force the timer to fire immediately, if set
 */
- (void)fireInstantAnswersTimer;

/**
 * Process loaded instant answers
 * This is here so that subclasses can no-op it if needed
 */
- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers;

@end
