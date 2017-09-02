//
//  AppMacro.h
//  XMPPMessage
//
//  Created by wht on 2017/8/31.
//  Copyright © 2017年 wht. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h


#endif /* AppMacro_h */

//如果不需要log,把1改成0
#if 1
#define NSLog(FORMAT, ...) fprintf(stderr,"[%s:%d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif


#define K_loginSuccess @"loginSuccess"
#define K_loginFail @"loginFail"
#define K_registSuccess @"registSuccess"
#define K_registFail @"registFail"
#define K_reloadFriendList @"reloadFriendList"
#define K_showMessage @"sendMessagesuccess"
#define K_messageFail @"messageFail"


#define K_ISLOGIN @"isLogin"


#define K_USERINFOISLOGIN [[NSUserDefaults standardUserDefaults] objectForKey:K_ISLOGIN]
