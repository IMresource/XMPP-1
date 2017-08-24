//
//  XMPPManager.m
//  EXchatxmpp
//
//  Created by wht on 2017/8/19.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "XMPPManager.h"
#import "CHUserInformation.h"
#import "XMPPvCardTemp.h"

typedef NS_ENUM(NSInteger, ConnectionType) {
    ConnectionTypeLogin,//登录
    ConnectionTypeRegister,//注册
};

@interface XMPPManager()<XMPPRosterDelegate>

@property (nonatomic, strong)NSString *passWord;
@property (nonatomic)ConnectionType connectiontype;

@end

@implementation XMPPManager

+ (XMPPManager *)shareXMPPManager{
    static XMPPManager * xmppManager;
    static dispatch_once_t onceToKen;
    dispatch_once(&onceToKen, ^{
        xmppManager = [[XMPPManager alloc] init];
    });
    return xmppManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.stream = [[XMPPStream alloc] init];
        self.stream.hostName = kHostName;
        self.stream.hostPort = kHostPort;
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //好友列表获取
        //好友列表存储,创建一个好友列表数据存储
        XMPPRosterCoreDataStorage * rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        //初始化好友列表.
        self.roster = [[XMPPRoster alloc] initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //通过通道获取好友列表,激活好友列表
        [self.roster activate:self.stream];
        //添加XMPPRosterDelegate 代理对象
        [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        
        
        self.vCardTempModule = [[XMPPvCardTempModule alloc]initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
        self.manageVcardContext = [[XMPPvCardCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
        
        self.vCardModule = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vCardTempModule dispatchQueue:dispatch_get_main_queue()];
        [_vCardModule addDelegate:self delegateQueue:(dispatch_get_main_queue())];
        [_vCardTempModule activate:self.stream];
        [_vCardModule activate:self.stream];
        
        //创建一个信息归档器
        XMPPMessageArchivingCoreDataStorage * messageArchivingCoreDateStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
//        初始化XMPP的信息归档器, 在主线程中执行.
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageArchivingCoreDateStorage dispatchQueue:dispatch_get_main_queue()];
        //激活聊天信息
        [self.xmppMessageArchiving activate:self.stream];
        self.manageVcardContext = messageArchivingCoreDateStorage.mainThreadManagedObjectContext;
        //初始化3个好友数组
        self.rosterList = [NSMutableArray array];
        self.availableRosterList = [NSMutableArray array];
        self.chatingFriendas = [NSMutableArray array];
        //初始化聊天信息
        self.messageDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark ------- 登录
- (void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord{
    self.connectiontype = ConnectionTypeLogin;
    self.passWord = passWord;
    [self createJIDWithUserName:userName];
}
#pragma mark ------- 注册
- (void)registerWithUserName:(NSString *)userName passWord:(NSString *)passWord{
    self.connectiontype = ConnectionTypeRegister;
    self.passWord = passWord;
    [self createJIDWithUserName:userName];
}

#pragma mark -------- 创建JID
- (void)createJIDWithUserName:(NSString *)userName{
    XMPPJID * myJID =  [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    self.stream.myJID = myJID;
    //与服务器链接
    [self connectionToServer];
}

#pragma mark -------- 与服务器链接
- (void)connectionToServer{
    NSLog(@"与服务器链接");
    if ([self.stream isConnected]) {
        [self.stream disconnect];
    }
    NSError *error;
    [self.stream connectWithTimeout:-1 error:&error];
    if (error) {
        NSLog(@"%s_%d_|请求服务器失败 = %@",__FUNCTION__ ,__LINE__,[error localizedDescription]);
    }
}

#pragma mark - XMPPStreamDelegate Method
#pragma mark ------- 与服务器链接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"与服务器链接成功");
    if (self.connectiontype == ConnectionTypeLogin) {
        [sender authenticateWithPassword:self.passWord error:NULL];
    }
    else if (self.connectiontype == ConnectionTypeRegister){
        [sender registerWithPassword:self.passWord error:NULL];
    }
}

#pragma mark ---------- 退出并断开连接
- (void)disconnect {
    //下线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.stream sendElement:presence];
    [self.stream disconnect];
}

#pragma mark ------- 连接超时
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"连接超时");
    [self connectionToServer];
}

#pragma mark -------登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"登录成功");
    //设置在线状态
    XMPPPresence * presence = [XMPPPresence presenceWithType:@"available"];
    [self.stream sendElement:presence];
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess object:nil];
}
#pragma mark -------登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    NSLog(@"登录失败 error == %@",error);
}


