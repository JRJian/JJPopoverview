//
//  JJMessageContentView.h
//  JJPopoverView
//
//  Created by chenjiantao on 16/4/12.
//  Copyright © 2016年 chenjiantao. All rights reserved.
//

/**
 
 消息弹出框
 
 */

#import <UIKit/UIKit.h>
#import "JJPopoverContentViewProtocol.h"

@interface JJMessageContentView : UIView <JJPopoverContentViewProtocol>

/**
 *  文本字体
 */
@property (nonatomic, copy) UIFont  *textFont;

/**
 *  文本颜色
 */
@property (nonatomic, copy) UIColor *textColor;

/**
 *  一个带有普通文本的弹出框内容视图
 *
 *  @param message 消息
 *  @param view    父视图
 *
 *  @return 内容视图
 */
- (instancetype)initWithMessage:(NSString *)message inView:(UIView *)view;

@end
