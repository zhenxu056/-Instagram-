//
//  MTImageZooView.m
//  ImageScorllView
//
//  Created by zj-db0631 on 2017/7/12.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTImageZooView.h"

@interface MTImageZooView ()<UIScrollViewDelegate>
{
    UIImage *disImage;
    BOOL isOpen;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MTImageZooView

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, MAINSIZE_Width, MAINSIZE_Height/3*2-40)];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.bouncesZoom = YES;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 0.5;
        [_scrollView setBackgroundColor:[UIColor whiteColor]];
    }
    return _scrollView;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setBackgroundColor:[UIColor grayColor]];
    }
    return _imageView;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    
}


- (void)setDrawImage {
    [self.scrollView setZoomScale:1.0 animated:NO];
    
    CGRect frame = self.imageView.frame;
    if (disImage) {
        if (disImage.size.height > disImage.size.width) {
            frame.size.width = self.scrollView.bounds.size.width;
            frame.size.height = (self.scrollView.bounds.size.width / disImage.size.width) * disImage.size.height;
        } else {
            frame.size.height = self.scrollView.bounds.size.height;
            frame.size.width = (self.scrollView.bounds.size.height / disImage.size.height) * disImage.size.width;
        }
        frame.origin.x = 0;
        frame.origin.y = 0;
    }
    else {
        frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
    
    self.imageView.frame = frame;
    
    [self.imageView setImage:disImage];
    
    self.scrollView.contentSize = frame.size;
    
    
}
//缩放结束
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scale > 1.0) {
        return;
    }
    if (disImage.size.height > disImage.size.width) {
        CGFloat imageScale = [self imageCompressForWidthScale:disImage targetWidth:0 targetHeight:scrollView.frame.size.height];
        [self.scrollView setZoomScale:1.0 - imageScale  animated:YES];
    }
    else {
        CGFloat imageScale = [self imageCompressForWidthScale:disImage targetWidth:scrollView.frame.size.width targetHeight:0]; 
        [self.scrollView setZoomScale:1.0 - imageScale*2  animated:YES];
    }
//    NSLog(@"scale %lf",scale);
//    NSLog(@"scale == %lf sum %lf",[self imageCompressForWidthScale:disImage targetWidth:scrollView.frame.size.width targetHeight:0], scale + [self imageCompressForWidthScale:disImage targetWidth:scrollView.frame.size.width targetHeight:0]*2);
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?(_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?
    (_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX,_scrollView.contentSize.height * 0.5 + offsetY);
}

//指定宽度按比例缩放
- (CGFloat)imageCompressForWidthScale:(UIImage *)sourceImage
                          targetWidth:(CGFloat)defineWidth
                          targetHeight:(CGFloat)defineHeight {
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (defineWidth) {
        CGFloat targetWidth = defineWidth;
        CGFloat targetHeight = height / (width / targetWidth);
        CGSize size = CGSizeMake(targetWidth, targetHeight);
        CGFloat scaleFactor = 0.0;
        
        if(CGSizeEqualToSize(imageSize, size) == NO){
            
            CGFloat widthFactor = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            
            if(widthFactor > heightFactor){
                scaleFactor = widthFactor;
            }
            else{
                scaleFactor = heightFactor;
            }
        }
        return scaleFactor;
    }
    else {
        CGFloat targetHeight = defineHeight;
        CGFloat targetWidth = width / (height / targetHeight);
        CGSize size = CGSizeMake(targetWidth, targetHeight);
        CGFloat scaleFactor = 0.0;
        
        if(CGSizeEqualToSize(imageSize, size) == NO){
            
            CGFloat widthFactor = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            
            if(widthFactor > heightFactor){
                scaleFactor = widthFactor;
            }
            else{
                scaleFactor = heightFactor;
            }
        }
        return scaleFactor;
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)setDisplayImage:(UIImage *)displayImage {
    disImage = displayImage;
    [self setDrawImage];
}
- (void)setIsClose:(BOOL)isClose {
    self.scrollView.scrollEnabled = isClose;
}

@end
