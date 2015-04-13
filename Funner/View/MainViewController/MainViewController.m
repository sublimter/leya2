//
//  MainViewController.m
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import "MainViewController.h"
#import "HobbyViewController.h"
#import "NotificationViewController.h"

#import "CommonUtils.h"

#import "MainCagtegoryCell.h"

#import "CategoryData.h"
#import "NotificationData.h"
#import "BlogData.h"
#import "UserData.h"

#import "NoticeView.h"


@interface MainViewController () {
    CategoryData *mCategorySelected;
    NSInteger mnCurCateIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *mImgNoBlog;
@property (weak, nonatomic) IBOutlet UIButton *mButAddHobby;

@property (weak, nonatomic) IBOutlet NoticeView *mViewNotice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintNoticeTop;


@end

@implementation MainViewController

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
    
    // init data
    mnCurCateIndex = -1;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    //UIEdgeInsets的作用就是定义一个在scrollview被拽出一个contentOffset 的时候的一个空间配合blocks可以实现下拉刷新中footer部分的停留;这里用法不理解？
    UIEdgeInsets edgeTable = self.mTableView.contentInset;
    edgeTable.top = 64;
    edgeTable.bottom = utils.mTabbarController.tabBar.frame.size.height;
    [self.mTableView setContentInset:edgeTable];
    //设置组头
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    //设置组尾
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    //给添加按钮设置圆角
    [self.mButAddHobby.layer setMasksToBounds:YES];
    [self.mButAddHobby.layer setCornerRadius:10];
    
//    [self.tabBarController.tabBar setHidden:NO];
    
    [self.mViewNotice setAlpha:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //加载tableview
    [self reloadTable];
//    [self checkLatestBlog];
}

- (void)reloadTable {
    CommonUtils *utils = [CommonUtils sharedObject];
    if ([utils.maryCategory count] == 0) {
        return;
    }
    
    UserData *currentUser = [UserData currentUser];

    NSInteger nCount = [currentUser.maryCategory count];
    
    if (nCount > 0) {
//        UIColor *colorBack = [UIColor colorWithRed:0/255.0 green:89/255.0 blue:130/255.0 alpha:1.0];
//        [self.mTableView setBackgroundColor:colorBack];
        [self.mImgNoBlog setHidden:YES];
        [self.mButAddHobby setHidden:YES];
        [self.mTableView setHidden:NO];
    }
    else {
//        [self.mTableView setBackgroundColor:[UIColor clearColor]];
        
        //
        [self.mImgNoBlog setHidden:NO];
        [self.mButAddHobby setHidden:NO];
        [self.mTableView setHidden:YES];
    }
    //用reLoadData来实现刷新表格数据
    [self.mTableView reloadData];
}

- (void)checkLatestBlog {
    // check my category whether it has new blog or not
    UserData *currentUser = [UserData currentUser];
    //遍历数组中所有的元素
    for (CategoryData *cData in currentUser.maryCategory) {
        cData.mbGotLatest = NO;
        cData.mbGotNetworkLatest = NO;
        
        // get the latest blog
        AVRelation *relation = currentUser.latestblog;
        AVQuery *query = [relation query];
        //查询的结果：返回与当前对象的关系
        [query whereKey:@"category" equalTo:cData];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            cData.mbGotLatest = YES;
            cData.mBlogLatest = (BlogData *)object;
            
            NSLog(@"got mine: %@, %@", cData.objectId, cData.mBlogLatest.objectId);

            [self updateTableView];
        }];
        
