//
//  UVStatus.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"


@interface UVStatus : UVBaseModel {
	NSInteger statusId;
	NSString *name;
}

@property (assign) NSInteger statusId;
@property (nonatomic, retain) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
