//
//  UVImageView.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UVURLImageResponse

@synthesize image = _image;

- (id)init {
	if (self = [super init]) {
		_image = nil;
	}
	return self;
}

- (void)dealloc {
	[_image release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLResponse

- (NSError*)request:(TTURLRequest*)request 
	processResponse:(NSHTTPURLResponse*)response
			   data:(id)data {
	if ([data isKindOfClass:[UIImage class]]) {
		_image = [data retain];
		
	} else if ([data isKindOfClass:[NSData class]]) {
		UIImage *image = [UIImage imageWithData:data];

		if (image) {
			_image = [image retain];
		} else {
			return [NSError errorWithDomain:@"uservoice.com" 
									   code:101
								   userInfo:nil];
		}
	}
	return nil;
}

@end

@implementation UVImageView

@synthesize URL = _URL, image = _image, defaultImage = _defaultImage;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_request = nil;
		_URL = nil;
		_image = nil;
		_defaultImage = nil;
	}
	return self;
}

- (void)dealloc {
	[_request cancel];
	[_request release];
	[_URL release];
	[_image release];
	[_defaultImage release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	if (_image) {
		[_image drawInRect:rect];
	} else {
		[_defaultImage drawInRect:rect];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
	[_request release];
	_request = [request retain];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	UVURLImageResponse* response = request.response;
	self.image = response.image;
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {

}

- (void)requestDidCancelLoad:(TTURLRequest*)request {

}

///////

- (void)setURL:(NSString*)URL {
	if (self.image && _URL && [URL isEqualToString:_URL])
		return;
	
	[self stopLoading];
	[_URL release];
	_URL = [URL retain];
	
	if (!_URL || !_URL.length) {
		if (self.image != _defaultImage) {
			self.image = _defaultImage;
		}
	} else {
		[self reload];
	}
}

- (void)setImage:(UIImage*)image {
	if (image != _image) {
		[_image release];
		_image = [image retain];
	}
}

- (BOOL)isLoading {
	return !!_request;
}

- (BOOL)isLoaded {
	return self.image && self.image != _defaultImage;
}

- (void)reload {
	if (!_request && _URL) {
		TTURLRequest* request = [TTURLRequest requestWithURL:_URL delegate:self];
		request.response = [[[UVURLImageResponse alloc] init] autorelease];
		
		if (_URL && ![request send]) {
			// Put the default image in place while waiting for the request to load
			if (_defaultImage && self.image != _defaultImage) {
				self.image = _defaultImage;
			}
		}
	}
}

- (void)stopLoading {
	[_request cancel];
}

@end

