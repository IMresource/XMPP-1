//
//  LoginViewController.m
//  XMPPMessage
//
//  Created by wht on 2017/8/31.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "LoginViewController.h"
#import "RegistViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic)UITextField *nameTF;
@property (strong, nonatomic)UITextField *pwdTF;
@property (strong, nonatomic)UIButton *loginBtn;
@property (strong, nonatomic)UIButton *forgetBtn;
@property (strong, nonatomic)UIButton *registBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:K_loginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFail) name:K_loginFail object:nil];
    
    [self createView];
}

- (void)userlogin{
    NSLog(@"用户登录");
    if (self.nameTF.text.length > 0 && self.pwdTF.text.length > 0) {
        [[XMPPManager shareXMPPManager] loginWithUserName:self.nameTF.text passWord:self.pwdTF.text];
    }else{
        [[AlertController shareManager] alertControllerWithTitle:@"提示" message:@"请填写正确的账号密码" preferredStyle:UIAlertControllerStyleAlert acceptTitle:@"确定" accepthandler:nil rejecttitle:nil rejecthandler:nil];
    }
}

//登录成功
- (void)loginSuccess{
    NSLog(@"登录成功");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//登录失败
- (void)loginFail{
    NSLog(@"登录失败");
}

- (void)forgetPassword{
    NSLog(@"忘记密码");
}

- (void)registNewUser{
    NSLog(@"用户注册");
    RegistViewController *registVC = [[RegistViewController alloc] init];
    [self.navigationController pushViewController:registVC animated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_loginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_loginFail object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createView{
    self.nameTF = [self textFieldWithFrame:CGRectMake(50, 100, 220, 50) placeholder:@"账号"];
    [self.view addSubview:_nameTF];
    self.nameTF.text = @"1";
    
    self.pwdTF = [self textFieldWithFrame:CGRectMake(_nameTF.left, _nameTF.bottom + 30, _nameTF.width, _nameTF.height) placeholder:@"密码"];
    [self.view addSubview:_pwdTF];
    self.pwdTF.text = @"1";
    
    self.loginBtn = [self buttonWithFrame:CGRectMake(_pwdTF.left + 30, _pwdTF.bottom + 30, 150, 30) title:@"登录" target:self action:@selector(userlogin)];
    [self.view addSubview:_loginBtn];
    
    self.forgetBtn = [self buttonWithFrame:CGRectMake(_pwdTF.left, _loginBtn.bottom +30, 100, 30) title:@"忘记密码" target:self action:@selector(forgetPassword)];
    [self.view addSubview:_forgetBtn];
    
    self.registBtn = [self buttonWithFrame:CGRectMake(_forgetBtn.right + 20, _forgetBtn.top, _forgetBtn.width, _forgetBtn.height) title:@"用户注册" target:self action:@selector(registNewUser)];
    [self.view addSubview:_registBtn];
}

- (UITextField *)textFieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder{
    UITextField *tf = [[UITextField alloc] initWithFrame:frame];
    tf.placeholder = placeholder;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, tf.height - 0.5, tf.width, 0.5)];
    label.backgroundColor = [UIColor grayColor];
    [tf addSubview:label];
    return tf;
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
