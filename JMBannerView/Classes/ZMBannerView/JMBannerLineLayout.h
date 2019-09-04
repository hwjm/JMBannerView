//
//  ZMBannerLineLayout.h
//  quanyou
//
//  Created by Dream on 2019/7/30.
//  Copyright © 2019 zimo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMBannerLineLayout : UICollectionViewFlowLayout

@property (nonatomic) CGSize centerItemSize;
@property (nonatomic, assign) CGFloat subItemScale;
@property (nonatomic, assign) CGFloat itemSpace;

@end

NS_ASSUME_NONNULL_END
