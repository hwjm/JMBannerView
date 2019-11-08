//
//  ZMBannerView.h
//  quanyou
//
//  Created by Dream on 2019/7/29.
//  Copyright © 2019 zimo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 滚动方向
typedef NS_ENUM(NSUInteger, JMBannerViewScrollDirection) {
    JMBannerViewScrollDirectionRight,
    JMBannerViewScrollDirectionLeft,
};


@class JMBannerView;
@protocol JMBannerViewDelegate <NSObject>
@optional
// 点击方法
- (void)bannerView:(JMBannerView *)bannerView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index isCenterCell:(BOOL)isCenter;

// scrollViewDelegate
- (void)bannerViewDidScroll:(JMBannerView *)bannerView;

- (void)bannerViewWillBeginDragging:(JMBannerView *)bannerView;

- (void)bannerViewDidEndDragging:(JMBannerView *)bannerView willDecelerate:(BOOL)decelerate;

- (void)bannerViewWillBeginDecelerating:(JMBannerView *)bannerView;

- (void)bannerViewDidEndDecelerating:(JMBannerView *)bannerView;

- (void)bannerViewDidEndScrollingAnimation:(JMBannerView *)bannerView;

@end

@protocol JMBannerViewDataSource <NSObject>

// item数量
- (NSInteger)numberOfItemsInBannerView:(JMBannerView *)bannerView;

// 自定义item
- (__kindof UICollectionViewCell *)bannerView:(JMBannerView *)bannerView cellForItemAtIndex:(NSInteger)index;


@end

@interface JMBannerView : UIView

@property (nonatomic) CGSize mainItemSize;          // 中心的item size. 默认为bannerView.bounds.size
@property (nonatomic, assign) CGFloat subItemScale; // 次级item缩放比例. 取值范围(0, 1], 默认为1
@property (nonatomic, assign) CGFloat itemSpace;    // item间距, 中心item与相邻的item之间间距, 尚未完善, 日后调整
@property (nonatomic, assign) CGFloat autoScrollInterval; // 自动滚动时间, 默认0;

@property (nonatomic, assign) BOOL allowSelection;  // 是否允许选中, 默认为Yes
@property (nonatomic, assign) BOOL dragEnable;      // 是否可以拖拽, 默认为Yes

@property (nonatomic, assign) JMBannerViewScrollDirection direction; // 滚动方向, 默认向右

@property (nonatomic, weak) id<JMBannerViewDelegate>   delegate;
@property (nonatomic, weak) id<JMBannerViewDataSource> dataSource;

@property (nonatomic, assign, readonly) NSInteger centerIndex;


- (void)reloadData; // 刷新数据

/** 注册 **/
- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

/** 刷新布局 **/
- (void)updateLayout;

/** 开始自动滚动 **/
- (void)startAutoScroll;

/** 关闭自动滚动 **/
- (void)stopAutoScroll;

@end

NS_ASSUME_NONNULL_END
