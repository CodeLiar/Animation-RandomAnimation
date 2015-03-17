//
//  ViewController.m
//  AnimationSample
//
//  Created by Geass on 3/16/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "ViewController.h"
#import "HMAnimationView.h"
#import "HMAnimationImageView.h"
#import "SecondViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self createImageView];
//    
//    [self getMovePath];
//    [self createAnimationView];
    
//    [self createAnimationImageView];
    
}
- (IBAction)buttonClick:(id)sender {
    
    SecondViewController *svc = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)createAnimationImageView
{
    HMAnimationView *view = [[HMAnimationView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2.0, 100, 300, 300)];
    view.backgroundColor = [UIColor grayColor];
    HMAnimationImageView *imageView = [[HMAnimationImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    view.clipsToBounds = YES;
    imageView.m_ActiveRect = CGRectMake(-50, -100, 400, 500);
    
    NSMutableArray *imageArr = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"MBProgress1"], [UIImage imageNamed:@"MBProgress2"], [UIImage imageNamed:@"MBProgress3"], [UIImage imageNamed:@"MBProgress4"], nil];
    imageView.image = [UIImage animatedImageWithImages:imageArr duration:0.5];
    [view addSubview:imageView];
    [self.view addSubview:view];
    [imageView startAnimating];
}

- (void)createAnimationView
{
    HMAnimationView *view = [[HMAnimationView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2.0, 100, 300, 300)];
    view.backgroundColor = [UIColor grayColor];
//    view.clipsToBounds = YES;
    [self.view addSubview:view];
    view.m_ActiveRect = CGRectMake(-50, -100, 400, 500);
    [view startAnimation];
}

- (void)createImageView
{
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(77, 100, 60, 60)];
    _imageView.animationDuration = 0.50f;
    _imageView.animationRepeatCount = 0;
    [self.view addSubview:_imageView];
    [_imageView startAnimating];
    _imageView.transform = CGAffineTransformMakeScale(-1 , 1);
}

- (void)getMovePath
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.x";
    animation.fromValue = @77;
    animation.toValue = @300;
    animation.duration = 1;
    animation.removedOnCompletion = YES;
    
    [_imageView.layer addAnimation:animation forKey:@"basic"];
    _imageView.layer.position = CGPointMake(300, 100);
    [self addObserver:self forKeyPath:@"imageView.layer.position" options:NSKeyValueObservingOptionNew context:nil];
    
    [self performSelector:@selector(nslogAnimation) withObject:nil afterDelay:2.0f];
}


- (void)getMovePath1
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.y";
    animation.fromValue = @100;
    animation.toValue = @300;
    animation.duration = 1;
    animation.removedOnCompletion = YES;
    
    [_imageView.layer addAnimation:animation forKey:@"basic"];
    _imageView.layer.position = CGPointMake(300, 300);
    [self addObserver:self forKeyPath:@"imageView.layer.position" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self performSelector:@selector(nslogAnimation) withObject:nil afterDelay:2.0f];
}

- (void)nslogAnimation
{
    
    NSLog(@"%@", _imageView.layer.animationKeys);
    
    [_imageView.layer removeAnimationForKey:@"basic"];
    
    NSLog(@"%@", _imageView.layer.animationKeys);
    
    [self getMovePath1];
    
    NSLog(@"%@", _imageView.layer.animationKeys);
}

- (void)addToShoppingCart
{
    //加入购物车动画效果
//    UIImage *image = [PEUtil imageWithFile:@"list.png"];
    UIImage *image = nil;
    CALayer *transitionLayer = [[CALayer alloc] init];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    transitionLayer.opacity = 1.0;
    transitionLayer.contents = (id)image.CGImage;
    transitionLayer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
    transitionLayer.frame = CGRectMake(850, 700, 44, 44);
    [self.view.layer addSublayer:transitionLayer];
    [CATransaction commit];
    
    //路径曲线
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:transitionLayer.position];
    
    
    CGPoint toPoint = CGPointZero;
    
    toPoint =  CGPointMake(1024-22, 22);
    [movePath addQuadCurveToPoint:toPoint
                     controlPoint:CGPointMake(transitionLayer.position.x - 120, 5)];
    
    //关键帧
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = YES;
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[@(1.0), @(0.6), @(0.4), @(0.2)];
    scaleAnimation.keyTimes = @[@0.25f, @0.5f, @0.75f, @1.0f];
    scaleAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime();
    group.duration = 0.7;
    group.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, nil];
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    //group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses= NO;
    
    [transitionLayer addAnimation:group forKey:@"opacity"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@", change);
}

@end
