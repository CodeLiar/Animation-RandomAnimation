//
//  HMAnimationView.m
//  AnimationSample
//
//  Created by Geass on 3/16/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "HMAnimationView.h"
#import <math.h>

static NSString * const HMAnimationKeyDefault = @"HMAnimationKeyDefault";

#define Animation_Image_Duration        0.5         // 帧动画时间


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

@interface HMAnimationView ()

// 动画类别
@property (nonatomic, assign) AnimationType m_AnimationType;
// 路径动画时间
@property (nonatomic, assign) CGFloat m_PathAnimationDuration;

// toPoint
@property (nonatomic, assign) CGPoint m_ToPoint;

@end

@implementation HMAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.m_ActiveRect = self.bounds;
        [self setUpView];
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeAllAnimations];
}

- (void)setUpView
{
    [self createImageView];
}

- (void)createImageView
{
    NSMutableArray *imageArr = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"MBProgress1"], [UIImage imageNamed:@"MBProgress2"], [UIImage imageNamed:@"MBProgress3"], [UIImage imageNamed:@"MBProgress4"], nil];
    _m_ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _m_ImageView.animationImages = imageArr;
    _m_ImageView.animationDuration = Animation_Image_Duration;
    _m_ImageView.animationRepeatCount = 0;
    [self addSubview:_m_ImageView];
}

// 添加路径动画
- (void)addAnimationWithKey:(NSString *)key
{
    // 如果key动画存在，移除key
    if ([_m_ImageView.layer animationForKey:key])
    {
        [_m_ImageView.layer removeAnimationForKey:key];
    }
    
    self.m_AnimationType = arc4random() % Animation_Type_Count;
//    self.m_AnimationType = 1;
    CAAnimation *animation = [self getAnimationWithRandom:self.m_AnimationType];
    animation.duration = self.m_PathAnimationDuration;
    animation.removedOnCompletion = YES;
    [_m_ImageView.layer addAnimation:animation forKey:key];
    [_m_ImageView.layer setPosition:self.m_ToPoint];
    [self performSelector:@selector(addAnimationWithKey:) withObject:HMAnimationKeyDefault afterDelay:self.m_PathAnimationDuration];
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
- (void)startAnimation
{
    [_m_ImageView startAnimating];
    [self addAnimationWithKey:HMAnimationKeyDefault];
}

// 停止动画
- (void)stopAnimation
{
    [_m_ImageView stopAnimating];
}

// 移除所有动画
- (void)removeAllAnimations
{
    [_m_ImageView.layer removeAllAnimations];
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
    if (randomX > _m_ImageView.layer.position.x)
    {
        _m_ImageView.transform = CGAffineTransformMakeScale(1, 1);
    }
    else if (randomX < _m_ImageView.layer.position.x)
    {
        _m_ImageView.transform = CGAffineTransformMakeScale(-1, 1);
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
            animation.fromValue = @(_m_ImageView.layer.position.x);
            animation.toValue = @([self getRandomX]);
            self.m_ToPoint = CGPointMake([animation.toValue floatValue], _m_ImageView.layer.position.y);
        }
            break;
        case 1:
        {
            animation.keyPath = keyPathArr[1];
            animation.fromValue = @(_m_ImageView.layer.position.y);
            animation.toValue = @([self getRandomY]);
            self.m_ToPoint = CGPointMake(_m_ImageView.layer.position.x, [animation.toValue floatValue]);
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
    [movePath moveToPoint:_m_ImageView.layer.position];
    [self setBezierPath:movePath];
    return movePath.CGPath;
}

// 获取中转点
- (CGPoint)getControlPoint:(CGPoint)toPoint
{
    CGPoint controlPoint = CGPointZero;
    CGFloat x = _m_ImageView.layer.position.x;
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
            CGFloat width = fabs(toPoint.x - _m_ImageView.layer.position.x);
            CGFloat height = fabs(toPoint.y - _m_ImageView.layer.position.y);
            self.m_ToPoint = toPoint;
            self.m_PathAnimationDuration = [self getPathDurationWithLength:width > height ? width : height];
        }
            break;
        case kBezierTypeSin:
        {
            CGPoint toPoint = CGPointZero;
            toPoint = CGPointMake([self getRandomX], _m_ImageView.layer.position.y);
            if (toPoint.x < 200.0f)
            {
                toPoint.x = 200.0f;
            }
            // 系数
            NSInteger ratio = arc4random() % 4 + 1;
            // 倍数
            NSInteger multiple = (arc4random() % 4 + 1) * 50;
            
            CGFloat x = (CGFloat)_m_ImageView.layer.position.x;
            CGFloat y = 0;
            if (x > toPoint.x)
            {
                for(; x > toPoint.x; x--){
                    y = sin(ratio * x / 180.0 * M_PI) * multiple + _m_ImageView.layer.position.y;
                    [path addLineToPoint:CGPointMake(x, y)];
                }
            }
            else if (x < toPoint.x)
            {
                for(; x < toPoint.x; x++){
                    y = sin(ratio * x / 180.0 * M_PI) * multiple + _m_ImageView.layer.position.y;
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
