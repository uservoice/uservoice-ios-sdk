//
//  UVTruncatingLabel.h
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVCalculatingLabel.h"

@protocol UVTruncatingLabelDelegate;

@interface UVTruncatingLabel : UVCalculatingLabel

@property (nonatomic, retain) NSString *fullText;
@property (nonatomic, retain) UILabel *moreLabel;
@property (nonatomic, weak) id<UVTruncatingLabelDelegate> delegate;

- (void)expand;

@end

@protocol UVTruncatingLabelDelegate <NSObject>
- (void)labelExpanded:(UVTruncatingLabel *)label;
@end
