//
//  weibo.mm
//  weibo
//
//  Created by xindong on 17/3/22.
//  Copyright (c) 2017年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

CHDeclareClass(NSObject);
CHDeclareClass(WBCustomSource);
CHDeclareClass(WBMyWeiboSourceViewController);

#pragma mark - Hook Method

// WBCustomSource

CHOptimizedMethod1(self, void, WBCustomSource, setSourceName, NSString*, sourceName) {
    if ([sourceName isEqualToString:@"iPhone 6"]) {
        sourceName = @"iPhone 8";
    } else if ([sourceName isEqualToString:@"iPhone"]) {
        sourceName = @"iPhone 9";
    }
    CHSuper1(WBCustomSource, setSourceName, sourceName);
}



// WBMyWeiboSourceViewController

CHOptimizedMethod1(self, id, WBMyWeiboSourceViewController, getSourceNameById, id, sourceId) {
    return @"心董儿";
}


//CHOptimizedMethod0(self, void, WBMyWeiboSourceViewController, selectCustomWeiboSource) {
//    CHSuper0(WBMyWeiboSourceViewController, selectCustomWeiboSource);
//    WBCustomSource *selectedSource = (WBCustomSource *)[self valueForKey:@"selectedSouce"];
//    NSString *text = [NSString stringWithFormat:@"customName: %@\nisCustom: %zd\nisDefault: %zd\nisSelected: %zd\nisVip: %zd\nsourceId: %@\nsourceName: %@",
//                      [selectedSource valueForKey:@"customName"],
//                      [[selectedSource valueForKey:@"isCustom"] boolValue],
//                      [[selectedSource valueForKey:@"isDefault"] boolValue],
//                      [[selectedSource valueForKey:@"isSelected"] boolValue],
//                      [[selectedSource valueForKey:@"isVip"] boolValue],
//                      [selectedSource valueForKey:@"sourceId"],
//                      [selectedSource valueForKey:@"sourceName"]];
//    
//    UITextView *textView = [UITextView new];
//    textView.frame = (CGRect){0, 0, 200, 300};
//    textView.center = [UIApplication sharedApplication].keyWindow.center;
//    textView.text = text;
//    textView.tag = 20170720;
//    [[UIApplication sharedApplication].keyWindow addSubview:textView];
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_TapToDismiss:)
//                                   ];
//    [textView addGestureRecognizer:tap];
//}

//static void _TapToDismiss(UITapGestureRecognizer *tap) {
//    [[UIApplication sharedApplication].keyWindow.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj isKindOfClass:[UITextView class]] && obj.tag == 20170720) {
//            [obj removeFromSuperview];
//            obj = nil;
//        }
//    }];
//}
//
//CHOptimizedMethod1(self, BOOL, NSObject, resolveInstanceMethod, SEL, sel) {
//    if ([NSStringFromSelector(sel) isEqualToString:@"_TapToDismiss:"]) {
//        BOOL isAdd = class_addMethod(self, sel, (IMP)_TapToDismiss, "v@:@");
//        return isAdd;
//    }
//    return CHSuper1(NSObject, resolveInstanceMethod, sel);
//}


#pragma mark - Register Hook

CHConstructor
{
    @autoreleasepool
    {
        CHLoadLateClass(WBCustomSource);
        CHHook1(WBCustomSource, setSourceName);
        
        CHLoadLateClass(WBMyWeiboSourceViewController);
//        CHHook0(WBMyWeiboSourceViewController, selectCustomWeiboSource);
//        
//        CHLoadLateClass(NSObject);
//        CHHook1(NSObject, resolveInstanceMethod);
    }
}

