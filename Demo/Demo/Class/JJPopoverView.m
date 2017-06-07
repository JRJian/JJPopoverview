//
//  JJPopoverView.m
//  JJPopoverView
//
//  Created by chenjiantao on 16/4/11.
//  Copyright © 2016年 chenjiantao. All rights reserved.
//

#import "JJPopoverView.h"
#import "JJPopoverViewConfiguration.h"
#import "UIImage+ImageEffects.h"

#import "JJEditorContentView.h"
#import "JJMessageContentView.h"

@interface JJPopoverView()

// 内容
@property (nonatomic, strong) UIView <JJPopoverContentViewProtocol> *contentView;

// 圆角
@property (nonatomic, assign) CGFloat boxRadius;

@end

@implementation JJPopoverView {
    UIView *_parentView;
    UIView *_topView;
    CGPoint _arrowPoint;
    CGFloat _arrowHeight;
    CGFloat _arrowHorizontalPadding;
    CGRect  _boxFrame;
    CGFloat _cpOffset; // 圆角控制点，用来绘图的时候画圆角用
    BOOL _above;
    BOOL _animating;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
}

+ (JJPopoverView *)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view messages:(NSString *)message delegate:(id<JJPopoverViewDelegate>)delegate {
    JJPopoverView *popover = [[JJPopoverView alloc] init];
    popover.delegate = delegate;
    [popover showAtPoint:point inView:view message:message];
    return popover;
}

+ (JJPopoverView *)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view titles:(NSArray *)titles delegate:(id<JJPopoverViewDelegate>)delegate {
    JJPopoverView *popover = [[JJPopoverView alloc] init];
    popover.delegate = delegate;
    [popover showAtPoint:point inView:view titles:titles];
    return popover;
}

+ (JJPopoverView *)showPopoverAtPoint:(CGPoint)point inView:(UIView *)view titles:(NSArray *)titles colors:(NSArray *)colors selectedIndex:(NSInteger)selectedIndex delegate:(id<JJPopoverViewDelegate>)delegate {
    JJPopoverView *popover = [[JJPopoverView alloc] init];
    popover.delegate = delegate;
    [popover showAtPoint:point inView:view titles:titles colors:colors selectedIndex:selectedIndex];
    return popover;
}

- (void)showAtPoint:(CGPoint)point inView:(UIView *)view message:(NSString *)message {
    JJMessageContentView *contentView = [[JJMessageContentView alloc] initWithMessage:message inView:view];
    [self showAtPoint:point inView:view contentView:contentView];
}

- (void)showAtPoint:(CGPoint)point inView:(UIView *)view titles:(NSArray *)titles {
    JJEditorContentView *contentView = [[JJEditorContentView alloc] initWithTitles:titles inView:view];
    [self showAtPoint:point inView:view contentView:contentView];
}

- (void)showAtPoint:(CGPoint)point inView:(UIView *)view titles:(NSArray *)titles colors:(NSArray *)colors selectedIndex:(NSInteger)selectedIndex {
    JJEditorContentView *contentView = [[JJEditorContentView alloc] initWithTitles:titles colors:colors selectedIndex:selectedIndex inView:view];
    [self showAtPoint:point inView:view contentView:contentView];
}

- (void)showAtPoint:(CGPoint)point inView:(UIView *)view contentView:(UIView<JJPopoverContentViewProtocol> *)contentView {
    
    self.contentView = contentView;
    _parentView = view;
    _topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    
    [self _bindActions];
    [self _setupLayout:point inView:view];
    
    // 在开始动画之前，设置透明色和缩放
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    // 动画到完整尺寸
    // 开始先放大到 1.05 倍，然后缩小到 1.0
    // 这两个动画会展示出类似弹簧效果
    _animating = YES;
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.f;
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _animating = NO;
        }];
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (void)_customInit {
    self.backgroundColor = [UIColor clearColor];
    _arrowHeight = 12.0f;
    _cpOffset = 1.8f;
    _arrowHorizontalPadding = 5.0f;
    _boxRadius = 4.0f;
}

