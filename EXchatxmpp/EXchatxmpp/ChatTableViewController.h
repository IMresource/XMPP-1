//
//  ChatTableViewController.h
//  EXchatxmpp
//
//  Created by wht on 2017/8/22.
//  Copyright © 2017年 wht. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"

@interface ChatTableViewController : UITableViewController

@property (strong, nonatomic)XMPPJID *chatWithJID;

@end
