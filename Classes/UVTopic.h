//
//  UVTopic.h
//  UserVoice
//
//  Created by Rich Collins on 4/28/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@interface UVTopic : UVBaseModel {
	NSString *example;
	NSString *prompt;
	NSInteger votesAllowed;
	NSInteger votesRemaining;
	NSInteger suggestionsCount;
	
	NSMutableArray *categories;
	NSMutableArray *suggestions;
	BOOL suggestionsNeedReload;
}

@property (nonatomic, retain) NSString *example;
@property (nonatomic, retain) NSString *prompt;
@property (nonatomic, assign) NSInteger votesAllowed;
@property (nonatomic, assign) NSInteger votesRemaining;
@property (nonatomic, assign) NSInteger suggestionsCount;

@property (assign) BOOL suggestionsNeedReload;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSMutableArray *suggestions;

@end
