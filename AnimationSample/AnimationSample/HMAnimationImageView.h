//
//  HMAnimationImageView.h
//  AnimationSample
//
//  Created by Geass on 3/16/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//


/* 动画页面停止使用时，必须调用
    - (void)stopAnimating 
 方法，否则会造成内存泄露
 */
#import <UIKit/UIKit.h>

@interface HMAnimationImageView : UIImageView

// 动画活动区域（必须制定）
@property (nonatomic, assign) CGRect m_ActiveRect;

@end
