//
//  Animal.m
//  RuntimeTest
//
//  Created by yaozhuoyu on 14-2-28.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "Animal.h"

@implementation Animal

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    NSLog(@"**** methodSignatureForSelector %@", methodSignature);
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSLog(@"forwardInvcation ---");
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    
}

@end
