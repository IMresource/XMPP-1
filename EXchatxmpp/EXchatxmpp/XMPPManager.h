//
//  XMPPManager.h
//  EXchatxmpp
//
//  Created by wht on 2017/8/19.
//  Copyright © 2017年 wht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

#define kLoginSuccess @"登录成功"
#define kRegistSuccess @"注册成功"
#define kRosterLoder @"刷新好友列表"
#define kShowMessage @"刷新消息"
#define kMessageFail @"消息发送失败"

@interface XMPPManager : NSObject<XMPPStreamDelegate>

//available: 表示处于在线状态(通知好友在线)
//unavailable: 表示处于离线状态（通知好友下线）
//subscribe: 表示发出添加好友的申请（添加好友请求）
//unsubscribe: 表示发出删除好友的申请（删除好友请求）
//unsubscribed: 表示拒绝添加对方为好友（拒绝添加对方为好友）
//error: 表示presence信息报中包含了一个错误消息。（出错）

//According to the XMPP protocol, the iq.type should be one of 'get', 'set', 'result' or 'error'

//*  好友信息状态有5种
//both - 互为好友
//none - 互不为好友
//to - 请求添加对方为好友，对方还没有同意
//from - 对方添加我为好友，自己还没有同意
//remove - 曾经删除的好友
//*/

//xmppStream通信管道,用于与服务器进行连接.
@property (nonatomic, strong)XMPPStream *stream;
//xmppRoster好友管理,用于管理好友的操作a
@property (nonatomic, strong)XMPPRoster *roster;
//好友列表(所有好友),[query children]
@property (strong, nonatomic)NSMutableArray *rosterList;
//both互为好友,存储CHUserInformation
@property   (nonatomic,strong)NSMutableArray *friendArr;
//****
@property   (nonatomic,strong)XMPPvCardAvatarModule *vCardModule;
@property   (nonatomic,strong)XMPPvCardTempModule *vCardTempModule;


//CoreData方式数据存储
// 和聊天相关的属性，消息归档
@property (nonatomic, strong)XMPPMessageArchiving * xmppMessageArchiving;
// 管理数据库上下文
@property   (nonatomic,strong)NSManagedObjectContext *manageVcardContext;
//在线的好友数组
@property (nonatomic, strong)NSMutableArray * availableRosterList;
//正在联系的好友 数组
@property (nonatomic, strong)NSMutableArray * chatingFriendas;
//消息字典
@property (nonatomic, strong)NSMutableDictionary * messageDictionary;


+ (XMPPManager *)shareXMPPManager;

//登录
- (void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord;
//注册
- (void)registerWithUserName:(NSString *)userName passWord:(NSString *)passWord;
//添加好友
- (void)addFriendWithuserName:(NSString *)userName nikeName:(NSString *)name;
//删除好友
- (void)deleteFriendWithuserName:(NSString *)userName;
//获取指定位置的好友
- (XMPPJID *)rosterObjectAtIndex: (NSInteger)index;

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence;

@end
