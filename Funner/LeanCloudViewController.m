
//  LeanCloudViewController.m
//  Funner
//
//  Created by zhaopeng on 15/4/25.
//
//

#import "LeanCloudViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface LeanCloudViewController ()

@end

@implementation LeanCloudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     *查询数据  创建一个AVQuery 对象  GameScore是表名
     *whereKey 是约束条件
     *调用findObjectsInBackgroundWithBlock方法去查询数据  查询的结果在数组objects中
     */
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"sex" equalTo:@(1)];
    [query whereKey:@"sss" equalTo:@"asdfasd"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // 检索成功
            NSLog(@"Successfully retrieved %d scores.", objects.count);
        } else {
            // 输出错误信息
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
//    上传数据
    /*
     首先找到对象：AVObject objectWithoutDataWithClassName:@"album" objectId:@"553b37d0e4b0a3f0d0ea4fcd"];
     给对象赋值：[av setObject:@"asdfasd" forKey:@"name"];
     最后保存到leancloud 调save方法
     
     */
    AVObject *av = [AVObject objectWithoutDataWithClassName:@"album" objectId:@"553b37d0e4b0a3f0d0ea4fcd"];
    [av setObject:@"asdfasd" forKey:@"name"];
    [av saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // 上传成功

        } else {
            // 输出错误信息
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
