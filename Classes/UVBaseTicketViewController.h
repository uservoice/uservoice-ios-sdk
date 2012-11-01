//
//  UVBaseTicketViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"
#import "UVTextView.h"

#define TICKET_VIEW_ARROW_TAG 1000
#define TICKET_VIEW_SPINNER_TAG 1001

@interface UVBaseTicketViewController : UVBaseViewController<UITextViewDelegate> {
    NSString *text;
    UVTextView *textView;
    NSTimer *timer;
    NSArray *instantAnswers;
    BOOL loadingInstantAnswers;
}

@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) UVTextView *textView;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSArray *instantAnswers;
@property (assign) BOOL loadingInstantAnswers;

- (id)initWithText:(NSString *)theText;
- (void)selectInstantAnswerAtIndex:(int)index;
- (void)customizeCellForInstantAnswer:(UITableViewCell *)cell index:(int)index;
- (void)addSpinnerAndArrowTo:(UIView *)view atCenter:(CGPoint)center;
- (void)updateSpinnerAndArrowIn:(UIView *)view withToggle:(BOOL)toggled animated:(BOOL)animated;
- (NSString *)instantAnswersFoundMessage;

- (void)willLoadInstantAnswers;
- (void)didLoadInstantAnswers;

@end
