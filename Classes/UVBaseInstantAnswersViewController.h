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

@interface UVBaseInstantAnswersViewController : UVBaseViewController {
    NSTimer *instantAnswersTimer;
    NSArray *instantAnswers;
    NSString *instantAnswersQuery;
    BOOL loadingInstantAnswers;
}

@property (nonatomic,retain) NSTimer *instantAnswersTimer;
@property (nonatomic,retain) NSArray *instantAnswers;
@property (nonatomic,retain) NSString *instantAnswersQuery;

- (void)selectInstantAnswerAtIndex:(int)index;
- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index;
- (void)addSpinnerAndXTo:(UIView *)view atCenter:(CGPoint)center;
- (void)updateSpinnerAndXIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated;
- (void)addSpinnerAndArrowTo:(UIView *)view atCenter:(CGPoint)center;
- (void)updateSpinnerAndArrowIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated;
- (NSString *)instantAnswersFoundMessage:(BOOL)toggled;
- (void)searchInstantAnswers:(NSString *)query;
- (void)loadInstantAnswers;
- (void)willLoadInstantAnswers;
- (void)didLoadInstantAnswers;
- (void)cleanupInstantAnswers;

@end
