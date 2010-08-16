//
//  UVStream.h
//  UserVoice
//
//  Created by Scott Rutherford on 11/08/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVForum;

@interface UVStreamEvent : UVBaseModel {
	// 2 streams per forum, public and private	
	NSString *type;
	NSDictionary *object;
}

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDictionary *object;

+ (id)publicForForum:(UVForum *)theForum andDelegate:(id)delegate since:(NSDate *)aDateOrNil;
+ (id)privateForForum:(UVForum *)theForum andDelegate:(id)delegate since:(NSDate *)aDateOrNil;

@end
