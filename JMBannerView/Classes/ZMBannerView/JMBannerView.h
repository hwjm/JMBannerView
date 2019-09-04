//
//  ZMBannerView.h
//  quanyou
//
//  Created by Dream on 2019/7/29.
//  Copyright © 2019 zimo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JMBannerView;
@protocol ZMBannerViewDelegate <NSObject>
@optional

- (void)bannerView:(JMBannerView *)bannerView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index;

@end

@protocol ZMBannerViewDataSource <NSObject>

- (NSInteger)numberOfItemsInBannerView:(JMBannerView *)bannerView;

- (__kindof UICollectionViewCell *)bannerView:(JMBannerView *)bannerView cellForItemAtIndex:(NSInteger)index;


@end

@interface JMBannerView : UIView

@property (nonatomic) CGSize mainItemSize;
@property (nonatomic, assign) CGFloat subItemScale;
@property (nonatomic, assign) CGFloat itemSpace;

@property (nonatomic, assign) BOOL allowSelect;

@property (nonatomic, weak) id<ZMBannerViewDelegate> delegate;
@property (nonatomic, weak) id<ZMBannerViewDataSource> dataSource;

- (void)reloadData;

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

- (void)autoScrollWithInterval:(CGFloat)interval;

@end

NS_ASSUME_NONNULL_END