- (void)_bindActions {
    for (UIControl *ctl in self.contentView.items) {
        if ([ctl isKindOfClass:[UIControl class]]) {
            [ctl addTarget:self action:@selector(didTapItems:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)_setupLayout:(CGPoint)point inView:(UIView *)view {
    
    CGPoint topPoint = [_topView convertPoint:point fromView:view];
    
    // 记录箭头出现位置
    _arrowPoint = topPoint;
    
    CGRect topViewBounds = _topView.bounds;
    
    float contentHeight = CGRectGetHeight(_contentView.frame);
    float contentWidth  = CGRectGetWidth(_contentView.frame);
    
    float padding   = k_JJPV_boxPadding;
    
    float boxHeight = contentHeight + 2.0f * padding;
    float boxWidth  = contentWidth  + 2.0f * padding;
    
    // popover 的左上方起始点
    float xOriginForBox = 0.f;
    
    float rightBoundary = CGRectGetWidth(topViewBounds) - k_JJPV_horizontalMargin - _boxRadius - _arrowHorizontalPadding;
    float leftBoundary  = k_JJPV_horizontalMargin + _boxRadius + _arrowHorizontalPadding;
    
    // 确保箭头能够被画出来
    if (_arrowPoint.x + _arrowHeight > rightBoundary) {// 超出了右边界
        _arrowPoint.x = rightBoundary - _arrowHeight;
    } else if (_arrowPoint.x - _arrowHeight < leftBoundary) {// 超出了做边界
        _arrowPoint.x = leftBoundary + _arrowHeight;
    }
    
    // 默认 popoverView 在箭头的中间
    xOriginForBox = floorf(_arrowPoint.x - boxWidth * 0.5f);
    
    // 检测 xOriginForBox 的值是否让 popoverView 超出了屏幕范围
    if (xOriginForBox < CGRectGetMinX(topViewBounds) + k_JJPV_horizontalMargin) {
        xOriginForBox = CGRectGetMinX(topViewBounds) + k_JJPV_horizontalMargin;
    } else if (xOriginForBox + boxWidth > CGRectGetMaxX(topViewBounds) - 2 * k_JJPV_horizontalMargin) {
        xOriginForBox = CGRectGetMaxX(topViewBounds) - k_JJPV_horizontalMargin - boxWidth;
    }
    
    // 是否向上弹出
    _above = YES;
    
    if (topPoint.y - contentHeight - _arrowHeight - k_JJPV_topMargin < CGRectGetMinY(topViewBounds)) {
        
        // 向下弹出，因为箭头上方的空间不足够显示一个 popoverView
        _above = NO;
        
        _boxFrame = CGRectMake(xOriginForBox, _arrowPoint.y + _arrowHeight, boxWidth, boxHeight);
    } else {
        
        _above = YES;
        
        _boxFrame = CGRectMake(xOriginForBox, _arrowPoint.y - _arrowHeight - boxHeight, boxWidth, boxHeight);
    }
    
    // 重新确定 contentView 尺寸
    CGRect contentFrame = CGRectMake(_boxFrame.origin.x + padding, _boxFrame.origin.y + padding, contentWidth, contentHeight);
    _contentView.frame = contentFrame;
    
    // 我么需要针对用户的弹出效果，设置图层的 anchorPoint。
    // 在设置视图的 frame 值之前需要先设置 anchorPoint，
    // 因为设置 anchorPoint 会隐式的设置 view 的 frame，我们并不想看到这个效果。
    self.layer.anchorPoint = CGPointMake(_arrowPoint.x / CGRectGetWidth(topViewBounds), _arrowPoint.y / CGRectGetHeight(topViewBounds));
    self.frame = topViewBounds;
    [self setNeedsDisplay];
    
    // 添加到视图上
    [self addSubview:_contentView];
    [_topView addSubview:self];
    
    // 给最外层的视图(self)添加点击事件，为了点击让 popoverView 消失
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;// 允许在 UITableView 或者其他可点击的视图内点击。
    [self addGestureRecognizer:tap];
    
    self.userInteractionEnabled = YES;
}

#pragma mark - 绘弹出框

- (void)drawRect:(CGRect)rect {
    
    // 构建 popover 路径
    CGRect frame = _boxFrame;
    
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    
    float xMax = CGRectGetMaxX(frame);
    float yMax = CGRectGetMaxY(frame);
    
    float cpOffset = _cpOffset;
    
    float radius = _boxRadius;
    
    /*
        LT2           RT1
     LT1⌜⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⌝RT2
        |               |
        |    popover    |
        |               |
     LB2⌞_______________⌟RB1
        LB1           RB2
     
     顺时针方向绘图, 起点LT1
     L = Left
     R = Right
     T = Top
     B = Bottom
     1,2 = 代表圆角点的先后顺序
     
     */
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    
    // LT1
    [popoverPath moveToPoint:CGPointMake(xMin, yMin + radius)];
    
    // LT2
    [popoverPath addCurveToPoint:CGPointMake(xMin + radius, yMin) controlPoint1:CGPointMake(xMin, yMin + radius - cpOffset) controlPoint2:CGPointMake(xMin + radius - cpOffset, yMin)];
    
    // 如果箭头是显示在 popoverView 上方，那么箭头的位置在 LT2 到 RT1 横线之间
    if (!_above) {
        [popoverPath addLineToPoint:CGPointMake(_arrowPoint.x - _arrowHeight, yMin)];// 箭头左拐角点
        [popoverPath addCurveToPoint:_arrowPoint controlPoint1:CGPointMake(_arrowPoint.x - _arrowHeight + k_JJPV_arrowCurvature, yMin) controlPoint2:_arrowPoint];// 箭头位置
        [popoverPath addCurveToPoint:CGPointMake(_arrowPoint.x + _arrowHeight, yMin) controlPoint1:_arrowPoint controlPoint2:CGPointMake(_arrowPoint.x + _arrowHeight - k_JJPV_arrowCurvature, yMin)];// 箭头右拐角点
    }
    
    // RT1
    [popoverPath addLineToPoint:CGPointMake(xMax - radius, yMin)];
    
    // RT2
    [popoverPath addCurveToPoint:CGPointMake(xMax, yMin + radius) controlPoint1:CGPointMake(xMax - radius + cpOffset, yMin) controlPoint2:CGPointMake(xMax, yMin + radius - cpOffset)];
    
    // RB1
    [popoverPath addLineToPoint:CGPointMake(xMax, yMax - radius)];
    
    // RB2
    [popoverPath addCurveToPoint:CGPointMake(xMax - radius, yMax) controlPoint1:CGPointMake(xMax, yMax - radius + cpOffset) controlPoint2:CGPointMake(xMax - radius + cpOffset, yMax)];
    
    // 如果箭头显示在 popoverView 下方，那么箭头的位置在 RB2 到 LB1 横线之间
    if (_above) {
        [popoverPath addLineToPoint:CGPointMake(_arrowPoint.x + _arrowHeight, yMax)];// 箭头右拐角点
        [popoverPath addCurveToPoint:_arrowPoint controlPoint1:CGPointMake(_arrowPoint.x + _arrowHeight - k_JJPV_arrowCurvature, yMax) controlPoint2:_arrowPoint];// 箭头位置
        [popoverPath addCurveToPoint:CGPointMake(_arrowPoint.x - _arrowHeight, yMax) controlPoint1:_arrowPoint controlPoint2:CGPointMake(_arrowPoint.x - _arrowHeight + k_JJPV_arrowCurvature, yMax)];// 箭头左拐角点
    }
    
    // LB1
    [popoverPath addLineToPoint:CGPointMake(xMin + radius, yMax)];
    
    // LB2
    [popoverPath addCurveToPoint:CGPointMake(xMin, yMax - radius) controlPoint1:CGPointMake(xMin + radius - cpOffset, yMax) controlPoint2:CGPointMake(xMin, yMax - radius + cpOffset)];
    
    [popoverPath closePath];
    
    //// 通用声明
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// ios7模糊效果
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(_topView.bounds), CGRectGetHeight(_topView.bounds)), NO, 1);
 
    [_topView drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(_topView.bounds), CGRectGetHeight(_topView.bounds)) afterScreenUpdates:NO];
    
    __block UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    snapshot = [snapshot applyBlurWithCrop:_topView.bounds resize:_topView.bounds.size blurRadius:6 tintColor:[UIColor colorWithWhite:.8f alpha:.2f] saturationDeltaFactor:1.8f maskImage:nil];
    
    //// 阴影
    UIColor* shadow = [UIColor colorWithWhite:0.0f alpha:0.4f];
    CGSize shadowOffset = CGSizeMake(0, 1);
    CGFloat shadowBlurRadius = 3.0f;

    //// 绘制背景
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    CGContextBeginTransparencyLayer(context, NULL);
    [popoverPath addClip];
    
    // 翻转Y轴进行图片渲染
    CGContextTranslateCTM(context, 0, CGRectGetHeight(_topView.bounds));
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, _topView.bounds, snapshot.CGImage);
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
}

