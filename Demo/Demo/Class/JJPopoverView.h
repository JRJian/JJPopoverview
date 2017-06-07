//
//  JJPopoverView.h
//  JJPopoverView
//
//  Created by chenjiantao on 16/4/11.
//  Copyright © 2016年 chenjiantao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJPopoverContentViewProtocol.h"

#pragma mark - Protocol

@class JJPopoverView;

@protocol JJPopoverViewDelegate <NSObject>

@optional

// 当 item 被选中时候，会触发这个代理通知
- (void)popoverView:(JJPopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index;

// 当弹出框消失之后，会触发这个代理通知
- (void)popoverViewDidDismiss:(JJPopoverView *)popoverView;

@end

@interface JJPopoverView : UIView

@property (nonatomic, readonly) UIView <JJPopoverContentViewProtocol> *contentView;
@property (nonatomic, weak) id<JJPopoverViewDelegate> delegate;

/**
 *  弹出一个带有提示信息的弹出框
 *
 *  @param point    弹出位置
 *  @param view     父视图
 *  @param message  提示信息
 *  @param delegate 代理
 *
 *  @return 弹出框
 */
+ (JJPopoverView *)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view messages:(NSString *)message delegate:(id <JJPopoverViewDelegate>)delegate;

/**
 *  弹出一个带有编辑项的弹出框
 *
 *  @param point    弹出位置
 *  @param view     父视图
 *  @param titles   编辑项字符串数组
 *  @param delegate 代理
 *
 *  @return 弹出框
 */
+ (JJPopoverView *)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view titles:(NSArray *)titles delegate:(id <JJPopoverViewDelegate>)delegate;

/**
 *  弹出一个带有丰富的编辑项的弹出框
 *
 *  @param point         弹出位置
 *  @param view          父视图
 *  @param titles        编辑项字符串数组
 *  @param colors        编辑颜色数组
 *  @param selectedIndex 选中颜色，如果传入 > || < colors.count，为全部未选中
 *  @param delegate      代理
 *
 *  @return 弹出框
 */
+ (JJPopoverView *)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view titles:(NSArray *)titles colors:(NSArray *)colors selectedIndex:(NSInteger)selectedIndex delegate:(id <JJPopoverViewDelegate>)delegate;

- (void)dismiss;

@end
