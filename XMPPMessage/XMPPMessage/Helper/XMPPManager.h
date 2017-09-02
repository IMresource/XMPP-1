//
//  XMPPManager.h
//  EXchatxmpp
//
//  Created by wht on 2017/8/19.
//  Copyright © 2017年 wht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

//#define kLoginSuccess @"登录成功"
//#define kRegistSuccess @"注册成功"
//#define kRosterLoder @"刷新好友列表"
//#define kShowMessage @"刷新消息"
//#define kMessageFail @"消息发送失败"

@interface XMPPManager : NSObject<XMPPStreamDelegate>

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

//-(void)aaaaaaaaaaaaad;

@end

//在iOS客户端，使用XMPP时, 使用第三方库 XMPPFramework  ，需要导入系统类库有：libxml2、CFNetWork、SystemConfiguration、Security、libresolv
//
//因为使用到了libxml2，所以 还需要到 Search Path 中的 Header Search Path  添加   /usr/include/libxml2

//  好友信息状态有5种
//both - 互为好友
//none - 互不为好友
//to - 请求添加对方为好友，对方还没有同意
//from - 对方添加我为好友，自己还没有同意
//remove - 曾经删除的好友

//iq.type get用于请求信息，类似于HTTP Get 发送获取花名册请求
//iq.type set提供信息或请求，类似于HTTP POST/PUT 用户新增一个联系人
//iq.type result响应请求，类似于HTTP 200 服务器返回花名册 服务器响应
//iq.type error错误信息

//available: 表示处于在线状态(通知好友在线)
//unavailable: 表示处于离线状态（通知好友下线）
//subscribe: 表示发出添加好友的申请（添加好友请求）
//unsubscribe: 表示发出删除好友的申请（删除好友请求）
//unsubscribed: 表示拒绝添加对方为好友（拒绝添加对方为好友）
//error: 表示presence信息报中包含了一个错误消息。（出错）

//XMPPJID用户身份的唯一标识,由用户名，域名和资源名三部分构成，格式为user@domain/resource，对应XMPPJID类中的三个属性user、domain、resource。

