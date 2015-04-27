//
//  InputCommentView.h
//  Funner
//
//  Created by highjump on 15-3-31.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@protocol InputCommentViewDelegate
- (void)onSentComment:(BOOL)bSucceed;
@end


@interface InputCommentView : UIView

@property (strong) BlogData *mBlogData;
@property (nonatomic) int mnCommentType;//评论类型
@property (weak, nonatomic) IBOutlet UITextField *mTxtComment;
@property (nonatomic, strong) NSString *user;

@property (strong) id <InputCommentViewDelegate> delegate;

@end
