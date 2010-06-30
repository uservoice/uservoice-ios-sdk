//
//  UVImageView.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UVImageView : UIView {
	NSString* _URL;
	UIImage* _image;
	UIImage* _defaultImage;
	
	NSURLConnection *_connection;
	NSURLRequest *_request;
	NSMutableData *_payload;
}

@property(nonatomic,copy) NSString* URL;
@property(nonatomic,retain) UIImage* image;
@property(nonatomic,retain) UIImage* defaultImage;

- (void)reload;
- (void)stopLoading;

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)conn;
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error;

@end