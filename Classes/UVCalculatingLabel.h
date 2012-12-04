//
//  UVCalculatingLabel.h
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UVCalculatingLabel : UILabel

- (CGFloat)effectiveWidth;
- (NSArray *)breakString;
- (CGRect)rectForLetterAtIndex:(NSUInteger)index;

@end
