#import <Foundation/Foundation.h>
#import "XMPPSASLAuthentication.h"
#import "XMPP.h"


@interface XMPPAnonymousAuthentication : NSObject <XMPPSASLAuthentication>

- (id)initWithStream:(XMPPStream *)stream;

// This class implements the XMPPSASLAuthentication protocol.
// 
// See XMPPSASLAuthentication.h for more information.

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface XMPPStream (XMPPAnonymousAuthentication)

/**
 * Returns whether or not the server support anonymous authentication.
 * 
 * This information is available after the stream is connected.
 * In other words, after the delegate has received xmppStreamDidConnect: notification.
 返回服务器是否支持匿名身份验证。
 此信息在stream连接之后可用。
 换句话说，在委派接收到xmppStreamDidConnect:通知之后
**/

//是否支出匿名认证
- (BOOL)supportsAnonymousAuthentication;

/**
 * This method attempts to start the anonymous authentication process.
 * 
 * This method is asynchronous.
 * 
 * If there is something immediately wrong,
 * such as the stream is not connected or doesn't support anonymous authentication,
 * the method will return NO and set the error.
 * Otherwise the delegate callbacks are used to communicate auth success or failure.
 此方法尝试启动匿名身份验证过程。
 *
 这个方法是异步的。
 *
 如果有什么东西立刻出错了，
 例如，流没有连接或不支持匿名身份验证，
 该方法将返回NO并设置错误。
 否则，委派回调用于通信身份验证成功或失败。
 * @see xmppStreamDidAuthenticate:
 * @see xmppStream:didNotAuthenticate:
**/
- (BOOL)authenticateAnonymously:(NSError **)errPtr;

@end
