//
//  HRBase64.h
//  HTTPRiot
//
//  Created by Justin Palmer on 7/2/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//
//  This was taken from Cyrus' Public Domain implementation on the bottom of 
//  http://www.cocoadev.com/index.pl?BaseSixtyFour.
//
#import <Foundation/Foundation.h>


@interface HRBase64 : NSObject {

}
+ (NSString*) encode:(NSData*)rawBytes;
@end
