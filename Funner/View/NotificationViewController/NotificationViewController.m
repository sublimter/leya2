//
//  NotificationViewController.m
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"

#import "DetailViewController.h"
#import "MessageViewController.h"

#import "CommonUtils.h"

#import "UserData.h"
#import "ChatData.h"
#import "BlogData.h"
#import "NotificationData.h"

#import "NotificationChatCell.h"
#import "NotificationCommentCell.h"

#import "CDSessionManager.h"

#import <AVOSCloud/AVOSCloud.h>

typedef enum {
    NOTIFY_CHAT = 0,
    NOTIFY_COMMENT
} NotifyType;

typedef enum {
    NOTIFY_NEW = 0,
    NOTIFY_ALL
} NotifyCommentShowType;


@interface NotificationViewController () {
    NotificationData *mCurNotify;
    NotifyType mnType;
    NotifyCommentShowType mnCommentType;
    
    NSMutableArray *maryNotifyData;
    
    UserData *mUserSelected;
    BlogData *mBlogSelected;
    
    NSInteger mnCurChatIndex;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *mSegment;
@property (weak, nonatomic) IBOutlet UIImageView *mImgLogo;
@property (weak, nonatomic) IBOutlet UILabel *unreadChatDot;
@property (weak, nonatomic) IBOutlet UILabel *unreadCommentDot;


@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    mnType = NOTIFY_CHAT;
    mnCommentType = NOTIFY_NEW;
    
    maryNotifyData = [[NSMutableArray alloc] init];
    
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  
    [super viewWillAppear:animated];
    
    [self updateNotification: nil];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    mCurNotify = nil;
}


// Nicolas
- (NSInteger)updateNotification: (UserData *)targetUser {
    
    UserData *currentUser = [UserData currentUser];
    
    if (!currentUser) {
        return 0;
    }
    
    if (targetUser) {
        currentUser = targetUser;
    }
    
    NSInteger __block totalUnreadCount = 0;
    
    [self.unreadChatDot.layer setMasksToBounds: YES];
    [self.unreadChatDot.layer setCornerRadius: 5];
    [self.unreadCommentDot.layer setMasksToBounds:YES];
    [self.unreadCommentDot.layer setCornerRadius: 5];
    
    // 设置通知的red dot。
    NSInteger unreadChatCount = [[CDSessionManager sharedInstance] getUnreadCountForPeerId: nil];
    if (unreadChatCount > 0) {
        self.unreadChatDot.text = [NSString stringWithFormat:@"%ld", (long)unreadChatCount];
        [self.unreadChatDot setHidden: NO];
    } else {
        [self.unreadChatDot setHidden: YES];
    }
    
    totalUnreadCount += unreadChatCount;
    
    // load notification data
    AVQuery *query = [NotificationData query];
    [query whereKey:@"targetuser" equalTo: currentUser];
    //[query whereKey:@"isnew" equalTo:[NSNumber numberWithBool:YES]];
    //[query whereKey:@"user" notEqualTo:[UserData currentUser]];
    [query whereKey:@"type" greaterThanOrEqualTo:@(NOTIFICATION_COMMENT)];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [maryNotifyData removeAllObjects];
        
        if (!error) {
            
            NSInteger unreadComment = 0;
            
            for (NotificationData *obj in objects) {
                obj.user = [currentUser getRelatedUserData:obj.user friendOnly:NO];
                
                if ([obj.isnew boolValue]) {
                    unreadComment++;
                }
                
                [maryNotifyData addObject:obj];
            }
            
            if (unreadComment > 0) {
                self.unreadCommentDot.text = [NSString stringWithFormat:@"%ld", (long)unreadComment];
                [self.unreadCommentDot setHidden: NO];
                

            } else {
                [self.unreadCommentDot setHidden: YES];
            }
            
            totalUnreadCount += unreadComment;
            
            CommonUtils *utils = [CommonUtils sharedObject];
            UITabBarItem *item = [utils.mTabbarController.tabBar.items objectAtIndex: 2];
            if (totalUnreadCount > 0) {
                [item setBadgeValue:[NSString stringWithFormat:@"%ld", (long)totalUnreadCount]];
            } else {
                [item setBadgeValue:nil];
            }
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            currentInstallation.badge = totalUnreadCount;
            [currentInstallation saveEventually];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = totalUnreadCount;
            
            [self.mTableView reloadData];
        }
    }];
    
    return totalUnreadCount;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    mnCommentType = NOTIFY_NEW;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)setNotificationAsNotNew {
    for (NotificationData *nData in maryNotifyData) {
        if ([nData.isnew boolValue]) {
            nData.isnew = [NSNumber numberWithBool:NO];
            [nData saveInBackground];
        }
    }
    
    [self updateNotification: nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Notify2Detail"]) {
        DetailViewController *viewController = [segue destinationViewController];
        viewController.mBlogData = mCurNotify.blog;
        viewController.mNotificationData = mCurNotify;
        
        // 将此通知设置为已读
        mCurNotify.isnew = [NSNumber numberWithBool:NO];
        [mCurNotify saveInBackground];
        
        viewController.mnCommentType = mCurNotify.type;
    }
    else if ([[segue identifier] isEqualToString:@"Notify2Message"]) {
        MessageViewController *viewController = [segue destinationViewController];
        viewController.mBlog = mBlogSelected;
        viewController.mUser = mUserSelected;
    }
}

