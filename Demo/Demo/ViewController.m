//
//  ViewController.m
//  Demo
//
//  Created by Jian on 2016/11/24.
//  Copyright © 2016年 jian. All rights reserved.
//

#import "ViewController.h"
#import "JJPopoverView.h"

@interface ViewController ()
<
JJPopoverViewDelegate
>
@property (nonatomic, weak) JJPopoverView *popover;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    
    if (_popover) {
        [_popover dismiss];
    }
    
    CGFloat oneThirdH = CGRectGetHeight(self.view.bounds) * 0.33;
    if (point.y < oneThirdH) {
        _popover = [JJPopoverView showPopoverAtPoint:point
                                              inView:self.view
                                            messages:@"花崎（はなさき） 千雪（ちゆき）hanasaki tsiyuki桃沢（ももざわ） 卯雪（うゆき）momozawa uyuki琴南（ことなみ） 铃兰（すずらん）kotonami suzu ran秋山..."
                                            delegate:self];
    } else if (point.y > oneThirdH && point.y < 2 * oneThirdH) {
        _popover = [JJPopoverView showPopoverAtPoint:point
                                              inView:self.view
                                              titles:@[@"宇智波·带土",
                                                       @"宇智波·止水",
                                                       @"宇智波·佐助",
                                                       @"宇智波·斑",
                                                       @"宇智波·鼬"]
                                            delegate:self];
    } else {
        _popover = [JJPopoverView showPopoverAtPoint:point
                                              inView:self.view
                                              titles:@[@"宇智波·带土",
                                                       @"宇智波·止水",
                                                       @"宇智波·佐助",
                                                       @"宇智波·斑",
                                                       @"宇智波·鼬",
                                                       @"宇智波·泉奈",
                                                       @"宇智波·富岳",
                                                       @"宇智波·美琴",
                                                       @"宇智波·镜"]
                                              colors:@[[UIColor yellowColor],
                                                       [UIColor magentaColor],
                                                       [UIColor orangeColor],
                                                       [UIColor purpleColor],
                                                       [UIColor brownColor]]
                                       selectedIndex:1
                                            delegate:self];
    }
}

#pragma mark - <JJPopoverViewDelegate>

- (void)popoverView:(JJPopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"点击了:%ld", index);
}

- (void)popoverViewDidDismiss:(JJPopoverView *)popoverView {
}

@end