        // get the latest blog data from network
        query = [BlogData query];
        [query whereKey:@"category" equalTo:cData];
        [query orderByDescending:@"createdAt"];
        [query whereKey:@"user" containedIn:[currentUser getRelatedUserArray]];
        
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (!error) {
                cData.mbGotNetworkLatest = YES;
                cData.mBlogNetworkLatest = (BlogData *)object;
                
                NSLog(@"got latest: %@, %@", cData.objectId, cData.mBlogNetworkLatest.objectId);

                [self updateTableView];
            }
            else {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

- (void)updateTableView {
    NSInteger nGotCount = 0;
    UserData *currentUser = [UserData currentUser];
    
    for (CategoryData *cData in currentUser.maryCategory) {
        if (cData.mbGotLatest && cData.mbGotNetworkLatest) {
            nGotCount++;
        }
    }
    
    if (nGotCount == [currentUser.maryCategory count]) {
        NSLog(@"main reloaddata");
        //刷新表
        [self reloadTable];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButNotification:(id)sender {
    [self performSegueWithIdentifier:@"Main2Notification" sender:nil];
}

- (IBAction)onButAddCategory:(id)sender {
//    [self.tabBarController setSelectedIndex:1];
    [self performSegueWithIdentifier:@"Main2Find" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//通知试图控制器继续执行。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Main2Hobby"]) {
        HobbyViewController *viewController =  [segue destinationViewController];
        viewController.mCategory = mCategorySelected;
    }
}

#pragma mark - TableViewDelegate
//设置分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	return 1 + ([maryNotifyData count] > 0);
    return 1;
}
//设置每个分组的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger nCount = 0;
    UserData *currentUser = [UserData currentUser];
    
	switch (section) {
		case 0:
//            if ([maryNotifyData count] > 0) {
//                nCount = 1;
//            }
//            else {
                nCount = [currentUser.maryCategory count];
//            }
            break;
            
//		case 1:
//			nCount = [currentUser.maryCategory count];
//            break;
            
		default:
			break;
	}
    
	return nCount;
}
//设置每一行cell的内容
- (UITableViewCell*)configureCategoryCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    UserData *currentUser = [UserData currentUser];
    
    MainCagtegoryCell *hobbyCell = (MainCagtegoryCell *)[tableView dequeueReusableCellWithIdentifier:@"MainHobbyCellID"];
    CategoryData *category = currentUser.maryCategory[indexPath.row];
    [hobbyCell showCategoryInfo:category];
    
    cell = hobbyCell;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        UIEdgeInsets edgeInset = UIEdgeInsetsZero;
        edgeInset.left = 50;
        [cell setSeparatorInset:edgeInset];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    
    if (indexPath.section == 0) {
//        if ([maryNotifyData count] > 0) {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"MainNotifyCellID"];
//            
//            UILabel *lblNum = (UILabel *)[cell viewWithTag:101];
//            
//            double dRadius = lblNum.frame.size.height / 2;
//            [lblNum.layer setMasksToBounds:YES];
//            [lblNum.layer setCornerRadius:dRadius];
//            [lblNum setHidden:YES];
//            
//            int nCount = 0;
//            for (NotificationData *notifyData in maryNotifyData) {
//                if ([notifyData.isnew boolValue]) {
//                    nCount++;
//                }
//            }
//            
//            if (nCount > 0) {
//                [lblNum setText:[NSString stringWithFormat:@"  %d  ", nCount]];
//                [lblNum setHidden:NO];
//            }
//        }
//        else {
            cell = [self configureCategoryCell:tableView cellForRowAtIndexPath:indexPath];
//        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_background.png"]];
//        }
    }
//    else {
//        cell = [self configureCategoryCell:tableView cellForRowAtIndexPath:indexPath];
//    }
    
	return cell;
}
//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGFloat height = ceil(screenWidth / 320.0 * 228.0);
    
    return height;
}

//选中某个cell的时候执行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserData *currentUser = [UserData currentUser];
    
	switch (indexPath.section) {
		case 0:
//            if ([maryNotifyData count] > 0) {
//                [self performSegueWithIdentifier:@"Main2Notification" sender:nil];
//            }
//            else {
                // get category data
                mCategorySelected = currentUser.maryCategory[indexPath.row];
                [self performSegueWithIdentifier:@"Main2Hobby" sender:nil];
//            }
			break;
            
//		case 1:
//            // get category data
//            mCategorySelected = currentUser.maryCategory[indexPath.row];
//            [self performSegueWithIdentifier:@"Main2Hobby" sender:nil];
//			break;
            
		default:
			break;
	}
}
#pragma mark - 设置编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        if ([maryNotifyData count] > 0) {
//            return UITableViewCellEditingStyleNone;
//        }
//        else {
//            return UITableViewCellEditingStyleDelete;
//        }
//    }
//    else {
        return UITableViewCellEditingStyleDelete;
//    }
}
#pragma mark - 设置处理编辑情况
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
//        mnCurCateIndex = indexPath.row;
//        
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
//                                                       message:@"您确定要删除这个爱好吗？"
//                                                      delegate:self
//                                             cancelButtonTitle:@"取消"
//                                             otherButtonTitles:@"删除",nil];
//        [alert show];
        
        [self removeCategory:indexPath.row];
    }
}

- (void)removeCategory:(NSInteger)nIndex {
    UserData *currentUser = [UserData currentUser];
    CategoryData *cData = currentUser.maryCategory[nIndex];
    
    [currentUser removeObject:cData forKey:@"category"];
    [currentUser.maryCategory removeObject:cData];

    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self reloadTable];
            
            [self.mViewNotice setMessage:[NSString stringWithFormat:@"%@已从您的频道列表中删除", cData.name]];
            [self showNotice];
        }
    }];
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        
    }
}

#pragma mark - notice
//发送通知
- (void)showNotice {
    CGFloat fContsraint = -7;
    
    // show notice
    [UIView animateWithDuration:0.5
                     animations:^{
                         //设置约束
                         [self.mConstraintNoticeTop setConstant:fContsraint + self.mViewNotice.frame.size.height];
                         [self.mViewNotice setAlpha:1];
//使用此方法强制立即进行layout,从当前view开始，此方法会遍历整个view层次(包括superviews)请求layout。因此，调用此方法会强制整个view层次布局。
                         [self.view layoutIfNeeded];
                         
                     }completion:^(BOOL finished) {
                         [self performSelector:@selector(hideNotice) withObject:nil afterDelay:2.0];
                     }];
}
//通知发送完成之后隐藏通知
- (void)hideNotice {
    CGFloat fContsraint = -7;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.mConstraintNoticeTop setConstant:fContsraint];
                         [self.mViewNotice setAlpha:0];
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL finished) {
                     }];
}



@end
