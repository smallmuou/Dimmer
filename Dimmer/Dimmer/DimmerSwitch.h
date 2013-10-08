
/*!
 * Copyright (c) 2013,福建星网视易信息系统有限公司
 * All rights reserved.
 
 * @File:       DimmerSwitch.h
 * @Abstract:   调光开关
                通过UIControlEventTouchUpInside来监听事件
 * @History:
 
 -2013-09-12 创建 by xuwf
 */

#import <UIKit/UIKit.h>

@interface DimmerSwitch : UIControl {
    BOOL _on;
    CGFloat _progress;  /* 0 ~ 1*/
}
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) CGFloat progress;

@end