/*
 XMPPStreamDelegate 方法
 @optional
 // 将要与服务器连接是回调
 - (void)xmppStreamWillConnect:(XMPPStream *)sender;
 
 // 当tcp socket已经与远程主机连接上时会回调此代理方法
 // 若App要求在后台运行，需要设置XMPPStream's enableBackgroundingOnSocket属性
 - (void)xmppStream:(XMPPStream *)sendersocketDidConnect:(GCDAsyncSocket *)socket;
 
 // 当TCP与服务器建立连接后会回调此代理方法
 - (void)xmppStreamDidStartNegotiation:(XMPPStream *)sender;
 
 // TLS传输层协议在将要验证安全设置时会回调
 // 参数settings会被传到startTLS
 // 此方法可以不实现的，若选择实现它，可以可以在
 // 若服务端使用自签名的证书，需要在settings中添加GCDAsyncSocketManuallyEvaluateTrust=YES
 //
 - (void)xmppStream:(XMPPStream *)senderwillSecureWithSettings:(NSMutableDictionary *)settings;
 
 // 上面的方法执行后，下一步就会执行这个代理回调
 // 用于在TCP握手时手动验证是否受信任
 - (void)xmppStream:(XMPPStream *)senderdidReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler;
 
 // 当stream通过了SSL/TLS的安全验证时，会回调此代理方法
 - (void)xmppStreamDidSecure:(XMPPStream *)sender;
 
 // 当XML流已经完全打开时（也就是与服务器的连接完成时）会回调此代理方法。此时可以安全地与服务器通信了。
 - (void)xmppStreamDidConnect:(XMPPStream *)sender;
 
 // 注册新用户成功时的回调
 - (void)xmppStreamDidRegister:(XMPPStream *)sender;
 
 // 注册新用户失败时的回调
 - (void)xmppStream:(XMPPStream *)senderdidNotRegister:(NSXMLElement *)error;
 
 // 授权通过时的回调，也就是登录成功的回调
 - (void)xmppStreamDidAuthenticate:(XMPPStream *)sender;
 
 // 授权失败时的回调，也就是登录失败时的回调
 - (void)xmppStream:(XMPPStream *)senderdidNotAuthenticate:(NSXMLElement *)error;
 
 // 将要绑定JID resource时的回调，这是授权程序的标准部分，当验证JID用户名通过时，下一步就验证resource。若使用标准绑定处理，return nil或者不要实现此方法
 - (id <XMPPCustomBinding>)xmppStreamWillBind:(XMPPStream *)sender;
 
 // 如果服务器出现resouce冲突而导致不允许resource选择时，会回调此代理方法。返回指定的resource或者返回nil让服务器自动帮助我们来选择。一般不用实现它。
 - (NSString *)xmppStream:(XMPPStream *)senderalternativeResourceForConflictingResource:(NSString *)conflictingResource;
 
 // 将要发送IQ（消息查询）时的回调
 - (XMPPIQ *)xmppStream:(XMPPStream *)senderwillReceiveIQ:(XMPPIQ *)iq;
 // 将要接收到消息时的回调
 - (XMPPMessage *)xmppStream:(XMPPStream *)senderwillReceiveMessage:(XMPPMessage *)message;
 // 将要接收到用户在线状态时的回调
 - (XMPPPresence *)xmppStream:(XMPPStream *)senderwillReceivePresence:(XMPPPresence *)presence;
 
 
 如果任何xmppStream:willReceiveX:接收:方法过滤传入的节，就会调用此方法。
 *
 对于某些扩展来说，知道接收到的东西是有用的，
 即使是由于某种原因被过滤了。
 
 // 当xmppStream:willReceiveX:(也就是前面这三个API回调后)，过滤了stanza，会回调此代理方法。
 // 通过实现此代理方法，可以知道被过滤的原因，有一定的帮助。
 - (void)xmppStreamDidFilterStanza:(XMPPStream *)sender;
 
 // 在接收了IQ（消息查询后）会回调此代理方法
 - (BOOL)xmppStream:(XMPPStream *)senderdidReceiveIQ:(XMPPIQ *)iq;
 // 在接收了消息后会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidReceiveMessage:(XMPPMessage *)message;
 // 在接收了用户在线状态消息后会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidReceivePresence:(XMPPPresence *)presence;
 
 // 在接收IQ/messag、presence出错时，会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidReceiveError:(NSXMLElement *)error;
 
 // 将要发送IQ（消息查询时）时会回调此代理方法
 - (XMPPIQ *)xmppStream:(XMPPStream *)senderwillSendIQ:(XMPPIQ *)iq;
 // 在将要发送消息时，会回调此代理方法
 - (XMPPMessage *)xmppStream:(XMPPStream *)senderwillSendMessage:(XMPPMessage *)message;
 // 在将要发送用户在线状态信息时，会回调此方法
 - (XMPPPresence *)xmppStream:(XMPPStream *)senderwillSendPresence:(XMPPPresence *)presence;
 
 // 在发送IQ（消息查询）成功后会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidSendIQ:(XMPPIQ *)iq;
 // 在发送消息成功后，会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidSendMessage:(XMPPMessage *)message;
 // 在发送用户在线状态信息成功后，会回调此方法
 - (void)xmppStream:(XMPPStream *)senderdidSendPresence:(XMPPPresence *)presence;
 
 // 在发送IQ（消息查询）失败后会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidFailToSendIQ:(XMPPIQ *)iqerror:(NSError *)error;
 // 在发送消息失败后，会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidFailToSendMessage:(XMPPMessage *)messageerror:(NSError *)error;
 // 在发送用户在线状态失败信息后，会回调此方法
 - (void)xmppStream:(XMPPStream *)senderdidFailToSendPresence:(XMPPPresence *)presenceerror:(NSError *)error;
 
 // 当修改了JID信息时，会回调此代理方法
 - (void)xmppStreamDidChangeMyJID:(XMPPStream *)xmppStream;
 
 // 当Stream被告知与服务器断开连接时会回调此代理方法
 - (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender;
 
 // 当发送了</stream:stream>节点时，会回调此代理方法
 - (void)xmppStreamDidSendClosingStreamStanza:(XMPPStream *)sender;
 
 // 连接超时时会回调此代理方法
 - (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender;
 
 // 当与服务器断开连接后，会回调此代理方法
 - (void)xmppStreamDidDisconnect:(XMPPStream *)senderwithError:(NSError *)error;
 
 // p2p类型相关的
 - (void)xmppStream:(XMPPStream *)senderdidReceiveP2PFeatures:(NSXMLElement *)streamFeatures;
 - (void)xmppStream:(XMPPStream *)senderwillSendP2PFeatures:(NSXMLElement *)streamFeatures;
 
 
 - (void)xmppStream:(XMPPStream *)senderdidRegisterModule:(id)module;
 - (void)xmppStream:(XMPPStream *)senderwillUnregisterModule:(id)module;
 
 // 当发送非XMPP元素节点时，会回调此代理方法。也就是说，如果发送的element不是
 // <iq>, <message> 或者 <presence>，那么就会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidSendCustomElement:(NSXMLElement *)element;
 // 当接收到非XMPP元素节点时，会回调此代理方法。也就是说，如果接收的element不是
 // <iq>, <message> 或者 <presence>，那么就会回调此代理方法
 - (void)xmppStream:(XMPPStream *)senderdidReceiveCustomElement:(NSXMLElement *)element;
 
 */


