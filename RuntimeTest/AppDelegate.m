//
//  AppDelegate.m
//  RuntimeTest
//
//  Created by yaozhuoyu on 14-2-28.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "AppDelegate.h"
#import "Cat.h"
#import "SubObject.h"
#import "Cat+eat.h"
#import <objc/runtime.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    UIViewController *viewController = [[UIViewController alloc] init];
    [self.window setRootViewController:viewController];
    [self.window makeKeyAndVisible];
    //[self testExample];
    //[self testMethodFroward];
    //[self testClassInherit];
    [self runtimeFunctionTest];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - test
- (void)testExample
{
    Cat *mCat = [[Cat alloc] init];
//    NSLog(@"mCat class %@, mCat class %@", [mCat class], [mCat superclass]);
//    //result :
//    /*
//      cat class Cat, super class Animal
//     */
//    
//    NSLog(@"Cat class %@, %p  mCat class %@, %p", [Cat class], [Cat class], [mCat class], [mCat class]);
    //Cat class Cat, 0x55748  mCat class Cat, 0x55748, 相同的

//    [mCat printClassInfo];
//    [mCat printClassLevelInfo];
//    [mCat printSuperClassLevelInfo];
//    [mCat printMetaSuperClassLevelInfo];
    
    
    //print method info
    [mCat printMethodList];
    [mCat eatFish];
    [mCat callEatFinishMethod];
}

- (void)testClassInherit
{
    BaseObject *baseObj = [[BaseObject alloc] init];
    baseObj.oneString = @"one String";
    SubObject *subObj = [[SubObject alloc] init];
    subObj.twoString = @"two String";
    
    NSLog(@"%@ \n %@", baseObj, subObj);
}

- (void)testMethodFroward
{
    Cat *mCat = [[Cat alloc] init];
    NSMethodSignature *callEatFinishSg = [mCat methodSignatureForSelector:@selector(callEatFinishMethod)];
    NSLog(@"methodSignatureForSelector---- callEatFinishSg: %@", callEatFinishSg);
    callEatFinishSg = [Cat instanceMethodSignatureForSelector:@selector(callEatFinishMethod)];
    NSLog(@"instanceMethodSignatureForSelector---- callEatFinishSg: %@", callEatFinishSg);
    
    //上面两个结果一样的。
    
    
    Animal *animal = [[Animal alloc] init];
    mCat = (Cat *)animal;
    [mCat callEatFinishMethod];
    
    /*
     当methodSignatureForSelector返回一个nil的时候，是不会调用forwardInvocation的。methodSignatureForSelector的默认实现调用的super。
     */
}


- (void)runtimeFunctionTest
{
    Animal *an = [[Animal alloc] init];
    [an getClassListTest];
    //当前runtime中class的数目 4371
    
    //获取animal的子类
    NSArray *subArr = [an rt_subclasses];
    NSLog(@"animal的子类有 ：%@", subArr);
    //Cat
    
    [an addSubClass];
    subArr = [an rt_subclasses];
    NSLog(@"现在animal的子类有 ：%@", subArr);
    //Cat,Bird
    
    [an testMetaClass];
    
    NSLog(@"sizeof(void *)  %lu, NSObject size : %lu, Animal size : %lu, Cat size : %lu", sizeof(void *), class_getInstanceSize([NSObject class]), class_getInstanceSize([Animal class]), class_getInstanceSize([Cat class]));
    //sizeof(void *)  4, NSObject size : 4, Animal size : 16, Cat size : 20
    
    [an testMethod];
    [an testAddMethod];
    [an testSetMethod];
    [an testProtocols];
    
}

@end
