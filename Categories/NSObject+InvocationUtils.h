//
//  NSObject+InvocationUtils.h
//  HTTPRiot
//
//  Created by Justin Palmer on 6/25/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (InvocationUtils)
- (void)performSelectorOnMainThread:(SEL)selector withObjects:(id)obj1, ...;
- (void)performSelectorOnMainThread:(SEL)selector withObjectArray:(NSArray *)objects;
@end
