//
//  SecondViewController.m
//  AnimationSample
//
//  Created by Geass on 3/16/15.
//  Copyright (c) 2015 Geass. All rights reserved.
//

#import "SecondViewController.h"
#import "HMAnimationImageView.h"



@interface SecondViewController () <UITableViewDelegate, UITableViewDataSource>
{
    HMAnimationImageView *imageView;
    NSArray *dataArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = @[@"1", @"2", @"3", @"4", @"5"];
    [self createAnimationImageView];
    [self createTableView];
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 200)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = dataArray[indexPath.row];
    return cell;
}

- (void)dealloc
{
    [imageView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)createAnimationImageView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2.0, 100, 300, 300)];
    view.backgroundColor = [UIColor grayColor];
    view.clipsToBounds = YES;
    
    imageView = [[HMAnimationImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    imageView.m_ActiveRect = CGRectMake(-50, -100, 400, 500);
    
    NSMutableArray *imageArr = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"MBProgress1"], [UIImage imageNamed:@"MBProgress2"], [UIImage imageNamed:@"MBProgress3"], [UIImage imageNamed:@"MBProgress4"], nil];
//    imageView.image = [UIImage animatedImageWithImages:imageArr duration:0.5];
    imageView.animationImages = imageArr;
    imageView.animationDuration = 0.5f;
    [imageView startAnimating];
    
    [view addSubview:imageView];
    
    [self.view addSubview:view];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
