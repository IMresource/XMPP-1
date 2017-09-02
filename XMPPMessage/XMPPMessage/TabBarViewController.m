//
//  TabBarViewController.m
//  XMPPMessage
//
//  Created by wht on 2017/8/30.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "TabBarViewController.h"
#import "ChatListViewController.h"
#import "MineViewController.h"
#import "RostersTableViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ChatListViewController *chatVC = [[ChatListViewController alloc] init];
    UINavigationController *chatNav = [[UINavigationController alloc] initWithRootViewController:chatVC];
    chatNav.tabBarItem.title = @"消息";
    [chatNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:170/255.0 blue:238/255.0 alpha:1.0], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    chatNav.navigationBar.translucent = NO;
    chatNav.tabBarItem.image = [UIImage imageNamed:@"home@2x.png"];
    
    RostersTableViewController *friendVC = [[RostersTableViewController alloc] init];
    UINavigationController *friendNav = [[UINavigationController alloc] initWithRootViewController:friendVC];
    friendNav.tabBarItem.title = @"联系人";
    friendNav.tabBarItem.image = [UIImage imageNamed:@"QQ@2x.png"];
    [friendNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:170/255.0 blue:238/255.0 alpha:1.0], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    friendNav.navigationBar.translucent = NO;
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem.title = @"我的";
    mineNav.tabBarItem.image = [UIImage imageNamed:@"personal@2x.png"];
    [mineNav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:170/255.0 blue:238/255.0 alpha:1.0], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    mineNav.navigationBar.translucent = NO;
    
    self.tabBar.translucent = NO;
    self.viewControllers = @[chatNav, friendNav, mineNav];
    self.selectedIndex = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
