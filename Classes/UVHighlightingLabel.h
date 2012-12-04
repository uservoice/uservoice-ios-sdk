//
//  UVHighlightingLabel.h
//  UserVoice
//
//  Created by Austin Taylor on 11/29/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVCalculatingLabel.h"

@interface UVHighlightingLabel : UVCalculatingLabel {
    NSRegularExpression *pattern;
}

@property (nonatomic, retain) NSRegularExpression *pattern;

@end
