//
//  UVSubject.h
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"


@interface UVSubject : UVBaseModel {
	NSInteger subjectId;
	NSString *text;
}

@property (assign) NSInteger subjectId;
@property (nonatomic, retain) NSString *text;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
