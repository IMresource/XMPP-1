//
//  MineViewController.m
//  XMPPMessage
//
//  Created by wht on 2017/8/30.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "MineViewController.h"
#import "LoginViewController.h"

@interface MineViewController ()

@property (strong, nonatomic)UIButton *logoutBtn;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logoutBtn = [self buttonWithFrame:CGRectMake(30, 30, 150, 30) title:@"退出登录" target:self action:@selector(logout)];
    [_logoutBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [self.view addSubview:_logoutBtn];
}

- (void)logout{
    NSLog(@"退出登录");
//    [[XMPPManager shareXMPPManager] disconnect];
    
    LoginViewController* loginVC = [[LoginViewController alloc]init];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    loginVC.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self  presentViewController:loginNav animated:YES completion:^{
        NSLog(@"----------");
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
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
