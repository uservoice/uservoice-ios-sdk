//
//  NSObject+InvocationUtils.m
//  HTTPRiot
//
//  Created by Justin Palmer on 6/25/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import "NSObject+InvocationUtils.h"


@implementation NSObject (InvocationUtils)
- (void)performSelectorOnMainThread:(SEL)selector withObjects:(id)obj1, ... {
    id argitem; va_list args;
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    if(obj1 != nil) {
        [objects addObject:obj1];
        va_start(args, obj1);         
        
        while (argitem = va_arg(args, id)) {
            [objects addObject:argitem];               
        }
        
        va_end(args);
    }
    
    [self performSelectorOnMainThread:selector withObjectArray:objects];
    [objects release];
}

- (void)performSelectorOnMainThread:(SEL)selector withObjectArray:(NSArray *)objects {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if(signature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:selector];
        
        for(size_t i = 0; i < objects.count; ++i) {
            id obj = [objects objectAtIndex:i];
            [invocation setArgument:&obj atIndex:(i + 2)];
        }
        
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];   
    }
}
@end
