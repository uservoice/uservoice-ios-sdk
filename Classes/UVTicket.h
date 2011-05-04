//
//  UVTicket.h
//  UserVoice
//
//  Created by Scott Rutherford on 26/04/2011.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVSubject;

@interface UVTicket : UVBaseModel {    
}

+ (id)createWithSubject:(NSString *)subject
                message:(NSString *)message
               delegate:(id)delegate;

@end
