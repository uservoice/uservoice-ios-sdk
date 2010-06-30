//
//  UVMessage.h
//  UserVoice
//
//  Created by UserVoice on 2/19/10.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVSubject;

@interface UVMessage : UVBaseModel {
}

+ (id)createWithSubject:(UVSubject *)subject
				   text:(NSString *)text
		   delegate:(id)delegate;
	
@end
