//
//  CHUserInformation.m
//  EXchatxmpp
//
//  Created by wht on 2017/8/19.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "CHUserInformation.h"

@implementation CHUserInformation
- (void)createUser:(XMPPElement *)element
{
    self.jid =[XMPPJID jidWithString:[[element attributeForName:@"jid"] stringValue]];
    NSString *name = [[element attributeForName:@"name"] stringValue];
    if (name == nil){
        self.name = _jid.user;
    }else{
        self.name = name;
    }
    self.unreadMessages = 0;
    NSString *group = [[[element elementsForName:@"group"] firstObject] stringValue];
    if (group == nil) {
        self.group = @"我的好友";
    }else{
        self.group = group;
    }
    self.statue = @"离线";
    self.image = [UIImage imageNamed:@"头像.png"];
    
}

@end
