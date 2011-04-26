//
//  UVImageView.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UVImageView

@synthesize URL = _URL, image = _image, defaultImage = _defaultImage;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_request = nil;
		_URL = nil;
		_image = nil;
		_defaultImage = nil;
        _connection = nil;
	}
	return self;
}

- (void)dealloc {
    [self stopLoading]; // cancels and releases connection, if any
	[_URL release];
	[_image release];
	[_defaultImage release];
	[_payload release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	if (_image) {
		[_image drawInRect:rect];
	} else {
		[_defaultImage drawInRect:rect];
	}
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	[_payload setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
	//NSLog(@"Recieving data. Incoming Size: %i  Total Size: %i", [data length], [_payload length]);	
	[_payload appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	//NSLog(@"Connection returned: %i", [_payload length]);
	UIImage *anImage = [UIImage imageWithData:_payload];
	//NSLog(@"Image: %@", anImage);
	
	if (anImage) {
		//NSLog(@"Calling image setter");
		self.image = anImage;
		[self setNeedsDisplay];
	}
    
	[conn release];	
    _connection = nil;
	//NSLog(@"Connection finished: %@", conn);
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {	
	[_payload setLength:0];
	[conn release];	
    _connection = nil;
}

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
		//NSLog(@"Setting image");
		[_image release];
		_image = [image retain];
	}
}

- (void)reload {
	if (!_request && _URL) {
		NSURL *url = [NSURL URLWithString:_URL];		
		_request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        
        [self stopLoading];
        _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
		
		if (_connection) {
			_payload = [[NSMutableData data] retain];
			//NSLog(@"Connection starting: %@", _connection);
			
			if (_defaultImage && self.image != _defaultImage) {
				self.image = _defaultImage;
			}
		} else {
			NSLog(@"Unable to start download.");
		}
	}
}

- (void)stopLoading {
	if (_connection) {
		[_connection cancel];
		[_connection release];
		_connection = nil;
    }
}

@end
