//
//  UVCustomField.h
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@interface UVCustomField : UVBaseModel {
	NSInteger subjectId;
	NSString *name;
}

@property (assign) NSInteger subjectId;
@property (nonatomic, retain) NSString *name;

+ (id)getCustomFieldsWithDelegate:(id)delegate;
- (id)initWithDictionary:(NSDictionary *)dict;

@end
