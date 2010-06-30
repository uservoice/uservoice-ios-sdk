//
//  UVImageView.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "Three20/TTURLRequest.h"
#import "Three20/TTURLResponse.h"

@interface UVImageView : UIView <TTURLRequestDelegate> {
	TTURLRequest* _request;
	NSString* _URL;
	UIImage* _image;
	UIImage* _defaultImage;
}

@property(nonatomic,copy) NSString* URL;
@property(nonatomic,retain) UIImage* image;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,readonly) BOOL isLoading;
@property(nonatomic,readonly) BOOL isLoaded;

- (void)reload;
- (void)stopLoading;

@end


@interface UVURLImageResponse : NSObject <TTURLResponse> {
	UIImage* _image;
}

@property(nonatomic,readonly) UIImage* image;

@end