- (IBAction)onChangeSegment:(id)sender {
    mnType = (NotifyType)self.mSegment.selectedSegmentIndex;
    
    mnCommentType = NOTIFY_NEW;
    
    [self.mTableView reloadData];
}

#pragma mark - TableView

- (NSInteger)getRowCount {
    NSInteger nCount = 0;
    
    if (mnCommentType == NOTIFY_NEW) {
        for (NotificationData *notifyData in maryNotifyData) {
            if ([notifyData.isnew boolValue]) {
                nCount++;
            }
        }
    }
    else {
        nCount = [maryNotifyData count];
    }
    
    return nCount;
}

- (NotificationData *)getNotifyData:(NSInteger)nIndex {
    
    NotificationData *dataRet;
    NSInteger nCount = 0;
    
    if (mnCommentType == NOTIFY_NEW) {
        for (NotificationData *notifyData in maryNotifyData) {
            if (![notifyData.isnew boolValue]) {
                continue;
            }
            
            if (nCount == nIndex) {
                dataRet = notifyData;
                break;
            }
            
            nCount++;
        }
    }
    else {
        dataRet = [maryNotifyData objectAtIndex:nIndex];
    }
    
    return dataRet;
}

- (NSInteger)getOldCount {
    NSInteger nCount = 0;
    
    for (NotificationData *notifyData in maryNotifyData) {
        if (![notifyData.isnew boolValue]) {
            nCount++;
        }
    }
    
    return nCount;
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger nCount = 0;
    
    if (mnType == NOTIFY_CHAT) {
        CommonUtils *utils = [CommonUtils sharedObject];
        nCount = [utils.maryChatInfo count];
    }
    else {
        nCount = [self getRowCount];
    }
    
    BOOL bHidden = YES;
    if (nCount == 0) {
        if (mnType == NOTIFY_COMMENT) {
            if (mnCommentType == NOTIFY_NEW) {
                if ([self getOldCount] == 0) {
                    bHidden = NO;
                }
            }
        }
        else {
            bHidden = NO;
        }
    }

    [self.mImgLogo setHidden:bHidden];

    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (mnType == NOTIFY_CHAT) {
        NotificationChatCell *notifyChatCell = (NotificationChatCell *)[tableView dequeueReusableCellWithIdentifier:@"NotifyChatCellID"];
        
        CommonUtils *utils = [CommonUtils sharedObject];
        ChatData *cData = [utils.maryChatInfo objectAtIndex:indexPath.row];
        
        [notifyChatCell fillContent:cData];
        
        cell = notifyChatCell;
    }
    else {
        NotificationCommentCell *notifyCommentCell = (NotificationCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"NotifyCommentCellID"];
        NotificationData *notifyData = [self getNotifyData:indexPath.row];
        [notifyCommentCell fillContent:notifyData];
    
        cell = notifyCommentCell;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat fHeight = 63;
    
    return fHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (mnType == NOTIFY_CHAT) {
        CommonUtils *utils = [CommonUtils sharedObject];
        ChatData *cData = [utils.maryChatInfo objectAtIndex:indexPath.row];

        mUserSelected = cData.mUser;
        mBlogSelected = cData.mBlog;
        [self performSegueWithIdentifier:@"Notify2Message" sender:nil];
    }
    else {
        mCurNotify = [self getNotifyData:indexPath.row];
        [self gotoNotifyDetail];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        mnCurChatIndex = indexPath.row;
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您确定要删除这个记录吗？"
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"删除",nil];
        [alert show];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    int nHeight = 0;
    
    if (mnType == NOTIFY_COMMENT && mnCommentType == NOTIFY_NEW) {
        if ([self getOldCount] > 0) {
            nHeight = 40;
        }
    }
    
    return nHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view;
    
    if (mnType == NOTIFY_COMMENT && mnCommentType == NOTIFY_NEW) {
        if ([self getOldCount] > 0) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
            UIButton *butShowAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
            butShowAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
            [butShowAll.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [butShowAll setTitle:@"显示更早消息" forState:UIControlStateNormal];
            [butShowAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [butShowAll addTarget:self action:@selector(onButShowAll:) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:butShowAll];
        }
    }
    
    return view;
}


#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (mnType == NOTIFY_CHAT) {
            CommonUtils *utils = [CommonUtils sharedObject];
            ChatData *cData = [utils.maryChatInfo objectAtIndex:mnCurChatIndex];
            
            [[CDSessionManager sharedInstance] deleteMessagesForBlogId:cData.mBlog.objectId];
            
            [utils.maryChatInfo removeObjectAtIndex:mnCurChatIndex];
            [self.mTableView reloadData];
        }
        else {
            NotificationData *notifyData = [maryNotifyData objectAtIndex:mnCurChatIndex];
            [notifyData deleteInBackground];
            [maryNotifyData removeObjectAtIndex:mnCurChatIndex];
            [self.mTableView reloadData];
        }

    }
}