#pragma mark -------注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
    [[NSNotificationCenter defaultCenter] postNotificationName:kRegistSuccess object:nil];
}
#pragma mark -------注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    NSLog(@"注册失败 %@", error);
}


#pragma mark ------- 添加好友
- (void)addFriendWithuserName:(NSString *)userName nikeName:(NSString *)name{
    XMPPJID *jid = [XMPPJID jidWithString:userName];
    //监听好友动作
    [self.roster subscribePresenceToUser:jid];
    [self.roster addUser:jid withNickname:name groups:@[@"我的好友"]];
    // 当添加成功时，会自动调用IQ方法
}

#pragma mark ------- 删除好友
- (void)deleteFriendWithuserName:(NSString *)userName{
    XMPPJID *jid = [XMPPJID jidWithString:userName];
    [self.roster removeUser:jid];
}


#pragma mark ------ XMPPStreamDelegate
#pragma mark ------- 好友的个数变化时，会调用此方法，初次获得好友列表时，也会自动调用此方法
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    NSLog(@"%s_%d_|",__FUNCTION__ ,__LINE__);
    NSLog(@"iq.type      %@   -----  %@", iq.type, iq);
    // 第一次走，获得所有好友信息
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        if ([@"query" isEqualToString:query.name]) {
            NSArray *items = [query children];
            self.rosterList = [NSMutableArray arrayWithArray:items];
            //封装数据
            [self friendPresent];
        }
// 添加好友或者删除好友时
    }else if([@"set" isEqualToString:iq.type]){
        NSXMLElement *query = iq.childElement;
        XMPPElement *item = [[query elementsForName:@"item"] firstObject];
        NSString *str = [[item attributeForName:@"subscription"] stringValue];
        //oneFriend当前操作的好友
        CHUserInformation *oneFriend = [[CHUserInformation alloc]init];
        [oneFriend createUser:item];
        // 判断是移除还是添加 subscription (both - 互为好友 none - 互不为好友 to - 请求添加对方为好友，对方还没有同意 from - 对方添加我为好友，自己还没有同意 remove - 曾经删除的好友)
        CHUserInformation *user = nil;
        if ([str isEqualToString:@"remove"]) {
            for (CHUserInformation *userFriend in _friendArr) {
                if ([userFriend.jid.user isEqualToString: oneFriend.jid.user ]) {
                    user = userFriend;
                }
            }
            if (user !=nil) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"好友删除成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:sureAction];
                [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
                [_friendArr removeObject:user];
            }
        }else if([str isEqualToString:@"both"]){
            int flagggg = 0;
            for (CHUserInformation *userFriend in _friendArr) {
                NSLog(@",,userFriend.jid.user     %@,  oneFriend.jid.user   ,%@",userFriend.jid.user,oneFriend.jid.user);
                if (userFriend.jid == oneFriend.jid) {
                    flagggg =1;
                    break;
                }
            }
            if (flagggg == 0) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"好友添加成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:sureAction];
                [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
                [self.friendArr addObject:oneFriend];
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kRosterLoder object:nil];
    }
    
    return YES;
}

//- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
//    NSLog(@"%s_%d_|",__FUNCTION__ ,__LINE__);
//}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    NSLog(@"listTVC 判断好友是否处于上线状态 %@ %d", presence.status, __LINE__);
    NSString *type = presence.type;
    NSString *presenceUser = presence.to.user;
    // 判断当前用户是否为好友
    if ([presenceUser isEqualToString:[sender myJID].user]) {
        if ([type isEqualToString:@"available"]) {
            NSLog(@"该用户处于上线状态");
        } else if ([type isEqualToString:@"unavailable"]) {
            NSLog(@"该用户处于下线状态");
        }
    }
    
    NSLog(@"%s_%d_|",__FUNCTION__ ,__LINE__);
    NSLog(@"[presence type]     ----    %@", [presence type]);
//    if ([[presence type] isEqualToString:@"subscribe"]){
//        [self xmppRoster:self.roster didReceivePresenceSubscriptionRequest:presence];
//    }
    
    //    DDLogVerbose(@"%@: %@ ^^^ %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    //当前用户
    //    NSString *userId = [NSString stringWithFormat:@"%@", [[sender myJID] user]];
    //在线用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"presenceType:%@",presenceType);
    NSLog(@"用户:%@",presenceFromUser);
    //这里再次加好友
    if ([presenceType isEqualToString:@"subscribed"]) {
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
        [self.roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }
}

