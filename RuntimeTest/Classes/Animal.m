//
//  Animal.m
//  RuntimeTest
//
//  Created by yaozhuoyu on 14-2-28.
//  Copyright (c) 2014年 yzy. All rights reserved.
//

#import "Animal.h"
#import <objc/runtime.h>
#import "NSObject+Category.h"
#import "Animal+Category.h"

@protocol AnimalTestDelegate <NSObject>

@optional
- (void)animalTestDelegateMethod1;

@end

@interface Animal(addMetod)
- (void)addMethod;
+ (void)addClassMethod;
@end

@interface Animal()<AnimalTestDelegate>

@end

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


///////////////////////////////////////////////////
- (void)getClassListTest
{
    Class *buffer = NULL;
    int count, size;
    
    count = objc_getClassList(NULL, 0);
    buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
    size = objc_getClassList(buffer, count);
    
    NSLog(@"当前runtime中class的数目 %d",count);
    
    free(buffer);
}

//获取子类
- (NSArray *)rt_subclasses
{
    Class *buffer = NULL;
    
    int count, size;
    do
    {
        count = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size = objc_getClassList(buffer, count);
    } while(size != count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < count; i++)
    {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while(superclass)
        {
            superclass = class_getSuperclass(superclass);
            if(superclass == [self class])
            {
                [array addObject: candidate];
                break;
            }
            
        }
    }
    free(buffer);
    return array;
}

//添加子类
- (void)addSubClass
{
    char *subClassName = "Bird";  //当subClassName的名字和Cat一样的时候，会创建失败，返回Nil
    Class _addSubClass = objc_allocateClassPair([self class], subClassName, 0);
    
    if (_addSubClass) {
        objc_registerClassPair(_addSubClass);
        
        id subClass = [[NSClassFromString([NSString stringWithCString:subClassName encoding:NSASCIIStringEncoding]) alloc] init];
        NSLog(@"创建了一个子类，为 %@", subClass);
    }
    
    //Destroys a class and its associated metaclass.
    //objc_disposeClassPair(_addSubClass);
}

- (void)testMetaClass
{
    NSLog(@"[Animal class] isMetaClass %d", class_isMetaClass([Animal class]));
    //[Animal class] isMetaClass 0
    NSLog(@"[self class] isMetaClass %d", class_isMetaClass([self class]));
    //[self class] isMetaClass 0
    NSLog(@"object_getClass([Animal class]) %d",class_isMetaClass(object_getClass([Animal class])));
    //object_getClass([Animal class]) 1
}

- (void)testMethod
{
    unsigned int count;
    Method *methods = class_copyMethodList([self class], &count);
    
    //Method不是一个对象，是一个struct，不能直接加入到NSMutableArray中
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++){
        Method mth = methods[i];
        NSValue *value = [NSValue valueWithBytes:&mth objCType:@encode(Method)];
        [array addObject:value];
    }
    free(methods);
    
    
    
    SEL sel = @selector(testMethod);
    NSUInteger index = [array indexOfObjectPassingTest: ^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        Method objMehod;
        [obj getValue:&objMehod];
        return method_getName(objMehod) == sel;
    }];
    
    Method method;
    NSValue *value = [array objectAtIndex: index];
    [value getValue:&method];
    
    NSLog(@"[method implementation] == [NSObject instanceMethodForSelector: sel] %d", method_getImplementation(method) == [Animal instanceMethodForSelector: sel]);
    
    NSString *sigString = [NSString stringWithUTF8String: method_getTypeEncoding(method)];
    
    NSLog(@"[[NSMethodSignature signatureWithObjCTypes: [[method signature] UTF8String]] isEqual: [NSObject instanceMethodSignatureForSelector: sel]]  %d", [[NSMethodSignature signatureWithObjCTypes: [sigString UTF8String]] isEqual: [Animal instanceMethodSignatureForSelector: sel]]);

}

static void addMethodImp(id self, SEL _cmd)
{
    NSLog(@" add Mehod Imp");
}

- (void)testAddMethod
{
    class_addMethod([self class], @selector(addMethod), (IMP)addMethodImp, "v@:");
    [self addMethod];
    
    class_addMethod(object_getClass([self class]), @selector(addClassMethod), (IMP)addMethodImp, "v@:");
    [Animal addClassMethod];
}

- (void)methodForSetTestA
{
    NSLog(@"****methodForSetTestA");
}

- (void)methodForSetTestB
{
    NSLog(@"****methodForSetTestB");
}

- (void)testSetMethod
{
    Method methodA =  class_getInstanceMethod([self class], @selector(methodForSetTestA));
    Method methodB =  class_getInstanceMethod([self class], @selector(methodForSetTestB));
//    IMP originTestAImp = [self methodForSelector:@selector(methodForSetTestA)];
//    IMP originTestBImp = [self methodForSelector:@selector(methodForSetTestB)];
    IMP originTestAImp = method_getImplementation(methodA);
    IMP originTestBImp = method_getImplementation(methodB);
    
    method_setImplementation(methodA, originTestBImp);
    [self methodForSetTestA];
    
    method_setImplementation(methodA, originTestAImp);
    [self methodForSetTestA];
    [self methodForSetTestB];
}


- (void)testProtocols
{
    unsigned int count;
    Protocol *__unsafe_unretained* protocols = class_copyProtocolList([self class], &count);
    
    for (NSUInteger index = 0; index < count; index ++) {
        Protocol *pc = protocols[index];
        NSLog(@"protocol name %s", protocol_getName(pc));
        
        unsigned int pCount;
        //Returns an array of the protocols adopted by a protocol.
        Protocol *__unsafe_unretained *cps = protocol_copyProtocolList(pc, &pCount);
        for (NSUInteger jndex = 0; jndex < pCount; jndex++) {
            Protocol *pc = cps[index];
            NSLog(@"protocol protocol name %s", protocol_getName(pc));
        }
        
    }
    
    free(protocols);
    
    
}





























@end
