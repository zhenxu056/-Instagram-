//
//  SelectPhotoView.h
//  InstagramProject
//
//  Created by zj-db0631 on 2017/7/14.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^selectPhotoAssets)(NSIndexPath *tableViewIndexPath, NSArray *assets, BOOL isFristOpen);

@interface SelectPhotoView : UIView

@property (copy, nonatomic) selectPhotoAssets block;

@property (nonatomic, assign) BOOL isStarAn;

- (instancetype)initWithFrame:(CGRect)frame complete:(selectPhotoAssets)complet;

@end