#pragma mark ------ XMPPRosterDelegate 
#pragma mark ------ 接收到添加好友的请求，选择接受or拒绝
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"________________%s_%d_|",__FUNCTION__ ,__LINE__);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@请求添加好友", [[presence from] user]] message:@"是否同意" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self)weakSelf = self;
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 添加到花名册
        [weakSelf.roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    }];
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.roster rejectPresenceSubscriptionRequestFrom:presence.from];
    }];
    [alertController addAction:acceptAction];
    [alertController addAction:rejectAction];
    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
    

        //请求的用户
//        NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
//        XMPPJID *addJID = [XMPPJID jidWithString:presenceFromUser];
//        NSString *jidName =[NSString stringWithFormat:@"%@请求添加你为好友", addJID.bare];
//    NSLog(@"-+++++++++++++  %@", jidName);
//    [self.roster acceptPresenceSubscriptionRequestFrom:addJID andAddToRoster:YES];
//    [self addFriendWithuserName:presenceFromUser nikeName:presenceFromUser];
        //接受
    
        //接受以后走IQ方法

}
// 开始获得好友状态
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"%s_%d_|",__FUNCTION__ ,__LINE__);
    //上线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.stream sendElement:presence];
}

// 收到好友的JID
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item{
    NSLog(@"%s_%d_|",__FUNCTION__ ,__LINE__);
    NSString *description = [[item attributeForName:@"subscription"] stringValue];
    XMPPJID *jid = [XMPPJID jidWithString:[[item attributeForName:@"jid"] stringValue]];
    NSLog(@"关系%@ 名字  %@", description, jid.user);
}

//  获取好友列表以后，调用此方法
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"%s_%d_|",__FUNCTION__ ,__LINE__);
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    NSLog(@"%s_%d_|",__FUNCTION__ ,__LINE__);
}

//获取指定位置的好友
- (XMPPJID *)rosterObjectAtIndex:(NSInteger)index
{
    if (index < 0) {
        return nil;
    }
    return self.friendArr[index];
}

// 封装item数据，分组，状态，好友
- (void)friendPresent{
    NSMutableArray *arr = _rosterList;
    self.friendArr = [[NSMutableArray alloc]init];
    for (XMPPElement *item in arr) {
        //返回subscription大部分都为none,none表示请求添加好友未确认
        NSString *str = [[item attributeForName:@"subscription"] stringValue];
        //both互为好友
        if ([str isEqualToString:@"both"]) {
        CHUserInformation *userInformation = [[CHUserInformation alloc]init];
        [userInformation createUser:item];
            if ([self.friendArr containsObject:userInformation]) {
                return;
            }
        [self.friendArr addObject:userInformation];
    }
    }
    //获取好友的更多详细信息
    //    [self friendInformation];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRosterLoder object:nil];
}

// 获取好友的头像及未读消息
- (void)friendInformation
{
    for (CHUserInformation *firend in self.friendArr) {
        //        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
        // 实体管理对象
        //        XMPPRosterCoreDataStorage *storage = [XMPPRosterCoreDataStorage sharedInstance];
        //        XMPPUserCoreDataStorageObject *object = [storage userForJID:firend.jid xmppStream:nil managedObjectContext:[storage mainThreadManagedObjectContext]];
        //        firend.image = object.photo;
        
        NSData *imageData = [self.vCardModule photoDataForJID:firend.jid];
        if (imageData != nil) {
            firend.image = [UIImage imageWithData:imageData];
        }else{
            firend.image = [UIImage imageNamed:@"头像.png"];
        }
        
        //  firend.unreadMessages = object.unreadMessages;
        //     NSLog(@"object = %@",object.photo);
        firend.messageArr = [self messageListForJID:firend.jid];
    }
    // [self friendPohto];
}

//获取指定好友的消息列表
- (NSMutableArray *)messageListForJID:(XMPPJID *)jid
{//请求的哪个数据库
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    // 实体管理对象
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    //  获取信息的条件
    NSPredicate *pridecte = [NSPredicate predicateWithFormat:@"bareJidStr = %@ AND streamBareJidStr = %@",jid.bare,self.stream.myJID.bare];
    [request setPredicate:pridecte];
    NSArray *array =  [moc executeFetchRequest:request error:nil] ;
    NSMutableArray *mutableArray = [[NSMutableArray alloc]initWithArray:array];
    return mutableArray;
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

#pragma mark - 已经发送消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    // 重新对消息进行操作
//    [self showMessage];
    NSLog(@"已经发送消息");
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMessage object:nil];
}
#pragma mark - 已经接收消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    // 重新对消息进行操作
//    [self showMessage];
    NSLog(@"已经接收消息");
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMessage object:nil];
}

#pragma mark - 消息发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"消息发送失败");
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageFail object:nil];
}

@end
