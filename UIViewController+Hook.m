//
//  UIViewController+Hook.m
//  HookDylib
//
//  Created by xindong on 17/7/19.
//  Copyright © 2017年 xindong. All rights reserved.
//

#import "UIViewController+Hook.h"
#import <objc/runtime.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static NSInteger const kTextViewIdentifier = 201707190343;

@implementation UIViewController (Hook)

#pragma mark -

- (void)xd_viewDidLoad {
    [self xd_viewDidLoad];
    
    BOOL invalidateVC1 = [self isKindOfClass:[UINavigationController class]];
    BOOL invalidateVC2 = [self isKindOfClass:[UITabBarController class]];
    BOOL invalidateVC3 = [self isKindOfClass:[UIInputViewController class]];
    BOOL invalidateVC4 = [self isKindOfClass:NSClassFromString(@"UIInputWindowController")];
    BOOL invalidateVC5 = [self isKindOfClass:[UIAlertController class]];
    
    BOOL invalidateViewController = invalidateVC1 || invalidateVC2 || invalidateVC3 || invalidateVC4 || invalidateVC5;
    
    if (invalidateViewController) {
        return;
    }
    
    UITextView *textView = [UITextView new];
    textView.frame = (CGRect){0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64};
    textView.editable = NO;
    textView.tag = kTextViewIdentifier;
    textView.text = [self xd_printCurrentViewControllerNameAndIvar];
    [[UIApplication sharedApplication].keyWindow addSubview:textView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(xd_clickedToDismissTextView:)];
    [textView addGestureRecognizer:tap];
}


- (NSString *)xd_printCurrentViewControllerNameAndIvar {
    NSString *currentClassName = [NSString stringWithFormat:@" currentClassName: %@\n", NSStringFromClass([self class])];
    NSMutableString *text = [currentClassName mutableCopy];
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar _ivar = ivars[i];
        const char *_ivarCN = ivar_getName(_ivar);
        const char *_ivarType = ivar_getTypeEncoding(_ivar);
        NSString *ivarName = [NSString stringWithUTF8String:_ivarCN];
        NSString *ivarType = [NSString stringWithUTF8String:_ivarType];
        [text appendFormat:@"%@", [NSString stringWithFormat:@"\n ivarName: %@  type: %@", ivarName, ivarType]];
    }
    return text;
}

- (void)xd_clickedToDismissTextView:(UITapGestureRecognizer *)tap {
    [[UIApplication sharedApplication].keyWindow.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UITextView class]] && obj.tag == kTextViewIdentifier) {
            [obj removeFromSuperview];
            obj = nil;
        }
    }];
}


#pragma mark - Method Swizzling

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self xd_exchangeOriginSelector:@selector(viewDidLoad) newSelector:@selector(xd_viewDidLoad)];
    });
}

+ (void)xd_exchangeOriginSelector:(SEL)selectorOrigin newSelector:(SEL)selectorNew {
    Class _Class = [self class];
    
    Method methodOrigin = class_getInstanceMethod(_Class, selectorOrigin);
    Method methodNew = class_getInstanceMethod(_Class, selectorNew);
    
    IMP impOrigin = method_getImplementation(methodOrigin);
    IMP impNew = method_getImplementation(methodNew);
    
    BOOL isAdd = class_addMethod(_Class, selectorOrigin, impNew, method_getTypeEncoding(methodNew));
    if (isAdd) {
        class_addMethod(_Class, selectorNew, impOrigin, method_getTypeEncoding(methodOrigin));
    } else {
        method_exchangeImplementations(methodOrigin, methodNew);
    }
}

@end
