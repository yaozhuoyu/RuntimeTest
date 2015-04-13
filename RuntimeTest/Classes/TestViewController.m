//
//  TestViewController.m
//  RuntimeTest
//
//  Created by 姚卓禹 on 15/4/13.
//  Copyright (c) 2015年 yzy. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self testSuperClass];
}

- (void)testSuperClass{
    NSObject *obj1 = [[NSObject alloc] init];
    NSLog(@"[obj1 class] %@(%p), [NSObject class] %@(%p)", [obj1 class], [obj1 class], [NSObject class], [NSObject class]);
    NSError *error1 = [[NSError alloc] initWithDomain:@"11" code:11 userInfo:nil];
    NSLog(@"[error1 class] %@(%p), [NSError class] %@(%p)", [error1 class], [error1 class], [NSError class], [NSError class]);
    /*
     2015-04-13 19:06:46.873 RuntimeTest[6465:1229031] [obj1 class] NSObject(0x199fec0a0), [NSObject class] NSObject(0x199fec0a0)
     2015-04-13 19:06:46.874 RuntimeTest[6465:1229031] [error1 class] NSError(0x19694e4c0), [NSError class] NSError(0x19694e4c0)
     相同，都是class对象，就是图中第二竖排对应
     */
    
    NSLog(@"[[NSObject class] class] %@(%p)", [[NSObject class] class], [[NSObject class] class]);
    /*
     和上面打印相同，不管class多少层，都是一样的
     */
    
    /////////////////////////////////////////////
    NSLog(@"objc_getClass obj %@(%p)", objc_getClass(object_getClassName(obj1)), objc_getClass(object_getClassName(obj1)));
    NSLog(@"objc_getClass class %@(%p)", objc_getClass(object_getClassName([NSObject class])), objc_getClass(object_getClassName([NSObject class])));
    
    
}

@end
