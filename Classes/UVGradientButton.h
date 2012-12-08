//
//  UVGradientButton.h
//  UserVoice
//
//  Created by Austin Taylor on 11/26/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
       green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
        blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UVGradientButton : UIButton {
    CALayer *highlight;
}

@end
