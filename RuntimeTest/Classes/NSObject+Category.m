//
//  NSObject+Category.m
//  RuntimeTest
//
//  Created by yaozhuoyu on 14-4-1.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "NSObject+Category.h"
#import <objc/runtime.h>

@implementation NSObject (Category)

- (Class)rt_class
{
    return object_getClass(self);
}

- (void)instanceMethod
{
    NSLog(@"self instanMaetod %@", self);
}

@end
