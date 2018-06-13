//
//  XMPhotoBrowserViewController.h
//  PhotoBrowser
//
//  Created by min on 2017/10/24.
//  Copyright © 2017年 mxm. All rights reserved.
//
//  图片浏览器

#import <UIKit/UIKit.h>

@protocol XMPhotoBrowserDelegate <NSObject>
@required
- (NSInteger)numberOfItems;
- (void)imageView:(UIImageView *)imageView atIndex:(NSInteger)index;

@optional
- (void)prefetchItemsAtIndexSet:(NSIndexSet *)indexSet;
- (void)stayAtIndex:(NSInteger)index;
- (void)didRemoveFromSuperViewController;

@end

@interface XMPhotoBrowserViewController : UIViewController

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, weak) id<XMPhotoBrowserDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentIndex;

@end