/*
 XMPPIQ
 消息查询（IQ）就是通过此类来处理的了。XMPP给我们提供了IQ方便创建的类，用于快速生成XML数据。若头文件声明如下：
 
 @interfaceXMPPIQ: XMPPElement
 
 // 生成iq
 + (XMPPIQ *)iq;
 + (XMPPIQ *)iqWithType:(NSString *)type;
 + (XMPPIQ *)iqWithType:(NSString *)typeto:(XMPPJID *)jid;
 + (XMPPIQ *)iqWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
 + (XMPPIQ *)iqWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 + (XMPPIQ *)iqWithType:(NSString *)typeelementID:(NSString *)eid;
 + (XMPPIQ *)iqWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 + (XMPPIQ *)iqWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
 - (id)init;
 - (id)initWithType:(NSString *)type;
 - (id)initWithType:(NSString *)typeto:(XMPPJID *)jid;
 - (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
 - (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 - (id)initWithType:(NSString *)typeelementID:(NSString *)eid;
 - (id)initWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 - (id)initWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
 // IQ类型，看下面的说明
 - (NSString *)type;
 
 // 判断type类型
 - (BOOL)isGetIQ;
 - (BOOL)isSetIQ;
 - (BOOL)isResultIQ;
 - (BOOL)isErrorIQ;
 
 // 当type为get或者set时，这个API是很有用的，用于指定是否要求有响应
 - (BOOL)requiresResponse;
 
 - (NSXMLElement *)childElement;
 - (NSXMLElement *)childErrorElement;
 
 @end
 
 //获取好友列表  使用iq结点
 //ip type="get" id="roster"><query  xmlns="jabber:iq:roster"/></iq>
 //返回结果集 使用iq结点：
 //iq><query><item jid="好友1"><item jid="好友2"></query></iq>
 
 //iq.type get用于请求信息，类似于HTTP Get 发送获取花名册请求
 //iq.type set提供信息或请求，类似于HTTP POST/PUT 用户新增一个联系人
 //iq.type result响应请求，类似于HTTP 200 服务器返回花名册 服务器响应
 //iq.type error错误信息
 
 IQ是一种请求／响应机制，从一个实体从发送请求，另外一个实体接受请求并进行响应。例如，client在stream的上下文中插入一个元素，向Server请求得到自己的好友列表，Server返回一个，里面是请求的结果。
 <type></type>有以下类别（可选设置如：<type>get</type>）：
 get :获取当前域值。类似于http get方法。
 set :设置或替换get查询的值。类似于http put方法。
 result :说明成功的响应了先前的查询。类似于http状态码200。
 error: 查询和响应中出现的错误。
 下面是一个IQ例子：
 
 <iqfrom="huangyibiao@welcome.com/ios"
 id="xxxxxxx"
 to="biaoge@welcome.com/ios"
 type="get">
 <queryxmlns="jabber:iq:roster"/>
 </iq>
 */


