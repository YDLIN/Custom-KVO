//
//  ViewController.m
//  KVO
//
//  Created by Du on 2018/4/24.
//  Copyright © 2018年 Du. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NSObject+KVO.h"

@interface ViewController ()
@property (strong, nonatomic) Person *p;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Person *p = [[Person alloc] init];
//    [p addObserver:self forKeyPath:@"money" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [p ot_addObserver:self forKeyPath:@"money" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    /*
     如果不重写class,这里是返回OTKVONotifying_Person
     */
    NSLog(@"%@",[p class]);
    _p = p;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@对象的%@属性被修改了。----%@",object, keyPath, change);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static int i = 0;
    i++;
    self.p.money = i;
}

- (void)dealloc {
    [self.p removeObserver:self forKeyPath:@"money"];
}
@end
