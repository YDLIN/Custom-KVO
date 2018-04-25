//
//  NSObject+KVO.h
//  KVO
//
//  Created by Du on 2018/4/24.
//  Copyright © 2018年 Du. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KVO)
- (void)ot_addObserver:(NSObject *_Nullable)observer forKeyPath:(NSString *_Nullable)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
@end
