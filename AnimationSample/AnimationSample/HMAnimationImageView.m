//
//  HMAnimationImageView.m
//  AnimationSample
//
//  Created by Geass on 3/16/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "HMAnimationImageView.h"
#import <math.h>

static NSString * const HMAnimationKeyDefault = @"HMAnimationKeyDefault";

#define Animation_Type_Count            2           // 枚举个数
typedef NS_ENUM(NSUInteger, AnimationType) {
    kAnimationTypeBasic,
    kAnimationTypeKey
};

#define Bezier_Type_count               2
typedef NS_ENUM(NSUInteger, BezierType) {
    kBezierTypeBasic,                               // 一般的曲线
    kBezierTypeSin                                  // 正玄曲线
};

@interface HMAnimationImageView ()

// 动画类别
@property (nonatomic, assign) AnimationType m_AnimationType;
// 路径动画时间
@property (nonatomic, assign) CGFloat m_PathAnimationDuration;
// toPoint 要到达的地点
@property (nonatomic, assign) CGPoint m_ToPoint;

@end

@implementation HMAnimationImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.animationRepeatCount = 0;
        self.m_ActiveRect = CGRectZero;
    }
    return self;
}

- (void)dealloc
{
    [self removeAllAnimations];
}


// 添加路径动画
- (void)addAnimationWithKey:(NSString *)key
{
    NSLog(@"----%s", __FUNCTION__);
    // 如果key动画存在，移除key
    if ([self.layer animationForKey:key])
    {
        [self.layer removeAnimationForKey:key];
    }
    
    self.m_AnimationType = arc4random() % Animation_Type_Count;
    
    CAAnimation *animation = [self getAnimationWithRandom:self.m_AnimationType];
    animation.duration = self.m_PathAnimationDuration;
    animation.removedOnCompletion = YES;
    [self.layer addAnimation:animation forKey:key];
    [self.layer setPosition:self.m_ToPoint];
//    [self performSelector:@selector(addAnimationWithKey:) withObject:HMAnimationKeyDefault afterDelay:self.m_PathAnimationDuration];
    
    __weak HMAnimationImageView *wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.m_PathAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wself addAnimationWithKey:HMAnimationKeyDefault];
    });
}

// 获取随机动画
- (CAAnimation *)getAnimationWithRandom:(AnimationType)random
{
    CAAnimation *animation = nil;
    switch (random) {
        case kAnimationTypeBasic:
        {
            CABasicAnimation *animation = [self initializeBasicAnimation];
            self.m_PathAnimationDuration = [self getPathDurationWithLength:fabs([animation.toValue floatValue] - [animation.fromValue floatValue])];
            return animation;
        }
            break;
        case kAnimationTypeKey:
        {
            CAKeyframeAnimation *animation = [self initializeKeyAnimation];
            return animation;
        }
            break;
        default:
            break;
    }
    return animation;
}

// 开始动画
- (void)startAnimating
{
    if (self.m_ActiveRect.size.width == 0 || self.m_ActiveRect.size.height == 0)
    {
        if (self.superview)
        {
            self.m_ActiveRect = self.superview.bounds;
        }
        else
        {
            return;
        }
    }
    
    [super startAnimating];
    [self addAnimationWithKey:HMAnimationKeyDefault];
}

// 停止动画（必须调用，否则会产生内存泄露）
- (void)stopAnimating
{
    [super stopAnimating];
}

// 移除所有动画
- (void)removeAllAnimations
{
    [self.layer removeAllAnimations];
}

// 随机获取x, y
- (CGFloat)getRandoxInRange:(NSRange)range
{
    if (range.length < 1)
    {
        return range.location;
    }
    else
    {
        return arc4random() % range.length + range.location;
    }
    
}

- (CGFloat)getRandomX
{
    CGFloat x_min = self.m_ActiveRect.origin.x;
    CGFloat x_length = self.m_ActiveRect.size.width;
    CGFloat randomX = arc4random() % (NSInteger)x_length + x_min;
    // 转换方向
    [self transformAnimationHead:randomX];
    return randomX;
}

- (CGFloat)getRandomY
{
    CGFloat y_min = self.m_ActiveRect.origin.y;
    CGFloat y_length = self.m_ActiveRect.size.height;
    CGFloat randomY = arc4random() % (NSInteger)y_length + y_min;
    return randomY;
}

- (void)transformAnimationHead:(CGFloat)randomX
{
    if (randomX > self.layer.position.x)
    {
        self.transform = CGAffineTransformMakeScale(1, 1);
    }
    else if (randomX < self.layer.position.x)
    {
        self.transform = CGAffineTransformMakeScale(-1, 1);
    }
}

