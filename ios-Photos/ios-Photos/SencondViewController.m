//
//  SencondViewController.m
//  ios-Photos
//
//  Created by zj-db0631 on 2017/7/14.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "SencondViewController.h"
#import "SelectPhotoCollectionViewCell.h"
#import <Photos/Photos.h>
@interface SencondViewController ()

@end

@implementation SencondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assetArray.count;
}

#pragma mark UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectPhotoCollectionViewCell" forIndexPath:indexPath];
    
    [[PHImageManager defaultManager] requestImageForAsset:_assetArray[indexPath.row] targetSize:self.view.bounds.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.image setImage:result];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
