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
    
    self.minimumLineSpacing = self.itemSpace - (self.centerItemSize.width*(1-self.subItemScale))/2;
    self.centerSpace = self.centerItemSize.width+self.minimumLineSpacing;
    self.sectionInset = UIEdgeInsetsMake(0, self.minimumLineSpacing/2, 0, self.minimumLineSpacing/2);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    NSArray *arr = [[NSArray alloc] initWithArray:original copyItems:YES];
    CGFloat centerX = self.collectionView.contentOffset.x+self.collectionView.frame.size.width/2;
    for (UICollectionViewLayoutAttributes *attr in arr) {
        CGFloat scale = self.subItemScale;
        CGFloat delta = MIN(self.centerSpace, ABS(attr.center.x-centerX));
        scale = (1-delta/self.centerSpace)*(1-scale) + scale;
        attr.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return arr;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGRect rect;
    rect.origin.x = proposedContentOffset.x;
    rect.origin.y = 0;
    rect.size = self.collectionView.frame.size;
    
    CGFloat centerX = proposedContentOffset.x+self.collectionView.frame.size.width/2;
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attr in [super layoutAttributesForElementsInRect:rect]) {
        if (ABS(minDelta)>ABS(attr.center.x-centerX)) {
            minDelta = attr.center.x-centerX;
        }
    }
    proposedContentOffset.x += minDelta;
    return proposedContentOffset;
}


- (void)setSubItemScale:(CGFloat)subItemScale {
    NSInteger scale = subItemScale*100;
    _subItemScale = scale / 100.00f;
}


@end
