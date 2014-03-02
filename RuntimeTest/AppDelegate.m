//
//  AppDelegate.m
//  RuntimeTest
//
//  Created by yaozhuoyu on 14-2-28.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "AppDelegate.h"
#import "Cat.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    UIViewController *viewController = [[UIViewController alloc] init];
    [self.window setRootViewController:viewController];
    [self.window makeKeyAndVisible];
    [self testExample];
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
    NSLog(@"mCat class %@, mCat class %@", [mCat class], [mCat superclass]);
    //result :
    /*
      cat class Cat, super class Animal
     */
    
    NSLog(@"Cat class %@, %p  mCat class %@, %p", [Cat class], [Cat class], [mCat class], [mCat class]);
    //Cat class Cat, 0x55748  mCat class Cat, 0x55748, 相同的
    
    
    [mCat printClassInfo];
    [mCat printClassLevelInfo];
    [mCat printSuperClassLevelInfo];
    [mCat printMetaSuperClassLevelInfo];
}

@end
