//
//  UVImageView.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVImageView.h"
#import "UVImageCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation UVImageView

@synthesize URL = _URL, image = _image, defaultImage = _defaultImage, payload = _payload, connection = _connection;

- (void)drawRect:(CGRect)rect {
	if (_image) {
		[_image drawInRect:rect];
	} else {
		[_defaultImage drawInRect:rect];
	}
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
        [[UVImageCache sharedInstance] setImage:self.image forURL:_URL];
	}
    
    self.connection = nil;
    self.payload = nil;
	//NSLog(@"Connection finished: %@", conn);
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {	
    self.payload = nil;
    self.connection = nil;
}

- (void)setURL:(NSString*)URL {
	if (self.image && _URL && [URL isEqualToString:_URL])
		return;
	
	[self stopLoading];
	[_URL release];
	_URL = [URL retain];
	
	if (_URL && _URL.length) {
        self.image = [[UVImageCache sharedInstance] imageForURL:_URL];
        [self setNeedsDisplay];
        if (!self.image)
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
	if (_URL) {
		NSURL *url = [NSURL URLWithString:_URL];		
		NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        
        [self stopLoading];
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
		
		if (_connection) {
			self.payload = [NSMutableData data];
			self.image = nil;
		} else {
			NSLog(@"Unable to start download.");
		}
	}
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
    self.payload = nil;
}

- (void)dealloc {
    [self stopLoading];
    self.URL = nil;
    self.image = nil;
    self.defaultImage = nil;
	[super dealloc];
}

@end