/*
 //XMPPPresence  管理用户在线状态
 这个类代表节点，我们通过此类提供的方法来生成XML数据。它代表用户在线状态，它的头文件内容很少的：
 
 @interfaceXMPPPresence: XMPPElement
 
 // Converts an NSXMLElement to an XMPPPresence element in place (no memory allocations or copying)
 + (XMPPPresence *)presenceFromElement:(NSXMLElement *)element;
 
 + (XMPPPresence *)presence;
 + (XMPPPresence *)presenceWithType:(NSString *)type;
 // type：用户在线状态，看下面的讲解
 // to：接收方的JID
 + (XMPPPresence *)presenceWithType:(NSString *)typeto:(XMPPJID *)to;
 
 - (id)init;
 - (id)initWithType:(NSString *)type;
 
 // type：用户在线状态，看下面的讲解
 // to：接收方的JID
 - (id)initWithType:(NSString *)typeto:(XMPPJID *)to;
 
 - (NSString *)type;
 
 - (NSString *)show;
 - (NSString *)status;
 
 - (int)priority;
 
 - (int)intShow;
 
 - (BOOL)isErrorPresence;
 
 @end
 
 presence用来表明用户的状态，如：online、away、dnd(请勿打扰)等。当改变自己的状态时，就会在stream的上下文中插入一个Presence元素，来表明自身的状态。要想接受presence消息，必须经过一个叫做presence subscription的授权过程。
 
 //available: 表示处于在线状态(通知好友在线)
 //unavailable: 表示处于离线状态（通知好友下线）
 //subscribe: 表示发出添加好友的申请（添加好友请求）
 //unsubscribe: 表示发出删除好友的申请（删除好友请求）
 //unsubscribed: 表示拒绝添加对方为好友（拒绝添加对方为好友）
 //error: 表示presence信息报中包含了一个错误消息。（出错）
 
 <type></type>有以下类别（可选设置如：<type>subscribe</type>）：
 subscribe：订阅其他用户的状态
 probe：请求获取其他用户的状态
 unavailable：不可用，离线（offline）状态
 <show></show>节点有以下类别，如<show>dnd</show>：
 chat：聊天中
 away：暂时离开
 xa：eXtend Away，长时间离开
 dnd：勿打扰
 <status></status>节点
 这个节点表示状态信息，内容比较自由，几乎可以是所有类型的内容。常用来表示用户当前心情，活动，听的歌曲，看的视频，所在的聊天室，访问的网页，玩的游戏等等。
 <priority></priority>节点
 范围-128~127。高优先级的resource能接受发送到bare JID的消息，低优先级的resource不能。优先级为负数的resource不能收到发送到bare JID的消息。
 发送一个用户在线状态的例子：
 
 <presencefrom="alice@wonderland.lit/pda">
 <show>dnd</show>
 <status>1111111111111111111</status>
 </presence>
 
 */


/*
 XMPPMessage是XMPP框架给我们提供的，方便用于生成XML消息的数据，其头文件如下：
 
 @interfaceXMPPMessage: XMPPElement
 
 + (XMPPMessage *)messageFromElement:(NSXMLElement *)element;
 
 + (XMPPMessage *)message;
 + (XMPPMessage *)messageWithType:(NSString *)type;
 + (XMPPMessage *)messageWithType:(NSString *)typeto:(XMPPJID *)to;
 + (XMPPMessage *)messageWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
 + (XMPPMessage *)messageWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 + (XMPPMessage *)messageWithType:(NSString *)typeelementID:(NSString *)eid;
 + (XMPPMessage *)messageWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 + (XMPPMessage *)messageWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
 - (id)init;
 - (id)initWithType:(NSString *)type;
 - (id)initWithType:(NSString *)typeto:(XMPPJID *)to;
 - (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eid;
 - (id)initWithType:(NSString *)typeto:(XMPPJID *)jidelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 - (id)initWithType:(NSString *)typeelementID:(NSString *)eid;
 - (id)initWithType:(NSString *)typeelementID:(NSString *)eidchild:(NSXMLElement *)childElement;
 - (id)initWithType:(NSString *)typechild:(NSXMLElement *)childElement;
 
 - (NSString *)type;
 - (NSString *)subject;
 - (NSString *)body;
 - (NSString *)bodyForLanguage:(NSString *)language;
 - (NSString *)thread;
 
 - (void)addSubject:(NSString *)subject;
 - (void)addBody:(NSString *)body;
 - (void)addBody:(NSString *)bodywithLanguage:(NSString *)language;
 - (void)addThread:(NSString *)thread;
 
 - (BOOL)isChatMessage;
 - (BOOL)isChatMessageWithBody;
 - (BOOL)isErrorMessage;
 - (BOOL)isMessageWithBody;
 
 - (NSError *)errorMessage;
 
 @end
 
 message是一种基本 推送 消息方法，它不要求响应。主要用于IM、groupChat、alert和notification之类的应用中。
 <type></type>有以下类别（可选设置如：<type> chat</type>）：
 normal：类似于email，主要特点是不要求响应；
 chat：类似于qq里的好友即时聊天，主要特点是实时通讯；
 groupchat：类似于聊天室里的群聊；
 headline：用于发送alert和notification；
 error：如果发送message出错，发现错误的实体会用这个类别来通知发送者出错了；
 <body></body>节点
 所要发送的内容就放在body节点下
 消息节点的例子：
 
 <messageto="lily@jabber.org/contact" type="chat">
 <body>11111111111？</body>
 </message>
 */















