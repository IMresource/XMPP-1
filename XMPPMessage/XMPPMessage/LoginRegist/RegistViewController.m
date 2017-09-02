//
//  RegistViewController.m
//  XMPPMessage
//
//  Created by wht on 2017/8/31.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "RegistViewController.h"

@interface RegistViewController ()

@property (strong, nonatomic)UITextField *nameTF;
@property (strong, nonatomic)UITextField *pwdTF;
@property (strong, nonatomic)UIButton *registBtn;

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registSuccess) name:K_registSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registFail) name:K_registFail object:nil];
    
    [self createView];
}

- (void)registNewUser{
    NSLog(@"用户注册");
    if (self.nameTF.text && self.pwdTF.text) {
    [[XMPPManager shareXMPPManager] registerWithUserName:self.nameTF.text passWord:self.pwdTF.text];
    }else{
        [[AlertController shareManager] alertControllerWithTitle:@"提示" message:@"请填写正确的账号密码" preferredStyle:UIAlertControllerStyleAlert acceptTitle:@"确定" accepthandler:nil rejecttitle:nil rejecthandler:nil];
    }
}

- (void)registSuccess{
    NSLog(@"注册成功");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registFail{
    NSLog(@"注册失败");
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_registSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_registFail object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createView{
    self.nameTF = [self textFieldWithFrame:CGRectMake(50, 100, 220, 50) placeholder:@"账号"];
    [self.view addSubview:_nameTF];
    
    self.pwdTF = [self textFieldWithFrame:CGRectMake(_nameTF.left, _nameTF.bottom + 30, _nameTF.width, _nameTF.height) placeholder:@"密码"];
    [self.view addSubview:_pwdTF];
    
    self.registBtn = [self buttonWithFrame:CGRectMake(_pwdTF.left + 30, _pwdTF.bottom + 50, 150, 30) title:@"注册" target:self action:@selector(registNewUser)];
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
