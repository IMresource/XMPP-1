//
//  CHUserInformation.h
//  EXchatxmpp
//
//  Created by wht on 2017/8/19.
//  Copyright © 2017年 wht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@interface CHUserInformation : NSObject
@property   (nonatomic,strong)XMPPJID *jid;
@property   (nonatomic,strong)NSString *name;
@property   (nonatomic,strong)NSString *imageNameStr;
@property   (nonatomic,strong)NSString *statue;//状态
@property   (nonatomic,strong)NSString *group;
@property   (nonatomic,strong)UIImage *image;
@property (nonatomic, assign) int  unreadMessages;
@property   (nonatomic,strong)NSMutableArray *messageArr;
- (void)createUser:(XMPPElement *)element;
@end
