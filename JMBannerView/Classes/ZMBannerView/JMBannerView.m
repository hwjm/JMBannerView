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

@end

#define kBannerViewSectionCount 200

@implementation JMBannerView

#pragma mark - public

- (void)reloadData {
    [_collectionView reloadData];
    NSIndexPath *centerIndexPath = [NSIndexPath indexPathForRow:0 inSection:kBannerViewSectionCount/2];
    [self resetBannerViewAtIndexpath:centerIndexPath];
}

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerClass:Class forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:_dequeueSection]];
    return cell;
}

- (void)updateLayout {
    NSIndexPath *centerIndexPath = [NSIndexPath indexPathForRow:[self centerIndexPath].row inSection:kBannerViewSectionCount/2];
    [_collectionView.collectionViewLayout invalidateLayout];
    _collectionView.collectionViewLayout = self.lineLayout;
    [self resetBannerViewAtIndexpath:centerIndexPath];
}

- (void)stopAutoScroll {
    [self removeTimer];
}

- (void)startAutoScroll {
    [self removeTimer];
    _autoScrollInterval > 0 ? [self addTimer] : nil;
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
    _allowSelection = YES;
    _dragEnable     = YES;
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _collectionView.frame = self.bounds;
    [_collectionView.collectionViewLayout invalidateLayout];
    _collectionView.collectionViewLayout = self.lineLayout;
    if (_itemsCount > 0) {
        NSIndexPath *centerIndexPath = [NSIndexPath indexPathForRow:[self centerIndexPath].row inSection:kBannerViewSectionCount/2];
        [self resetBannerViewAtIndexpath:centerIndexPath];        
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
    if (_itemsCount == 0) return;
    
    NSIndexPath *next;
    JMBannerViewScrollDirection d = _direction;
    if (d == JMBannerViewScrollDirectionRight) {
        next = [self rightIndexPath];
    } else {
        next = [self leftIndexPath];
    }
    [self.collectionView scrollToItemAtIndexPath:next atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - calculate
- (NSIndexPath *)centerIndexPath {
    return [_collectionView indexPathForItemAtPoint:CGPointMake(_collectionView.center.x+_collectionView.contentOffset.x, _collectionView.center.y)];
}

- (NSIndexPath *)leftIndexPath {
    NSIndexPath *centerIndex = [self centerIndexPath];
    BOOL isNextSection = centerIndex.row==0;
    NSInteger section, row;
    if (isNextSection) {
        section = centerIndex.section-1;
        row     = _itemsCount-1;
    } else {
        section = centerIndex.section;
        row     = centerIndex.row-1;
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSIndexPath *)rightIndexPath {
    NSIndexPath *centerIndex = [self centerIndexPath];
    BOOL isNextSection = centerIndex.row >= _itemsCount-1;
    NSInteger section, row;
    if (isNextSection) {
        section = centerIndex.section+1;
        row     = 0;
    } else {
        section = centerIndex.section;
        row     = centerIndex.row+1;
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (void)resetBannerViewAtIndexpath:(NSIndexPath *)indexPath {
    if (_itemsCount>0) {
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];        
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self removeTimer];
    if (_delegate && [_delegate respondsToSelector:@selector(bannerView:didSelectedItemCell:atIndex:isCenterCell:)]) {
        BOOL isCenter = [[self centerIndexPath] compare:indexPath] == NSOrderedSame;
        [self.delegate bannerView:self didSelectedItemCell:[collectionView cellForItemAtIndexPath:indexPath] atIndex:indexPath.row isCenterCell:isCenter];
    }
    [_collectionView scrollToItemAtIndexPath:[self centerIndexPath] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self addTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
    if (_delegate && [_delegate respondsToSelector:@selector(bannerViewWillBeginDragging:)]) {
        [self.delegate bannerViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
    if (_delegate && [_delegate respondsToSelector:@selector(bannerViewDidEndDragging:willDecelerate:)]) {
        [self.delegate bannerViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerViewWillBeginDecelerating:)]) {
        [self.delegate bannerViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *centerIndex = [NSIndexPath indexPathForRow:[self centerIndexPath].row inSection:kBannerViewSectionCount/2];
    [self resetBannerViewAtIndexpath:centerIndex];
    if (_delegate && [_delegate respondsToSelector:@selector(bannerViewDidEndDecelerating:)]) {
        [self.delegate bannerViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSIndexPath *centerIndex = [NSIndexPath indexPathForRow:[self centerIndexPath].row inSection:kBannerViewSectionCount/2];
    [self resetBannerViewAtIndexpath:centerIndex];
    if (_delegate && [_delegate respondsToSelector:@selector(bannerViewDidEndScrollingAnimation:)]) {
        [self.delegate bannerViewDidEndScrollingAnimation:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(bannerViewDidScroll:)]) {
        [self.delegate bannerViewDidScroll:self];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kBannerViewSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _itemsCount = [_dataSource numberOfItemsInBannerView:self];
    return _itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _dequeueSection = indexPath.section;
    return [_dataSource bannerView:self cellForItemAtIndex:indexPath.row];
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor  = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator   = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate      = self;
        _collectionView.dataSource    = self;
        _collectionView.pagingEnabled = NO;
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

- (CGSize)mainItemSize {
    if (CGSizeEqualToSize(CGSizeZero, _mainItemSize)) {
        _mainItemSize = _collectionView.bounds.size;
    }
    return _mainItemSize;
}

- (CGFloat)subItemScale {
    NSAssert(_subItemScale >= 0, @"error: subItemScale取值范围为(0, 1]");
    if (_subItemScale == 0 || _subItemScale > 1) {
        _subItemScale = 1;
    }
    return _subItemScale;
}

- (void)setDirection:(JMBannerViewScrollDirection)direction {
    [self removeTimer];
    [self addTimer];
    _direction = direction;
}

- (NSInteger)centerIndex {
    return [self centerIndexPath].row;
}

- (void)setAllowSelect:(BOOL)allowSelection {
    _collectionView.allowsSelection = allowSelection;
}

- (void)setDragEnable:(BOOL)dragEnable {
    _dragEnable = dragEnable;
    _collectionView.scrollEnabled = dragEnable;
}

@end