#pragma mark - Basic Animation
// 随机获取Basic Animation KeyPath
// 只添加x y
- (CABasicAnimation *)initializeBasicAnimation
{
    NSArray *keyPathArr = @[@"position.x", @"position.y"];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    switch (arc4random() % keyPathArr.count) {
        case 0:
        {
            animation.keyPath = keyPathArr[0];
            animation.fromValue = @(self.layer.position.x);
            animation.toValue = @([self getRandomX]);
            self.m_ToPoint = CGPointMake([animation.toValue floatValue], self.layer.position.y);
        }
            break;
        case 1:
        {
            animation.keyPath = keyPathArr[1];
            animation.fromValue = @(self.layer.position.y);
            animation.toValue = @([self getRandomY]);
            self.m_ToPoint = CGPointMake(self.layer.position.x, [animation.toValue floatValue]);
        }
            break;
            
        default:
            break;
    }
    return animation;
}

#pragma mark - Key Animation
// bezier 曲线
- (CGPathRef)getBezierLine
{
    //路径曲线
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:self.layer.position];
    [self setBezierPath:movePath];
    return movePath.CGPath;
}

// 获取中转点
- (CGPoint)getControlPoint:(CGPoint)toPoint
{
    CGPoint controlPoint = CGPointZero;
    CGFloat x = self.layer.position.x;
    controlPoint.x = [self getRandoxInRange:NSMakeRange(x, fabs(toPoint.x - x))];
    controlPoint.y = [self getRandomY];
    return controlPoint;
}

// 设置曲线
- (void)setBezierPath:(UIBezierPath *)path
{
    BezierType type = arc4random() % Bezier_Type_count;
    type = 0;
    switch (type) {
        case kBezierTypeBasic:
        {
            CGPoint toPoint = CGPointMake([self getRandomX], [self getRandomY]);
            [path addQuadCurveToPoint:toPoint
                         controlPoint:[self getControlPoint:toPoint]];
            CGFloat width = fabs(toPoint.x - self.layer.position.x);
            CGFloat height = fabs(toPoint.y - self.layer.position.y);
            self.m_ToPoint = toPoint;
            self.m_PathAnimationDuration = [self getPathDurationWithLength:width > height ? width : height];
        }
            break;
        case kBezierTypeSin:
        {
            CGPoint toPoint = CGPointZero;
            toPoint = CGPointMake([self getRandomX], self.layer.position.y);
            if (toPoint.x < 200.0f)
            {
                toPoint.x = 200.0f;
            }
            // 系数
            NSInteger ratio = arc4random() % 4 + 1;
            // 倍数
            NSInteger multiple = (arc4random() % 4 + 1) * 50;
            
            CGFloat x = (CGFloat)self.layer.position.x;
            CGFloat y = 0;
            if (x > toPoint.x)
            {
                for(; x > toPoint.x; x--){
                    y = sin(ratio * x / 180.0 * M_PI) * multiple + self.layer.position.y;
                    [path addLineToPoint:CGPointMake(x, y)];
                }
            }
            else if (x < toPoint.x)
            {
                for(; x < toPoint.x; x++){
                    y = sin(ratio * x / 180.0 * M_PI) * multiple + self.layer.position.y;
                    [path addLineToPoint:CGPointMake(x, y)];
                }
            }
            
            
            self.m_ToPoint = toPoint;
            self.m_PathAnimationDuration = [self getPathDurationRation:ratio multiple:multiple / 100];
        }
            break;
        default:
            break;
    }
}

// 获取关键帧动画
- (CAKeyframeAnimation *)initializeKeyAnimation
{
    //关键帧
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = [self getBezierLine];
    return animation;
}
#pragma mark - 路径动画Duration
// 基本路径获取时间
- (CGFloat)getPathDurationWithLength:(CGFloat)length
{
    // 每200 给1~2秒
    CGFloat duration = arc4random() % 2 + 1;
    if (length > 200)
    {
        duration = (length / 200.0f) * duration;
    }
    return duration;
}

// 贝塞尔曲线路径时间
- (CGFloat)getPathDurationRation:(NSInteger)ratio multiple:(NSInteger)mutiple
{
    // 每200 给1~2秒
    CGFloat duration = arc4random() % 2 + 1;
    
    duration = duration + duration * ((float)(ratio + mutiple)) / 4.0;
    
    return duration;
}


@end
