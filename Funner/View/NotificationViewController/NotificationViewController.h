//
//  NotificationViewController.h
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import <UIKit/UIKit.h>

@class UserData;

@interface NotificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

- (NSInteger)updateNotification: (UserData *)targetUser;

//@property (strong) NSMutableArray *maryNotification;

@end
