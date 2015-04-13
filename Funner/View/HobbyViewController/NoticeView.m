//
//  NoticeView.m
//  Funner
//
//  Created by highjump on 15-4-4.
//
//

#import "NoticeView.h"

@interface NoticeView()

@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;

@end

@implementation NoticeView

/*
// Only override drawRect: if you perform custom drawing.
//只覆盖drawRect:如果你执行自定义绘图。
// An empty implementation adversely affects performance during animation.
//一个空的在动画实现对性能造成不利影响。
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setMessage:(NSString *)strMsg {
    [self.mLblContent setText:strMsg];
}

@end
