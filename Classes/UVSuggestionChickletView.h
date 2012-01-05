//
//  UVSuggestionChickletView.h
//  UserVoice
//
//  Created by UserVoice on 1/15/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	UVSuggestionChickletStyleLight,
	UVSuggestionChickletStyleDark,
	UVSuggestionChickletStyleDetail,
	UVSuggestionChickletStyleEmpty
} UVSuggestionChickletStyle;

@class UVSuggestion;

@interface UVSuggestionChickletView : UIView {
	CALayer *statusColorLayer;
	UIImageView *backgroundImageView;	
	UILabel *voteNumLabel;
	UILabel *voteLabel;
	UILabel *statusLabel;
}

@property (nonatomic, retain) CALayer *statusColorLayer;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UILabel *voteNumLabel;
@property (nonatomic, retain) UILabel *voteLabel;
@property (nonatomic, retain) UILabel *statusLabel;

+ (CGFloat)heightForView;
+ (CGFloat)widthForView;
+ (UVSuggestionChickletView *)suggestionChickletViewWithOrigin:(CGPoint)origin;

- (id)initWithOrigin:(CGPoint)origin;
- (void)updateWithSuggestion:(UVSuggestion *)suggestion style:(UVSuggestionChickletStyle)style;

@end
