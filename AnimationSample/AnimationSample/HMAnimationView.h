//
//  HMAnimationView.h
//  AnimationSample
//
//  Created by Geass on 3/16/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface HMAnimationView : UIView

@property (nonatomic, strong) UIImageView *m_ImageView;

@property (nonatomic, assign) CGRect m_ActiveRect;

- (void)startAnimation;
- (void)stopAnimation;
- (void)removeAllAnimations;

@end
