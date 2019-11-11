//
//  ZMBannerLineLayout.m
//  quanyou
//
//  Created by Dream on 2019/7/30.
//  Copyright © 2019 zimo. All rights reserved.
//

#import "JMBannerLineLayout.h"

@interface JMBannerLineLayout()

@property (nonatomic, assign) CGFloat centerSpace;

@end

@implementation JMBannerLineLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = self.centerItemSize.width==0||self.centerItemSize.height==0 ? self.collectionView.bounds.size : self.centerItemSize;
    self.itemSize = CGSizeMake(MIN(self.collectionView.bounds.size.width, self.itemSize.width), MIN(self.collectionView.bounds.size.height, self.itemSize.height));
    
    // 真实的item space
    self.minimumLineSpacing = self.itemSpace - (self.centerItemSize.width*(1-self.subItemScale))/2;
    self.centerSpace = self.centerItemSize.width+self.minimumLineSpacing;
    self.sectionInset = UIEdgeInsetsMake(0, self.minimumLineSpacing/2, 0, self.minimumLineSpacing/2);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    // _subItemScale 取值区间 (0, 1], 当为1时不做处理
    if (_subItemScale >=1 || _subItemScale < 0) return original;
    
    NSArray *arr = [[NSArray alloc] initWithArray:original copyItems:YES];
    // 找出中心点
    CGFloat centerX = self.collectionView.contentOffset.x+self.collectionView.center.x;
    for (UICollectionViewLayoutAttributes *attr in arr) {
        CGFloat scale = _subItemScale;
        // 计算item的缩放比例, 范围[_subItemScale, 1];
        CGFloat delta = MIN(_centerSpace, ABS(attr.center.x-centerX));
        scale = (1-delta/_centerSpace)*(1-scale) + scale;
        attr.transform = CGAffineTransformMakeScale(scale, scale);
        // 中心的item在最上层
        attr.zIndex = -ABS(attr.center.x-centerX);
    }
    return arr;
}

// 分页效果
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGRect rect;
    rect.origin.x = proposedContentOffset.x;
    rect.origin.y = 0;
    rect.size = self.collectionView.frame.size;
    
    CGFloat centerX = proposedContentOffset.x+self.collectionView.center.x;
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attr in [super layoutAttributesForElementsInRect:rect]) {
        if (ABS(minDelta)>ABS(attr.center.x-centerX)) {
            minDelta = attr.center.x-centerX;
        }
    }

    proposedContentOffset.x += minDelta;
    if (ABS(velocity.x)<1 && ABS(velocity.x)>0.2) {
        int symbol = velocity.x/ABS(velocity.x);
        proposedContentOffset.x += (self.itemSize.width+self.minimumLineSpacing)*symbol;
    }
    return proposedContentOffset;
}

- (void)setSubItemScale:(CGFloat)subItemScale {
    NSInteger scale = subItemScale*100;
    _subItemScale = scale / 100.00f;
}


@end
