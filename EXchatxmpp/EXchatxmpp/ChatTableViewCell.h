//
//  ChatTableViewCell.h
//  EXchatxmpp
//
//  Created by wht on 2017/8/22.
//  Copyright © 2017年 wht. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTableViewCell : UITableViewCell

// 判断是不是对方发送过来的消息 YES - 对方发送的消息， NO - 自己发送给对方的消息
@property (nonatomic, assign) BOOL isOut;
// 消息内容
@property (nonatomic, copy) NSString *message;

@end
