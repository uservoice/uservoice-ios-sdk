//
//  UVResponseDelegate.h
//  UserVoice
//
//  Created by UserVoice on 10/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRiot.h"


@interface UVResponseDelegate : NSObject <HRResponseDelegate> {
	Class modelClass;
	NSInteger statusCode;
}

@property (assign) Class modelClass;

- (id)initWithModelClass:(Class)clazz;

@end
