//
//  Animal.h
//  RuntimeTest
//
//  Created by yaozhuoyu on 14-2-28.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Animal : NSObject

@property (nonatomic, strong, readonly) NSString *anName;
@property (nonatomic, assign) NSUInteger anAge;
@property (nonatomic, strong) NSArray *anArray;


- (void)getClassListTest;
- (NSArray *)rt_subclasses;

- (void)addSubClass;

- (void)testMetaClass;

- (void)testMethod;

- (void)testAddMethod;

- (void)testSetMethod;

- (void)testProtocols;

- (void)testIvars;

- (void)testProperty;

- (void)testAddProperty;
@end
