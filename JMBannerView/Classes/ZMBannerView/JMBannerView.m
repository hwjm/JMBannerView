//
//  ZMBannerView.m
//  quanyou
//
//  Created by Dream on 2019/7/29.
//  Copyright © 2019 zimo. All rights reserved.
//

#import "JMBannerView.h"
#import "JMBannerLineLayout.h"

@interface JMBannerView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JMBannerLineLayout *lineLayout;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger itemsCount;
@property (nonatomic, assign) NSInteger dequeueSection;

@property (nonatomic, assign) CGFloat autoScrollInterval;

@end

#define kBannerViewSectionCount 200

@implementation JMBannerView

#pragma mark - public

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:Class forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:self.dequeueSection]];
    return cell;
}

- (void)autoScrollWithInterval:(CGFloat)interval {
    self.autoScrollInterval = interval;
    [self addTimer];
}


#pragma mark - init
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (void)defaultSetting {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _collectionView.frame = self.bounds;
    _collectionView.collectionViewLayout = self.lineLayout;
    
    if (self.itemsCount>0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kBannerViewSectionCount/2] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self removeTimer];
    }
}

#pragma mark - timer
- (void)addTimer {
    if (_timer || _autoScrollInterval <=0) return;
    _timer = [NSTimer timerWithTimeInterval:_autoScrollInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (!_timer) return;
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFired:(NSTimer *)timer {
    [self scrollToNext];
}

- (void)scrollToNext {
    if (self.itemsCount == 0) return;
    NSIndexPath *curr = [NSIndexPath indexPathForRow:[self currentIndexPath].row inSection:kBannerViewSectionCount/2];
    [self.collectionView scrollToItemAtIndexPath:curr atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    BOOL isNextSection = curr.row+1 >= self.itemsCount;
    NSInteger row = isNextSection ? 0 : curr.row+1;
    NSInteger section = isNextSection ? curr.section+1 : curr.section;
    NSIndexPath *next = [NSIndexPath indexPathForRow:row inSection:section];
    [self.collectionView scrollToItemAtIndexPath:next atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (NSIndexPath *)currentIndexPath {
    if (self.itemsCount == 0) return nil;
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        CGPoint p = [self convertPoint:self.center toView:cell];
        if (CGRectContainsPoint(cell.bounds, p)) {
            return [self.collectionView indexPathForCell:cell];
        }
    }
    return nil;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:didSelectedItemCell:atIndex:)]) {
        [self.delegate bannerView:self didSelectedItemCell:[collectionView cellForItemAtIndexPath:indexPath] atIndex:indexPath.row];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kBannerViewSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.itemsCount = [self.dataSource numberOfItemsInBannerView:self];
    return self.itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.dequeueSection = indexPath.section;
    return [self.dataSource bannerView:self cellForItemAtIndex:indexPath.row];
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.lineLayout];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor  = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator   = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate      = self;
        _collectionView.dataSource    = self;
        _collectionView.pagingEnabled = NO;
        _collectionView.pagingEnabled = NO;
        _collectionView.allowsSelection = self.allowSelect;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)lineLayout {
    if (!_lineLayout) {
        _lineLayout = [[JMBannerLineLayout alloc] init];
    }
    _lineLayout.centerItemSize = self.mainItemSize;
    _lineLayout.subItemScale   = self.subItemScale;
    _lineLayout.itemSpace      = self.itemSpace;
    return _lineLayout;
}

- (CGFloat)subItemScale {
    NSAssert(_subItemScale >= 0, @"error: subItemScale取值范围为(0, 1]");
    if (_subItemScale == 0 || _subItemScale > 1) {
        _subItemScale = 1;
    }
    return _subItemScale;
}













@end
