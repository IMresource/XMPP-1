//
//  ChatTableViewController.m
//  EXchatxmpp
//
//  Created by wht on 2017/8/22.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatTableViewCell.h"

@interface ChatTableViewController ()

@property (strong, nonatomic)NSMutableArray *allMessageArray;

@property (strong, nonatomic)UITextField *messageTF;

@end

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.chatWithJID.user;
    
    UIView *aView= [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height -150, self.view.width, 50)];
    aView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:aView];
    
    self.messageTF = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, aView.width -20, 30)];
    self.messageTF.placeholder = @"发送消息";
    self.messageTF.backgroundColor = [UIColor whiteColor];
    [aView addSubview:_messageTF];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(aView.width - 50, 150, 50, _messageTF.height);
    [btn addTarget:self action:@selector(showMessage) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:btn];
    
    
    self.allMessageArray = [NSMutableArray array];
    // 隐藏分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 注册cell
    [self.tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatCell"];
    // 发送按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    // 取消按钮 20
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessageAction)];
//    [[XMPPManager shareXMPPManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessage) name:kShowMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageFail) name:kMessageFail object:nil];
    
    // 获取显示消息的方法
    [self showMessage];
    
}

- (void)messageFail{
    NSLog(@"消息发送失败");
}

#pragma mark - 取消按钮点击事件
- (void)cancelAction {
    // 返回上一界面
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 发送消息按钮点击事件
- (void)sendMessageAction {
    if (!self.messageTF.text) {
        return;
    }
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatWithJID];
    // 设置message的body为固定值 (没有实现发送自定义消息)
    [message addBody:self.messageTF.text];
    // 通过通道进行消息发送
    [[XMPPManager shareXMPPManager].stream sendElement:message];
    self.messageTF.text = nil;
}

#pragma mark - 显示消息
- (void)showMessage {
    NSLog(@"显示消息");

    // 获取管理对象上下文
    NSManagedObjectContext *context = [XMPPManager shareXMPPManager].manageVcardContext;
    // 初始化请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 获取实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    // 设置查询请求的实体
    [request setEntity:entity];
    // 设置谓词查询 (当前用户的jid，对方用户的jid)  (根据项目需求而定)
    request.predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@",[XMPPManager shareXMPPManager].stream.myJID.bare,self.chatWithJID.bare];
    // 按照时间顺序排列
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:@[sort]];
    // 获取到存储在数据库中的聊天记录
    NSArray *resultArray = [context executeFetchRequest:request error:nil];
    // 先清空消息数组 （根据项目需求而定）
    [self.allMessageArray removeAllObjects];
    // 将结果数组赋值给消息数组
    self.allMessageArray = [resultArray mutableCopy];
    // 刷新UI
    [self.tableView reloadData];
    // 当前聊天记录跳到最后一行
    if (self.allMessageArray.count > 0) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.allMessageArray.count - 1 inSection:0];
        // 跳到最后一行
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    }
    [context save:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"self.allMessageArray    %@", self.allMessageArray);
    return self.allMessageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    // 数组里存储的是XMPPMessageArchiving_Message_CoreDataObject对象
    XMPPMessageArchiving_Message_CoreDataObject *message = [self.allMessageArray objectAtIndex:indexPath.row];
    // 设置cell中的相关数据
    // 根据isOutgoing判断是不是对方发送过来的消息 YES - 对方发送的消息， NO - 自己发送给对方的消息
    cell.isOut = message.isOutgoing;
    cell.message = message.body;
    NSLog(@"message.body   %@", message.body);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // cell的高度并没有自适应
    return 70;
}

#pragma mark - ------------XMPPStreamDelegate相关代理------------
//#pragma mark - 已经发送消息
//- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
//    // 重新对消息进行操作
//    [self showMessage];
//}
//#pragma mark - 已经接收消息
//- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
//    // 重新对消息进行操作
//    [self showMessage];
//}
//
//#pragma mark - 消息发送失败
//- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
//    NSLog(@"消息发送失败");
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
