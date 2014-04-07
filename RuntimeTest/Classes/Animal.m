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
- (id)optionalAnimalTestDelegateMethod:(int)obj;
@required
- (void)requireAnimalTestDelegateMethod;

@end

@interface Animal(addMetod)
- (void)addMethod;
+ (void)addClassMethod;
@end

@interface Animal()<AnimalTestDelegate>
{
    id  obj_;
    CGRect rect;
    CGFloat along;
}

@end

@implementation Animal

#pragma mark -
#pragma mark - AnimalTestDelegate

- (void)requireAnimalTestDelegateMethod
{
    NSLog(@"********requireAnimalTestDelegateMethod");
}


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
    objc_disposeClassPair(_addSubClass);
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
        NSLog(@"testMethod %d, method name %@", i, NSStringFromSelector(method_getName(mth)));
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
        
        [self printProtocolMethod:pc];
        
        //获取协议满足的协议
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

- (void)printProtocolMethod:(Protocol *)pr
{
    BOOL isRequiredMethod = NO;
    BOOL isInstanceMethod = YES;
    unsigned int count;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(pr, isRequiredMethod, isInstanceMethod, &count);
    
    for(unsigned i = 0; i < count; i++)
    {
        NSString *signature = [NSString stringWithCString: methods[i].types encoding: [NSString defaultCStringEncoding]];
        NSLog(@"pr %s %i: methods description type: %@, sel: %@", protocol_getName(pr),i, signature, NSStringFromSelector(methods[i].name));
        //pr AnimalTestDelegate 0: methods description type: @12@0:4i8, sel: optionalAnimalTestDelegateMethod:
    }
    
    free(methods);
}


- (void)testIvars
{
    NSLog(@"/////////////////////////////////////////////////////////////////////");
    unsigned int count;
    Ivar *list = class_copyIvarList([self class], &count);
    
    for (unsigned i = 0; i < count; i++) {
        Ivar ivar = list[i];
        //ptrdiff_t是signed类型，用于存放同一数组中两个指针之间的差距
        NSLog(@"ivar %d : name %s\t typeEncoding %s\t  offset %td \t",i, ivar_getName(ivar), ivar_getTypeEncoding(ivar), ivar_getOffset(ivar));
    }
    
    free(list);
    
    /*
     2014-04-05 10:30:24.786 RuntimeTest[11809:60b] ivar 0 : name obj_	 typeEncoding @	  offset 4
     2014-04-05 10:30:24.787 RuntimeTest[11809:60b] ivar 1 : name rect	 typeEncoding {CGRect="origin"{CGPoint="x"f"y"f}"size"{CGSize="width"f"height"f}}	  offset 8
     2014-04-05 10:30:24.789 RuntimeTest[11809:60b] ivar 2 : name along	 typeEncoding f	  offset 24
     2014-04-05 10:30:24.790 RuntimeTest[11809:60b] ivar 3 : name _anName	 typeEncoding @"NSString"	  offset 28
     2014-04-05 10:30:24.791 RuntimeTest[11809:60b] ivar 4 : name _anAge	 typeEncoding I	  offset 32
     2014-04-05 10:30:24.792 RuntimeTest[11809:60b] ivar 5 : name _anArray	 typeEncoding @"NSArray"	  offset 36
     */
    
    NSLog(@"@encode(id) %s, @encode(CGRect) %s,  @encode(Animal) %s ,@encode(NSString) %s", @encode(id), @encode(CGRect), @encode(Animal), @encode(NSString));
    NSLog(@"@encode(NSString *) %@", [NSString stringWithUTF8String:@encode(NSString)]);
    
    /*
     2014-04-05 10:37:03.572 RuntimeTest[11833:60b] @encode(id) @, @encode(CGRect) {CGRect={CGPoint=ff}{CGSize=ff}},  @encode(Animal) {Animal=#@{CGRect={CGPoint=ff}{CGSize=ff}}f@I@} ,@@encode(NSString) {NSString=#}
     2014-04-05 10:37:03.573 RuntimeTest[11833:60b] @encode(NSString *) {NSString=#}
    */
    
    
    NSLog(@"******log NSObject ivar");
    list = class_copyIvarList([NSObject class], &count);
    
    for (unsigned i = 0; i < count; i++) {
        Ivar ivar = list[i];
        //ptrdiff_t是signed类型，用于存放同一数组中两个指针之间的差距
        NSLog(@"ivar %d : name %s\t typeEncoding %s\t  offset %td \t",i, ivar_getName(ivar), ivar_getTypeEncoding(ivar), ivar_getOffset(ivar));
    }
    
    free(list);
}

