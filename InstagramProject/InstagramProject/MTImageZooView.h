//
//  MTImageZooView.h
//  ImageScorllView
//
//  Created by zj-db0631 on 2017/7/12.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MAINSIZE_Width [UIScreen mainScreen].bounds.size.width
#define MAINSIZE_Height [UIScreen mainScreen].bounds.size.height
@interface MTImageZooView : UIView

@property (nonatomic, strong) UIImage *displayImage;

@property (nonatomic, assign) BOOL isClose;

@end
