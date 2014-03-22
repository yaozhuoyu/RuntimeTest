//
//  BaseObject.h
//  RuntimeTest
//
//  Created by 姚卓禹 on 14-3-15.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseObject : NSObject{
    NSString *antherString;
}

@property (nonatomic, strong) NSString *oneString;

@end

/*
@interface SubObject : BaseObject

@property (nonatomic, strong) NSString *twoString;

@end
*/