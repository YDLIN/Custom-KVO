//
//  NSObject+KVO.m
//  KVO
//
//  Created by Du on 2018/4/24.
//  Copyright © 2018年 Du. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/message.h>

@implementation NSObject (KVO)
- (void)ot_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    //1.动态创建Person子类
    NSString *superClassName = NSStringFromClass([self class]);
    NSString *subClassName = [@"OTKVONotifying_" stringByAppendingString:superClassName];
    /*
     * 参数一：添加的这个子类的父类
     * 参数二：添加的这个子类的名字
     * 参数三：传0即可
     */
    Class subClass = objc_allocateClassPair([self class], subClassName.UTF8String, 0);
    //2.注册新创建的类
    objc_registerClassPair(subClass);
    
    //3.修改调用者的类型（Person->OTKVONotifying_Person）
    object_setClass(self, subClass);
    
    /* 4.重写setMoney:方法（给子类添加方法）
     * 参数一：给哪个类添加方法
     * 参数二：SEL方法编号
     * 参数三：IMP方法实现
     * 参数四：类型编码
     此参数可以参考官方文档：https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
     */
    class_addMethod(subClass, NSSelectorFromString(@"setMoney:"), (IMP)setMoney, "v@:i");
    
    /* 5.将观察者绑定到对象上
     * 参数一：给哪个对象绑定属性
     * 参数二：常量指针，用来标识
     * 参数三：给对象绑定什么
     * 参数四：OBJC_ASSOCIATION_ASSIGN类似属性里面的weak关键字，
     因为这里的observer是ViewController，而在ViewController在外面又持有p对象，
     所以为了防止引用循环，所以p对象绑定observer的时候使用OBJC_ASSOCIATION_ASSIGN
     */
    objc_setAssociatedObject(self, (__bridge const void *)@"bindObserver", observer, OBJC_ASSOCIATION_ASSIGN);
    
    //6.添加getter,这一步是为了能获取到修改属性前的旧值
    objc_setAssociatedObject(self, (__bridge const void *)@"getter", keyPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

/* 子类添加的方法的实现
 * id self 方法调用者（必不可少）
 * SEL _cmd 方法编号（必不可少）
 * newValue 就是调用该方法时，传递的参数，这里就是表示即将给money属性赋值的新值
 */
void setMoney(id self, SEL _cmd, int newValue) {
    //1、获取旧值
    NSString *getterName = objc_getAssociatedObject(self, (__bridge const void *)@"getter");
    //保存子类类型（OTKVONotifying_Person）
    Class class = [self class];
    //self的”is a“指向父类（Person）
    object_setClass(self, class_getSuperclass(class));
    //调用原类get方法，获取oldValue
    //
    /*
     int 代表返回类型/对象类型需要加*号，如NSString *(*)(id, SEL)
     (*)代表函数指针，相当于block的(^)
     (id, SEL)是参数列表，参数列表可以传多个。id是消息接收方，这里是Person类，SEL是需要调用的方法选择器，也就是这里的NSSelectorFromString(getterName)
     */
    int oldValue = ((int (*)(id, SEL))objc_msgSend)((id)self, NSSelectorFromString(getterName));
    
    //self的”is a“指向子类（OTKVONotifying_Person）
    object_setClass(self, class);
    
    /* 2、调用Person的setter去修改money的值
         结构体的声明：
         struct objc_super {
             id receiver;
             Class super_class;
         };
         receiver: 类型为id的指针。指定类的实例。
         super_class: 指向Class数据结构的指针。 指定要消息的实例的父类。
     */
    struct objc_super person = {
        self,
        class_getSuperclass([self class])
    };
    objc_msgSendSuper(&person, _cmd, newValue);
    
    //3、通知监听者（传递新旧值）
    //3.1、通过对象拿到监听者
    id observer = objc_getAssociatedObject(self, (__bridge const void *)@"bindObserver");
    //3.2、给observer发送消息(这里一定要传参数，不然会崩溃的)
    objc_msgSend(observer, @selector(observeValueForKeyPath:ofObject:change:context:), @"money", self, @{@"ot_old":@(oldValue),@"ot_new":@(newValue)},nil);
}
@end
