//
//  XMPhotoCell.m
//  PhotoBrowser
//
//  Created by min on 2017/10/24.
//  Copyright © 2017年 mxm. All rights reserved.
//
//  图片浏览器的Cell

#import "XMPhotoCell.h"

@implementation XMPhotoCell
{
    UIActivityIndicatorView *_indicatorView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.delegate = self;
        [self.contentView addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:_imageView];
        //菊花指示器
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.contentView addSubview:_indicatorView];
    }
    return self;
}

- (void)startIndicatorAnimating
{
    [_indicatorView startAnimating];
}

- (void)stopIndicatorAnimating
{
    [_indicatorView stopAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = self.bounds.size;
    _imageView.frame = self.bounds;
    _indicatorView.frame = self.bounds;
}

//可缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

//保持图片缩放后显示在scrollView的中间
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
}

@end

NSString * const XMPhotoCellIdentifier = @"idXMPhotoCell";

//@implementation UIButton (IndexPath)
//- (void)setIndexPath:(NSIndexPath *)indexPath
//{
//    objc_setAssociatedObject(self, @selector(indexPath), indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (NSIndexPath *)indexPath
//{
//    return objc_getAssociatedObject(self, @selector(indexPath));
//}
//@end
