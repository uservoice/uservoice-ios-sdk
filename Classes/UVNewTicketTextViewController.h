//
//  UVNewTicketTextViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseTicketViewController.h"

@interface UVNewTicketTextViewController : UVBaseTicketViewController<UITableViewDataSource, UITableViewDelegate> {
    BOOL showInstantAnswersMessage;
    BOOL userHasSeenInstantAnswers;
    BOOL keyboardHidden;
    UIView *instantAnswersMessage;
}

@property (nonatomic,retain) UIView *instantAnswersMessage;

@end