#pragma mark 点击事件

- (void)didTapItems:(id)sender {
    NSUInteger tapIndex = [self.contentView.items indexOfObject:sender];
    
    if (_delegate && [_delegate respondsToSelector:@selector(popoverView:didSelectItemAtIndex:)]) {
        [_delegate popoverView:self didSelectItemAtIndex:tapIndex];
    }
}

- (void)tapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:_contentView];
    
    BOOL found = NO;
    NSArray *items = self.contentView.items;
    
    for (int i = 0; i < items.count && !found; i++) {
        UIView *view = [items objectAtIndex:i];
        
        if (CGRectContainsPoint(view.frame, point)) {
            // 找到点击的按钮，通知代理
            found = YES;

            if ([view isKindOfClass:[UIButton class]]) {
                return;
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(popoverView:didSelectItemAtIndex:)]) {
                [_delegate popoverView:self didSelectItemAtIndex:i];
            }
            
            break;
        }
    }
    
    if (!found && CGRectContainsPoint(_contentView.bounds, point)) {
        found = YES;
    }
    
    if (!found) {
        [self dismiss:YES];
    }
}

#pragma mark 消失

- (void)dismiss {
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated {
    if (_animating) {
        return;
    }
    _animating = YES;
    if (!animated) {
        [self dismissComplete];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0.1f;
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        } completion:^(BOOL finished) {
            self.transform = CGAffineTransformIdentity;
            [self dismissComplete];
        }];
    }
}

- (void)dismissComplete {
    [self removeFromSuperview];
    
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewDidDismiss:)]) {
        [_delegate popoverViewDidDismiss:self];
    }
    
    _animating = NO;
}

#pragma mark - Private
#pragma mark 屏幕尺寸

- (CGSize)jj_screenSize {
    UIApplication *application          = [UIApplication sharedApplication];
    UIInterfaceOrientation orientation  = application.statusBarOrientation;
    CGSize size                         = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

@end
