//
//  BaseObject.m
//  RuntimeTest
//
//  Created by 姚卓禹 on 14-3-15.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "BaseObject.h"

@implementation BaseObject

@synthesize oneString = prviteStr;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, privateStr %@", NSStringFromClass([self class]), prviteStr];
}

@end

/*
@implementation SubObject

@synthesize twoString = prviteStr;

@end
 */