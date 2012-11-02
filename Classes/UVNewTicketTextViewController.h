//
//  UVNewTicketTextViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseTicketViewController.h"
#import "UVNewTicketViewController.h"

@interface UVNewTicketTextViewController : UVBaseTicketViewController<UITableViewDataSource, UITableViewDelegate> {
    BOOL showInstantAnswersMessage;
    BOOL userHasSeenInstantAnswers;
    BOOL keyboardHidden;
    UIView *instantAnswersMessage;
    UVNewTicketViewController *ticketViewController;
}

@property (nonatomic,retain) UIView *instantAnswersMessage;
@property (nonatomic,retain) UVNewTicketViewController *ticketViewController;

@end
