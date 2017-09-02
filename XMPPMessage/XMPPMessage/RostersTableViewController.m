//
//  RostersTableViewController.m
//  EXchatxmpp
//
//  Created by wht on 2017/8/19.
//  Copyright © 2017年 wht. All rights reserved.
//

#import "RostersTableViewController.h"
#import "XMPPManager.h"
#import "CHUserInformation.h"
#import "ChatTableViewController.h"

@interface RostersTableViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic)UITextField *addText;


//所有好友列表数组.
@property (nonatomic ,strong)NSMutableArray * rosterList;

@property   (nonatomic,strong)NSMutableArray *array;
@property   (nonatomic,strong)NSMutableArray *emptyArr;
@property   (nonatomic,strong)NSMutableDictionary *friendSectionDic;
@property   (nonatomic,strong)NSMutableDictionary *emptyDic;

@property   (nonatomic,strong)NSMutableArray *sectionArr;//几个分组
@property   (nonatomic,strong)UIImageView *imageViewOne;
@property   (nonatomic,assign)int flag ;

@end

@implementation RostersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //添加好友的左按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriendsMethod)];
    
    //通知中心添加一个监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRoster) name:K_reloadFriendList object:nil];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTitle:@"删除好友"];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)setEditing:(BOOL)editing{
    [super setEditing:editing];
    [self setEditing:editing];
}

//添加删除好友时调用刷新好友列表
- (void)reloadRoster{
    self.friendSectionDic = [[NSMutableDictionary alloc]init];
    NSMutableArray *arr = [[XMPPManager shareXMPPManager] friendArr];
    NSMutableArray *sectionArr = [[NSMutableArray alloc]init];
    for (CHUserInformation *user in arr) {
        int flag = 0;
        for (NSString *group in sectionArr) {
            if ([user.group isEqualToString:group]) {
                flag = 1;
                break;
            }
        }
        if (flag==0) {
            [sectionArr addObject:user.group];
            NSMutableArray *rowArr = [[NSMutableArray alloc]init];
            [rowArr addObject:user];
            [self.friendSectionDic setObject:rowArr forKey:user.group];
        }else{
            NSMutableArray *rowArr = [self.friendSectionDic objectForKey:user.group];
            [rowArr addObject:user];
        }
    }
    self.emptyDic = [[NSMutableDictionary alloc]init];
    self.sectionArr = sectionArr;
    for (NSString *str in self.sectionArr) {
        NSMutableArray *emptyArr = [[NSMutableArray alloc]init];
        [self.emptyDic setObject:emptyArr forKey:str];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sectionArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.emptyDic objectForKey:[self.sectionArr objectAtIndex:section]] count];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.tag = section+100;
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *UpView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
    UpView.backgroundColor = [UIColor brownColor];
    UpView.alpha = 0.2;
    [view addSubview:UpView];
    
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, 320, 1)];
    downView.backgroundColor = [UIColor brownColor];
    downView.alpha = 0.2;
    [view addSubview:downView];
    
    UIImageView *imageViewTwo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 16, 16)];
    // imageViewTwo.image = [UIImage imageNamed:@"分组.png"];
    NSArray *array = [_emptyDic objectForKey:[_sectionArr objectAtIndex:section]];
    if (array.count <1) {
        imageViewTwo.image = [UIImage imageNamed:@"分组.png"];
    }else{
        imageViewTwo.image = [UIImage imageNamed:@"展开@2x.png"];
    }
    NSArray *array1 ;
    NSArray *arr = [_emptyDic objectForKey:[_sectionArr objectAtIndex:section]];
    NSArray *arr1 = [_friendSectionDic objectForKey:[_sectionArr objectAtIndex:section]];
    if (arr.count >0 ){
        array1 = arr;
    }else if (arr1.count >0)
    {
        array1 = arr1;
    }
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(280, 0,30 , 40)];
    NSString *number = [NSString stringWithFormat:@"(%lu)",(unsigned long)array1.count];
    label1.font = [UIFont systemFontOfSize:12];
    label1.text = number;
    label1.textAlignment = NSTextAlignmentRight;
    [view addSubview:label1];
    
    imageViewTwo.tag = section+200;
    [view addSubview:imageViewTwo];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 100, 40)];
    NSString *str = [_sectionArr objectAtIndex:section];
    label.text = str;
    [view addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change:)];
    [view addGestureRecognizer:tap];
    return view;
    
}

- (void)change:(UITapGestureRecognizer*)taap{
    UIView *view = [taap view];
    NSInteger sec = view.tag - 100;
    NSMutableArray *array = [_emptyDic objectForKey:[_sectionArr objectAtIndex:sec]];
    NSMutableArray *arr = [_friendSectionDic objectForKey:[_sectionArr objectAtIndex:sec]];
    
    [_emptyDic setObject:arr forKey:[_sectionArr objectAtIndex:sec]];
    [_friendSectionDic setObject:array forKey:[_sectionArr objectAtIndex:sec]];
    [self.tableView reloadData];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CHUserInformation *user = [[_emptyDic objectForKey:[_sectionArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RosterCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RosterCell"];
    }
    cell.textLabel.text = user.name;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewController *chatTVC = [[ChatTableViewController alloc] initWithStyle:UITableViewStylePlain];
    // 将当前好友的JID传到聊天界面
    CHUserInformation *user = [[_emptyDic objectForKey:[_sectionArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    chatTVC.chatWithJID = user.jid;
    [self.navigationController pushViewController:chatTVC animated:YES];
}

//添加好友
- (void)addFriendsMethod{
    NSLog(@"manager - 添加好友 %d", __LINE__);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"请输入要添加好友的名字" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self)weakSelf = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        // 接收输入的好友名字
        weakSelf.addText = textField;
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"======%@", weakSelf.addText.text);
        [[XMPPManager shareXMPPManager] addFriendWithuserName:weakSelf.addText.text nikeName:nil];
    }];
    [alertController addAction:sureAction];
    [alertController addAction:cancleAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // 删除一个好友
//        XMPPJID *jid = self.allRosterArray[indexPath.row];
//        // 根据名字删除好友
//        [[XMPPManager sharedXMPPManager] removeFriendWithName:jid.user];
//        // 从数组中移除
//        [self.allRosterArray removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        
//    }
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CHUserInformation *user = [[_emptyDic objectForKey:[_sectionArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        
        [[XMPPManager shareXMPPManager] deleteFriendWithuserName:user.name];
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

//        //找到要删除的人
//        XMPPJID *jid = self.rosterJids[indexPath.row];
//        //从数组中删除
//        [self.rosterJids removeObjectAtIndex:indexPath.row];
//        //从Ui单元格删除
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic
//         ];
//        //从服务器删除
//        [[XMPPManager defaultManager].xmppRoster removeUser:jid];
        

        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;//在线好友,全部好友
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@" [XMPPManager shareXMPPManager].rosterList.count     %lu",  (unsigned long)[XMPPManager shareXMPPManager].rosterList.count);
//    return [XMPPManager shareXMPPManager].rosterList.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RosterCell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RosterCell"];
//    }
//    CHUserInformation *info =  (CHUserInformation *)[[XMPPManager shareXMPPManager] rosterObjectAtIndex:indexPath.row];
//    cell.textLabel.text = info.name;
//    return cell;
//}

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
