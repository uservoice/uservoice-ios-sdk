//
//  UVCategory.h
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"


@interface UVCategory : UVBaseModel {
	NSInteger categoryId;
	NSString *name;
}

@property (assign) NSInteger categoryId;
@property (nonatomic, retain) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
