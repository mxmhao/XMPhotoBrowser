//
//  XMPhotoCell.h
//  PhotoBrowser
//
//  Created by min on 2017/10/24.
//  Copyright © 2017年 mxm. All rights reserved.
// 
//  图片浏览器的Cell

#import <UIKit/UIKit.h>

//@interface UIButton (IndexPath)
//@property (nonatomic, retain) NSIndexPath *indexPath;
//@end

@interface XMPhotoCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
//@property (nonatomic, strong) UIButton *btnHDImage; //查看高清图片按钮

- (void)startIndicatorAnimating;
- (void)stopIndicatorAnimating;

@end

UIKIT_EXTERN NSString * const XMPhotoCellIdentifier;
