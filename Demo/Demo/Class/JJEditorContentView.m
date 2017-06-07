//
//  JJEditorContentView.m
//  JJPopoverView
//
//  Created by chenjiantao on 16/4/12.
//  Copyright © 2016年 chenjiantao. All rights reserved.
//

#import "JJEditorContentView.h"
#import "JJPopoverViewConfiguration.h"
#import "UIImage+ImageEffects.h"

@implementation JJEditorContentView {
    NSMutableArray *_items;
}

- (instancetype)initWithTitles:(NSArray *)titles inView:(UIView *)view {
    self = [super init];
    if (self) {
        [self _defaultInit];
        [self _addItems:titles inView:view offsetY:0 offsetIndex:0];
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray *)titles colors:(NSArray *)colors selectedIndex:(NSInteger)selectedIndex inView:(UIView *)view {
    self = [super init];
    if (self) {
        [self _defaultInit];
        // 加 1 是为了增加删除按钮
        [self _addItems:titles colors:[colors arrayByAddingObject:@""] selectedIndex:selectedIndex inView:view];
    }
    return self;
}

- (void)_defaultInit {
    _items = [NSMutableArray array];
    _textFont = [UIFont systemFontOfSize:14.0f];
    _textColor = K_JJPV_textColor;
    _textHighlightColor = [UIColor grayColor];
}

#pragma mark 添加颜色选项

- (void)_addItems:(NSArray *)titles colors:(NSArray *)colors selectedIndex:(NSInteger)selectedIndex inView:(UIView *)view {
    if (colors.count == 0) {
        [self _addItems:titles inView:view offsetY:0 offsetIndex:0];
    } else {
        
        CGFloat circleWidth = k_JJPV_circleWidth;
        int i = 0;
        
        for (UIColor *color in colors) {
            
            UIButton *item  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, circleWidth, circleWidth)];
            item.backgroundColor            = [UIColor clearColor];
            [item setSelected:selectedIndex == i];
            
            // 最后一个是删除按钮需要额外设置
            if (i == colors.count - 1) {
                [item setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
                [item setEnabled:selectedIndex < colors.count - 1 && selectedIndex >= 0];
            } else {
                UIImage *nimg = [UIImage circleImageWithColor:color size:CGSizeMake(circleWidth - 2, circleWidth - 2)];
                UIImage *simg = [UIImage circleImageWithColor:color size:CGSizeMake(circleWidth - 2, circleWidth - 2) borderColor:[UIColor whiteColor] borderWidth:1.0f];
                [item setImage:nimg forState:UIControlStateNormal];
                [item setImage:simg forState:UIControlStateSelected];
                [item setImage:simg forState:UIControlStateSelected | UIControlStateHighlighted];
            }
            
            [_items addObject:item];
            
            i++;
        }
        
        CGFloat maxY = [self _setupLayoutWithColorViews:_items inView:view];
        [self _addItems:titles inView:view offsetY:maxY + k_JJPV_boxPadding offsetIndex:colors.count];
    }
}

#pragma mark 添加文字选项

- (void)_addItems:(NSArray *)titles inView:(UIView *)view offsetY:(CGFloat)offsetY offsetIndex:(NSUInteger)offsetIndex {
    for (NSString *title in titles) {
        CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:_textFont}];
        textSize = CGSizeMake(textSize.width + 10, textSize.height + 4);
        UIButton *item  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
        item.backgroundColor            = [UIColor clearColor];
        item.titleLabel.font            = _textFont;
        item.titleLabel.textAlignment   = NSTextAlignmentCenter;
        item.titleLabel.textColor       = _textColor;
        item.layer.cornerRadius         = 4.f;
        item.layer.borderWidth          = 1.0f;
        item.layer.borderColor          = K_JJPV_borderColor.CGColor;
        [item setTitle:title forState:UIControlStateNormal];
        [item setTitleColor:_textColor forState:UIControlStateNormal];
        [item setTitleColor:_textHighlightColor forState:UIControlStateHighlighted];
        [_items addObject:item];
    }
    
    [self _setupLayoutWithViews:_items inView:view offsetY:offsetY offsetIndex:offsetIndex];
}

- (CGFloat)_setupLayoutWithColorViews:(NSArray *)views inView:(UIView *)inView {
    
    UIView *container   = self;
    
    float boxPadding    = k_JJPV_boxPadding;
    float totalHeight   = boxPadding;
    float width         = k_JJPV_circleWidth;
    float left          = 0;
    float top           = 0;
    int   columnCount   = 0;
    int   i = 0;
    
    // 计算一行能显示多少个
    columnCount = (CGRectGetWidth(inView.frame) - 2 * k_JJPV_horizontalMargin - boxPadding) / (width + boxPadding);
    
    // 定位每一个 item 的位置
    // 计算出 container 宽，高
    for (UIView *view in views) {
        
        left = i % columnCount * (boxPadding + width);
        top  = i / columnCount * (boxPadding + width);
        
        view.frame = CGRectMake(left, top, width, width);
        
        [container addSubview:view];
        
        if (i == views.count - 1) {
            totalHeight = CGRectGetMaxY(view.frame);
        }
        
        i++;
    }
    
    return totalHeight;
}

- (void)_setupLayoutWithViews:(NSArray *)views inView:(UIView *)view offsetY:(CGFloat)offsetY offsetIndex:(NSUInteger)offsetIndex {
    
    UIView *container   = self;
    
    float boxPadding    = k_JJPV_boxPadding;
    float totalHeight   = boxPadding;
    float totalWidth    = boxPadding;
    float width         = 0;
    float left          = 0;
    float top           = 0;
    int   columnCount   = 0;
    int   i = 0;
    
    NSArray *tmpViews = [views subarrayWithRange:NSMakeRange(offsetIndex, views.count - offsetIndex)];
    
    // 取出最宽的
    for (UIView *view in tmpViews) {
        width = MAX(width, CGRectGetWidth(view.frame));
    }
    
    // 计算一行能显示多少个
    columnCount = (CGRectGetWidth(view.frame) - 2 * k_JJPV_horizontalMargin - boxPadding) / (width + boxPadding);
    
    // 定位每一个 item 的位置
    // 计算出 container 宽，高
    for (UIView *view in tmpViews) {
        
        left = i % columnCount * (boxPadding + width);
        top  = i / columnCount * (boxPadding + CGRectGetHeight(view.frame)) + offsetY;
        
        view.frame = CGRectMake(left, top, width, CGRectGetHeight(view.frame));
        
        [container addSubview:view];
        
        if (i == tmpViews.count - 1) {
            totalHeight = CGRectGetMaxY(view.frame);
        }
        
        if (i == columnCount - 1 || (tmpViews.count <= columnCount && i == tmpViews.count - 1)) {
            totalWidth  = CGRectGetMaxX(view.frame);
        }
        
        i++;
    }
    
    // 更新删除按钮位置
    if (offsetIndex > 0) {
        UIView *deleteView = views[MIN(MAX(0, offsetIndex - 1), views.count - 1)];
        CGRect viewFrame = deleteView.frame;
        viewFrame.origin.x = totalWidth - CGRectGetWidth(viewFrame);
        deleteView.frame = viewFrame;
    }
    
    container.frame = CGRectMake(0, 0, totalWidth, totalHeight);
}

- (NSArray *)items {
    return _items;
}

@end
