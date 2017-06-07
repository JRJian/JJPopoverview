//
//  JJMessageContentView.m
//  JJPopoverView
//
//  Created by chenjiantao on 16/4/12.
//  Copyright © 2016年 chenjiantao. All rights reserved.
//

#import "JJMessageContentView.h"
#import "JJPopoverViewConfiguration.h"

@implementation JJMessageContentView{
    NSArray *_items;
}

- (instancetype)initWithMessage:(NSString *)message inView:(UIView *)view {
    self = [super init];
    if (self) {
        [self _defaultInit];
        [self _addMessageView:message inView:view];
    }
    return self;
}

- (void)_defaultInit {
    _textFont = [UIFont systemFontOfSize:16.0f];
    _textColor = K_JJPV_textColor;
}

- (void)_addMessageView:(NSString *)message inView:(UIView *)view {
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    
    NSDictionary *attributes = @{NSFontAttributeName: _textFont};
    CGFloat maxWidth = CGRectGetWidth(view.frame) - (k_JJPV_horizontalMargin + k_JJPV_boxPadding) * 2;
    CGSize textSize = [message boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil].size;
    UILabel *item  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    item.backgroundColor    = [UIColor clearColor];
    item.font               = _textFont;
    item.textAlignment      = NSTextAlignmentCenter;
    item.textColor          = _textColor;
    item.text               = message;
    item.numberOfLines      = 0;
    item.lineBreakMode      = NSLineBreakByWordWrapping;
    [items addObject:item];
    
    [self _setupLayoutWithViews:items inView:view];
}

- (void)_setupLayoutWithViews:(NSArray *)views inView:(UIView *)view {
    
    UIView *container   = self;
    
    float boxPadding    = k_JJPV_boxPadding;
    float totalHeight   = boxPadding;
    float totalWidth    = boxPadding;
    float width         = 0;
    
    // 取出最宽的
    for (UIView *view in views) {
        width = MAX(width, CGRectGetWidth(view.frame));
    }
    
    // 定位每一个 item 的位置
    // 计算出 container 宽，高
    for (UIView *view in views) {
        view.frame = CGRectMake(0, 0, width, CGRectGetHeight(view.frame));
        [container addSubview:view];
        totalHeight = CGRectGetMaxY(view.frame);
        totalWidth  = CGRectGetMaxX(view.frame);
    }
    
    container.frame = CGRectMake(0, 0, totalWidth, totalHeight);
    
    _items = views;
}

- (NSArray *)items {
    return _items;
}

@end
