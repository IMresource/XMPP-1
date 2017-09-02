//
//  AlertController.m
//  XMPPMessage
//
//  Created by wht on 2017/8/31.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "AlertController.h"

@implementation AlertController

+ (AlertController *)shareManager{
    static AlertController * alert;
    static dispatch_once_t onceToKen;
    dispatch_once(&onceToKen, ^{
        alert = [[AlertController alloc] init];
    });
    return alert;
}

- (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle acceptTitle:(NSString *)acceptTitle accepthandler:(void (^ __nullable)(UIAlertAction *action))accepthandler rejecttitle:(NSString *)rejecttitle rejecthandler:(void (^ __nullable)(UIAlertAction *action))rejecthandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:acceptTitle style:UIAlertActionStyleDefault handler:accepthandler];
    [alertController addAction:acceptAction];
    
    if (rejecttitle.length > 0) {
        UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:rejecttitle style:UIAlertActionStyleCancel handler:rejecthandler];
        [alertController addAction:rejectAction];
    }
    
    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
    return alertController;
    
}

#pragma mark - 获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }else{
        result = window.rootViewController;
    }
    return result;
}


@end
