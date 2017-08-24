//
//  ViewController.m
//  EXchatxmpp
//
//  Created by wht on 2017/8/19.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "ViewController.h"
#import "XMPPManager.h"
#import "RostersTableViewController.h"


@interface ViewController ()

@property (strong, nonatomic)UITextField *nameTF;
@property (strong, nonatomic)UITextField *passwordTF;
@property (strong, nonatomic)UIButton *loginBtn;
@property (strong, nonatomic)UIButton *registBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
    
    //登录成功跳转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToRostersVC) name:kLoginSuccess object:nil];
    //注册成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registSuccess) name:kRegistSuccess object:nil];
}

//登录
- (void)login{
    [[XMPPManager shareXMPPManager] loginWithUserName:self.nameTF.text passWord:self.passwordTF.text];
}

//注册
- (void)regist{
    [[XMPPManager shareXMPPManager] registerWithUserName:self.nameTF.text passWord:self.passwordTF.text];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createView{
    self.nameTF = [[UITextField alloc] initWithFrame:CGRectMake(30, 100, 150, 30)];
    _nameTF.placeholder = @"用户名";
    _nameTF.layer.borderWidth = 0.5;
    [self.view addSubview:self.nameTF];
    self.nameTF.text = @"1";
    
    self.passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(_nameTF.left, _nameTF.bottom + 30, _nameTF.width, _nameTF.height)];
    _passwordTF.placeholder = @"密码";
    _passwordTF.layer.borderWidth = 0.5;
    [self.view addSubview:self.passwordTF];
    self.passwordTF.text = @"1";
    
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _loginBtn.frame = CGRectMake(_passwordTF.left, _passwordTF.bottom + 20, _passwordTF.width, 50);
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    self.registBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _registBtn.frame = CGRectMake(_loginBtn.left, _loginBtn.bottom + 20, _loginBtn.width, 50);
    [_registBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_registBtn addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registBtn];
}

- (void)pushToRostersVC{
    RostersTableViewController *rostersVC = [[RostersTableViewController alloc] init];
    [self.navigationController pushViewController:rostersVC animated:YES];
}

- (void)registSuccess{
    self.nameTF.text = nil;
    self.passwordTF.text = nil;
}

@end
