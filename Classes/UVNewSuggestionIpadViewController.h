//
//  UVNewSuggestionIpadViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/30/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseSuggestionViewController.h"

@interface UVNewSuggestionIpadViewController : UVBaseSuggestionViewController<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    BOOL showInstantAnswers;
    BOOL showInstantAnswersMessage;
    int instantAnswersCount;
}

@end
