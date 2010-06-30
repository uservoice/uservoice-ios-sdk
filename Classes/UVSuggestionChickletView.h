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

}

+ (CGFloat)heightForView;
+ (CGFloat)widthForView;
+ (UVSuggestionChickletView *)suggestionChickletViewWithOrigin:(CGPoint)origin;

- (id)initWithOrigin:(CGPoint)origin;
- (void)updateWithSuggestion:(UVSuggestion *)suggestion style:(UVSuggestionChickletStyle)style;

@end