#pragma mark -

- (void)onButShowAll:(id)sender {
    mnCommentType = NOTIFY_ALL;
    [self.mTableView reloadData];
}

- (void)gotoNotifyDetail {
    [self performSegueWithIdentifier:@"Notify2Detail" sender:nil];
}

- (void)showRightMenu {
    UIBarButtonItem *rightButton = nil;
    
    // check if the current category is mine
    if ([maryNotifyData count] > 0) {
        rightButton = [[UIBarButtonItem alloc] initWithTitle:@"清空"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(onButClear:)];
        
        [self.mTableView setHidden:NO];
    }
    else {
        [self.mTableView setHidden:YES];
    }
    
    [self.navigationItem setRightBarButtonItem:rightButton];
}

- (IBAction)onButClear:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您确定要删除所有的消息吗？"
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"删除",nil];
    [alert show];
}

//#pragma mark - Alert Delegate
//- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1)
//    {
//        for (NotificationData *notifyData in maryNotifyData) {
//            notifyData[@"isread"] = [NSNumber numberWithBool:YES];
//            [notifyData saveInBackground];
//        }
//        [maryNotifyData removeAllObjects];
//        
//        [self showRightMenu];
//        
//        mnCommentType = NOTIFY_ALL;
//        [self.mTableView reloadData];
//    }
//}


@end
