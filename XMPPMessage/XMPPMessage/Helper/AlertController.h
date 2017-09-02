//
//  AlertController.h
//  XMPPMessage
//
//  Created by wht on 2017/8/31.
//  Copyright © 2017年 wht. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertController : NSObject

+ (AlertController *_Nullable)shareManager;

- (UIAlertController *)alertControllerWithTitle:(NSString *_Nullable)title message:(NSString *_Nullable)message preferredStyle:(UIAlertControllerStyle)preferredStyle acceptTitle:(NSString *_Nullable)acceptTitle accepthandler:(void (^ __nullable)(UIAlertAction * _Nullable action))accepthandler rejecttitle:(NSString *_Nullable)rejecttitle rejecthandler:(void (^ __nullable)(UIAlertAction * _Nullable action))rejecthandler;

- (UIViewController *_Nullable)getCurrentVC;

@end
