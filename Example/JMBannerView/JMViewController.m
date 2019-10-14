//
//  JMViewController.m
//  JMBannerView
//
//  Created by K-Nezuko on 09/04/2019.
//  Copyright (c) 2019 K-Nezuko. All rights reserved.
//

#import "JMViewController.h"
#import "JMBannerView.h"
#import "JMCustomCell.h"

@interface JMViewController ()<JMBannerViewDelegate, JMBannerViewDataSource>

@property (weak, nonatomic) IBOutlet JMBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UISlider *itemWidthSlider;
@property (weak, nonatomic) IBOutlet UILabel *itemWidthLabel;

@property (weak, nonatomic) IBOutlet UISlider *subItemSlider;
@property (weak, nonatomic) IBOutlet UILabel *subItemScaleLabel;

@property (weak, nonatomic) IBOutlet UISlider *itemSpaceSlider;
@property (weak, nonatomic) IBOutlet UILabel *itemSpaceLabel;

@property (weak, nonatomic) IBOutlet UISlider *timeIntervalSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;

@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic, strong) NSMutableArray *originalDatas;
@property (nonatomic, strong) NSMutableArray *datas;

@end

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@implementation JMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // banner init
    self.bannerView.delegate     = self;
    self.bannerView.dataSource   = self;
    [self.bannerView registerClass:[JMCustomCell class] forCellWithReuseIdentifier:@"reuse"];
    
    // request data
    self.originalDatas = [NSMutableArray array];
    for (int i = 0; i<5; i++) {
        [self.originalDatas addObject:[self getRandomColor]];
    }
    self.datas = [NSMutableArray arrayWithArray:self.originalDatas];
    
    // default config for debug
    self.itemWidthLabel.text = [NSString stringWithFormat:@"%.2f", kScreenWidth];
    self.subItemScaleLabel.text = @"1.0";
    self.itemSpaceLabel.text = @"0";
    self.timeIntervalLabel.text = @"0";
}

#pragma mark - JMBannerViewDataSource
// item数量
- (NSInteger)numberOfItemsInBannerView:(JMBannerView *)bannerView
{
    return self.datas.count;
}

// 自定义item
- (__kindof UICollectionViewCell *)bannerView:(JMBannerView *)bannerView cellForItemAtIndex:(NSInteger)index
{
    JMCustomCell *cell = [bannerView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndex:index];
    cell.contentView.layer.borderColor = [UIColor redColor].CGColor;
    cell.contentView.layer.borderWidth = 1;
    cell.contentView.backgroundColor = self.datas[index];
    return cell;
}

#pragma mark - JMBannerViewDelegate
// 点击方法
- (void)bannerView:(JMBannerView *)bannerView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index isCenterCell:(BOOL)isCenter
{
    NSLog(@"%ld ~~ isCenter: %d", (long)index, isCenter);
}

- (void)bannerViewDidScroll:(JMBannerView *)bannerView
{
    // NSLog(@"%ld", (long)bannerView.centerIndex);
}

#pragma mark - change bannerView params
- (IBAction)sliderChange:(UISlider *)sender
{
    if (sender == self.itemWidthSlider) {
        self.bannerView.mainItemSize = CGSizeMake(kScreenWidth * sender.value, 100);
        self.itemWidthLabel.text = [NSString stringWithFormat:@"%.2f", kScreenWidth * sender.value];
    }
    if (sender == self.subItemSlider) {
        self.bannerView.subItemScale = sender.value;
        self.subItemScaleLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
    }
    if (sender == self.itemSpaceSlider) {
        self.bannerView.itemSpace = 20*sender.value;
        self.itemSpaceLabel.text = [NSString stringWithFormat:@"%.2f", 20*sender.value];
    }
    if (sender == self.timeIntervalSlider) {
        self.bannerView.autoScrollInterval = 10*sender.value;
        [self.bannerView startAutoScroll];
        self.timeIntervalLabel.text = [NSString stringWithFormat:@"%.2f", (10*sender.value)];
    }
    
    [self.bannerView updateLayout];
}

- (IBAction)directionSwitch:(UISwitch *)sender
{
    self.bannerView.direction = sender.on ? JMBannerViewScrollDirectionRight :JMBannerViewScrollDirectionLeft;
    self.directionLabel.text = sender.on ? @"right" : @"left";
}

- (IBAction)addAction:(UIButton *)sender
{
    [self.originalDatas addObject:[self getRandomColor]];
    self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.originalDatas.count];
}

- (IBAction)reducAction:(UIButton *)sender
{
    [self.originalDatas removeLastObject];
    self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.originalDatas.count];
}

- (IBAction)reloadAction:(id)sender
{
    self.datas = [NSMutableArray arrayWithArray:self.originalDatas];
    [self.bannerView reloadData];
}

- (UIColor *)getRandomColor
{
    return [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
