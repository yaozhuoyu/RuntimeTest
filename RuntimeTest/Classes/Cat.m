//
//  Cat.m
//  RuntimeTest
//
//  Created by 姚卓禹 on 14-3-2.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "Cat.h"
#import <objc/runtime.h>

@implementation Cat

- (void)printClassInfo{
    /*
     1.打印isa 信息
    */
    //direct access to Objective-C isa is deprecated in favor of object_getClass()
    //NSLog(@"cat isa is %@", self->isa);
    
    NSLog(@"**** cat object isa is %@", object_getClass(self));
    //**** cat object isa is Cat
    
    /*
     2.打印self super 信息
     */
    NSLog(@"**** cat self class is %@ %p, super class is %@ %p", [self class], [self class], [super class], [super class]);
    //**** cat self class is Cat, super class is Cat
    //打印结果一样的，详细解释请看：http://www.cocoachina.com/macdev/objc/2011/0124/2602.html
}

- (void)printClassLevelInfo{
    //实例的class
    Class instanceClass = object_getClass(self);
    Class metaClass = object_getClass(instanceClass);
    
    NSLog(@"==== instanceClass is %@  %p, metaClass is %@  %p", instanceClass, instanceClass, metaClass, metaClass);
    
    //类的class
    Class methodClass = [Cat class];
    Class classClass =object_getClass(methodClass);
    NSLog(@"==== methodClass is %@  %p, class class is %@ %p", methodClass, methodClass, classClass, classClass);
    //结论：instanceClass的地址等于methodClass classClass等于metaClass
    //其实instanceClass 为类对象，而metaClass为元类（metaclass）
    
    
    Class metaClassClass = object_getClass(metaClass);
    NSLog(@"==== metaClassClass is %@  %p", metaClassClass, metaClassClass);
    Class nsobjectMetaClass = object_getClass([NSObject class]);
    NSLog(@"==== nsobjectMetaClass is %@  %p", nsobjectMetaClass, nsobjectMetaClass);
    //结论 ：任何元类的class都是NSObject的元类
    
}

- (void)printSuperClassLevelInfo{
    Class instanceClass = object_getClass(self);
    Class sClass = class_getSuperclass(instanceClass);
    Class ssClass = class_getSuperclass(sClass);
    Class sssClass = class_getSuperclass(ssClass);
    
    NSLog(@"++++ class is %@ %p, class name %s", instanceClass, instanceClass, object_getClassName(instanceClass));
    NSLog(@"++++ Superclass is %@ %p, class name %s", sClass, sClass, object_getClassName(sClass));
    NSLog(@"++++ SuperSuperclass is %@ %p, class name %s", ssClass, ssClass, object_getClassName(ssClass));
    NSLog(@"++++ SuperSuperSuperclass is %@ %p, class name %s", sssClass, sssClass, object_getClassName(sssClass));
    /*
     ++++ class is Cat 0x50748, class name Cat
     ++++ Superclass is Animal 0x50784, class name Animal
     ++++ SuperSuperclass is NSObject 0x3cc05f94, class name NSObject
     ++++ SuperSuperSuperclass is (null) 0x0, class name nil
    */
}

- (void)printMetaSuperClassLevelInfo{
    Class instanceClass = object_getClass(self);
    Class metaClass = object_getClass(instanceClass);
    
    Class sClass = class_getSuperclass(metaClass);
    Class ssClass = class_getSuperclass(sClass);
    Class sssClass = class_getSuperclass(ssClass);
    Class ssssClass = class_getSuperclass(sssClass);
    
    NSLog(@"---- metaClass is %@ %p, class name %s", metaClass, metaClass, object_getClassName(metaClass));
    NSLog(@"---- Superclass is %@ %p, class name %s", sClass, sClass, object_getClassName(sClass));
    NSLog(@"---- SuperSuperclass is %@ %p, class name %s", ssClass, ssClass, object_getClassName(ssClass));//其为NSObject的元类
    NSLog(@"---- SuperSuperSuperclass is %@ %p, class name %s", sssClass, sssClass, object_getClassName(sssClass));
    NSLog(@"---- SuperSuperSuperSuperclass is %@ %p, class name %s", ssssClass, ssssClass, object_getClassName(ssssClass));
    
    /*
     ---- metaClass is Cat 0x5075c, class name NSObject
     ---- Superclass is Animal 0x50770, class name NSObject
     ---- SuperSuperclass is NSObject 0x3cc05fa8, class name NSObject
     ---- SuperSuperSuperclass is NSObject 0x3cc05f94, class name NSObject
     ---- SuperSuperSuperSuperclass is (null) 0x0, class name nil
     */
}

- (void)callEatFinishMethod
{
    //[self eatFish];
}
//
//- (void)eatFish
//{
//    NSLog(@"cat eat fish at class");
//}

- (void)printMethodList
{
    /*
     1.category的方法eatFish也会在此方法列表中
     2.如果类的内部也有一个eatFish方法，则方法列表中会有两个eatFish
     3.在写过category之后，所有的调用eatFish方法，都是调用category的实现
     4.经过测试，在load方法和initialize方法中打印方法列表，和在之后打印的结果一样，可见在load的时候category已经加载进来。
    */
    unsigned int count;
    Method *methods = class_copyMethodList([self class], &count);
    NSLog(@"%@ class has %d mehod", [self class], count);
    
    for (int index = 0; index < count; index++) {
        Method currentMethod = methods[index];
        SEL methodSEL = method_getName(currentMethod);
        NSLog(@"%d : %s",index, sel_getName(methodSEL));
    }
    
    free(methods);
}

@end
