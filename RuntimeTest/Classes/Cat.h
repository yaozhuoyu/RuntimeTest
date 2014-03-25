//
//  Cat.h
//  RuntimeTest
//
//  Created by 姚卓禹 on 14-3-2.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "Animal.h"

@interface Cat : Animal

@property (nonatomic, strong) NSString *food;

- (void)printClassInfo;
- (void)printClassLevelInfo;
- (void)printSuperClassLevelInfo;
- (void)printMetaSuperClassLevelInfo;

- (void)printMethodList;

- (void)callEatFinishMethod;


@end
