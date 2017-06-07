//
//  JJEditorContentView.h
//  JJPopoverView
//
//  Created by chenjiantao on 16/4/12.
//  Copyright © 2016年 chenjiantao. All rights reserved.
//

/** 
 
 编辑弹出框
 
 */

#import <UIKit/UIKit.h>
#import "JJPopoverContentViewProtocol.h"

@interface JJEditorContentView : UIView <JJPopoverContentViewProtocol>

/**
 *  文本字体
 */
@property (nonatomic, copy) UIFont  *textFont;

/**
 *  文本颜色
 */
@property (nonatomic, copy) UIColor *textColor;

/**
 *  文本高亮色
 */
@property (nonatomic, copy) UIColor *textHighlightColor;

/**
 *  一个普通选择器的弹出框内容视图
 *
 *  @param titles 编辑项字符串数组
 *  @param view   父视图
 *
 *  @return 内容视图
 */

- (instancetype)initWithTitles:(NSArray *)titles inView:(UIView *)view;

/**
 *  一个带有颜色选择器的弹出框内容视图
 *
 *  @param titles        编辑项字符串数组
 *  @param colors        编辑颜色
 *  @param selectedIndex 选中颜色，如果传入 > || < colors.count，为全部未选中
 *  @param view          父视图
 *
 *  @return 内容视图
 */
- (instancetype)initWithTitles:(NSArray *)titles colors:(NSArray *)colors selectedIndex:(NSInteger)selectedIndex inView:(UIView *)view;

@end
