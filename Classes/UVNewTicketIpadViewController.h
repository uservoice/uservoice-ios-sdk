//
//  UVNewTicketIpadViewController.h
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseTicketViewController.h"

@class UVCustomField;

@interface UVNewTicketIpadViewController : UVBaseTicketViewController {
    BOOL showInstantAnswers;
    BOOL showInstantAnswersMessage;
    int instantAnswersCount;
}

@end