- (void)testProperty
{
    NSLog(@"/////////////////////////////////////////////////////////////////////");
    unsigned int count;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    NSLog(@"current property num %d", count);
    
    for(unsigned i = 0; i < count; i++)
    {
        objc_property_t pro = list[i];
        NSLog(@"property name %s \t attributes %s", property_getName(pro), property_getAttributes(pro));
    }
    
    free(list);
    
    /*
     2014-04-05 10:51:17.217 RuntimeTest[11859:60b] current property num 3
     2014-04-05 10:51:17.218 RuntimeTest[11859:60b] property name anName 	 attributes T@"NSString",R,N,V_anName
     2014-04-05 10:51:17.219 RuntimeTest[11859:60b] property name anAge 	 attributes TI,N,V_anAge
     2014-04-05 10:51:17.220 RuntimeTest[11859:60b] property name anArray 	 attributes T@"NSArray",&,N,V_anArray
     
     其中对于attribute来说：
     The string starts with a T followed by the @encode type and a comma, and finishes with a V followed by the name of the backing instance variable. Between these, the attributes are specified by the following descriptors, separated by commas
     
     R表示是read only，C表示copy，&表示retain，N表示nonatomic
    */
}

- (void)testAddProperty
{
    //先添加变量
    /*
    NSString *ivarName = @"addIvar";
    const char *typeStr = @encode(NSString);
    
    //This function may only be called after objc_allocateClassPair and before objc_registerClassPair. Adding an instance variable to an existing class is not supported.
     
    NSUInteger size, alignment;
    NSGetSizeAndAlignment(typeStr, &size, &alignment);
    class_addIvar([self class], [ivarName UTF8String], size, log2(alignment), typeStr);
    */
    
    NSLog(@"//////////////////////////////////////////////");
    const char *subClassName = "Bird";  //当subClassName的名字和Cat一样的时候，会创建失败，返回Nil
    Class _addSubClass = objc_allocateClassPair([self class], subClassName, 0);
    
    if (_addSubClass) {
        
        //添加一个string变量
        NSString *ivarName = @"stringIvar1";
        const char *typeStr = @encode(NSString);
        
        
        //The instance variable's minimum alignment in bytes is 1<<align. The minimum alignment of an instance variable depends on the ivar's type and the machine architecture. For variables of any pointer type, pass log2(sizeof(pointer_type)).
        
        
        NSUInteger size, alignment;
        NSGetSizeAndAlignment(typeStr, &size, &alignment);
        
        BOOL ss = class_addIvar(_addSubClass, [ivarName UTF8String], size, log2(alignment), typeStr);
        NSLog(@"%@  size %d, alignment %d add sucess %d  log2 %f", ivarName, size, alignment, ss, log2(4));
        
        //再添加一个变量char
        ivarName = @"charIvar2";
        typeStr = @encode(char);
        NSGetSizeAndAlignment(typeStr, &size, &alignment);
        ss = class_addIvar(_addSubClass, [ivarName UTF8String], size, alignment, typeStr);
        NSLog(@"%@  size %d, alignment %d add sucess %d", ivarName, size, alignment, ss);
        
        //添加一个string变量
        ivarName = @"stringIvar2";
        typeStr = @encode(NSString);
        NSGetSizeAndAlignment(typeStr, &size, &alignment);
        ss = class_addIvar(_addSubClass, [ivarName UTF8String], size, log2(alignment), typeStr);
        NSLog(@"%@  size %d, alignment %d add sucess %d", ivarName, size, alignment, ss);
        
        objc_registerClassPair(_addSubClass);
        
        id subClass = [[NSClassFromString([NSString stringWithCString:subClassName encoding:NSASCIIStringEncoding]) alloc] init];
        NSLog(@"创建了一个子类，为 %@", subClass);
        
        NSLog(@"==== class_getInstanceSize %zu", class_getInstanceSize([subClass class]));
        
        unsigned int count;
        Ivar *list = class_copyIvarList([subClass class], &count);
        
        for (unsigned i = 0; i < count; i++) {
            Ivar ivar = list[i];
            //ptrdiff_t是signed类型，用于存放同一数组中两个指针之间的差距
            NSLog(@"ivar %d : name %s\t typeEncoding %s\t  offset %td \t",i, ivar_getName(ivar), ivar_getTypeEncoding(ivar), ivar_getOffset(ivar));
        }
        
        free(list);
    }
    
    
    
    
    //Destroys a class and its associated metaclass.
    objc_disposeClassPair(_addSubClass);
}




















@end
