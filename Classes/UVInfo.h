//
//  UVInfo.h
//  UserVoice
//
//  Created by Scott Rutherford on 27/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@interface UVInfo : UVBaseModel {
	NSString *about_title;
	NSString *about_body;
	NSString *motivation_title;
	NSString *motivation_body;
	NSDictionary *management;
	NSDictionary *contacts;
}

@property (nonatomic, retain) NSString *about_title;
@property (nonatomic, retain) NSString *about_body;
@property (nonatomic, retain) NSString *motivation_title;
@property (nonatomic, retain) NSString *motivation_body;
@property (nonatomic, retain) NSDictionary *management;
@property (nonatomic, retain) NSDictionary *contacts;

+ (id)getWithDelegate:(id)delegate;

@end
