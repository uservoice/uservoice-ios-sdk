//
//  UIView+UVExtras.m
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UIView+UVExtras.h"

@implementation UIView (UVExtras)

- (CGFloat)width {
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

- (CGFloat)height {
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

- (NSString*)listColor:(UIColor*) color
{
	int r = 0, g = 0, b = 0;
	CGFloat alpha = 1.0;
	CGFloat* colors;
	if (color) {
		colors = (CGFloat *) CGColorGetComponents(color.CGColor);
		if (colors) {
			r = (int) (255 * colors[0]);
			g = (int) (255 * colors[1]);
			b = (int) (255 * colors[2]);
			alpha = colors[3];
		}
	}
    return [NSString stringWithFormat:@"r:%d g:%d b:%d a:%.2f", r, g, b, alpha];	
}

- (void)describeText:(NSMutableString*)str view:(UIView *)v indent:(int)level
{	
	CGFloat bx = 0.0, by = 0.0, bw = 0.0, bh = 0.0;
	CGFloat fx = 0.0, fy = 0.0, fw = 0.0, fh = 0.0;
	CGFloat cx = 0.0, cy = 0.0;
	NSString *indentString1 = [[NSString stringWithString:@""] stringByPaddingToLength:level withString:@"+" startingAtIndex:0];
	NSString *indentString2 = [[NSString stringWithString:@""] stringByPaddingToLength:level+2 withString:@" " startingAtIndex:0];
	
	if (v) {
		CGRect bd = v.bounds;
		bx = bd.origin.x;
		by = bd.origin.y;
		bw = bd.size.width;
		bh = bd.size.height;
		CGRect fd = v.frame;
		fx = fd.origin.x;
		fy = fd.origin.y;
		fw = fd.size.width;
		fh = fd.size.height;
		cx = v.center.x;
		cy = v.center.y;
		
		[str appendFormat:@"+%@ %s retain:%d - tag:%d - bgcolor:(%@)\n"
		 @"%@ bounds: x:%.0f y:%.0f w:%.0f h:%.0f - frame: x:%.0f y:%.0f w:%.0f h:%.0f - center: x:%.0f, y:%.0f\n", 
		 indentString1, [v class], v.retainCount, v.tag, [self listColor:v.backgroundColor],
		 indentString2, bx, by, bw, bh, fx, fy, fw, fh, cx, cy];
		
		if ([v isKindOfClass:[UILabel class]]) {
			UILabel* label = (UILabel*) v;
			if (label.text)
				[str appendFormat:@"%@ text (len:%d - color:%@): '%@'\n", indentString2, [label.text length], 
				 [self listColor:label.textColor],
				 label.text];
		} else
			if ([v isKindOfClass:[UITextField class]]) {
				UITextField* tf = (UITextField*) v;
				if (tf.text)
					[str appendFormat:@"%@ text (len:%d - color:%@): '%@'\n", indentString2, [tf.text length], 
					 [self listColor:tf.textColor],
					 tf.text];
			}
	} else {
		[str appendFormat:@"%@--null--\n"];
	}
}

- (NSString *)describeOne:(NSMutableString *)result view:(UIView*)view indent:(int)level
{
	[self describeText:result view:view indent:level];
	
	for (UIView* subview in view.subviews) {
		[self describeOne:result view:subview indent:level+1];
	}
	return result;
}

- (NSString *)description {
	UIView* topView = (UIView *) self;
	int	indentLevel = 0;
	NSMutableString* result = [[[NSMutableString alloc] init] autorelease];
	
	[self describeOne:result view:topView indent:indentLevel];
	return result;
}

@end
