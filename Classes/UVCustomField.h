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
    NSString *name;
    NSArray *values;
    NSInteger fieldId;
    BOOL required;
}

@property (assign) NSInteger fieldId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *values;

- (id)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isPredefined;
- (BOOL)isRequired;

@end
