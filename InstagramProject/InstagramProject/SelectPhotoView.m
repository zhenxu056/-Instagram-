//
//  SelectPhotoView.m
//  InstagramProject
//
//  Created by zj-db0631 on 2017/7/14.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "SelectPhotoView.h"

#import <Photos/Photos.h>

#define MAINSIZE_Width [UIScreen mainScreen].bounds.size.width
#define MAINSIZE_Height [UIScreen mainScreen].bounds.size.height

static NSString *cellIdentifier = @"childs";

@interface SelectPhotoView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *photoAmountArray;
@property (nonatomic, strong) NSMutableDictionary *photoTitleAndAssetDic;

@end

@implementation SelectPhotoView

- (instancetype)initWithFrame:(CGRect)frame complete:(selectPhotoAssets)complet {
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAINSIZE_Width, MAINSIZE_Height-40) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [self addSubview:self.tableView];
        
        self.block = complet;
        
        _photoTitleAndAssetDic = [[NSMutableDictionary alloc] init];
        
        [self getAllPhotosFromAlbum];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setIsStarAn:(BOOL)isStarAn {
    if (isStarAn) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, 0, MAINSIZE_Width, MAINSIZE_Height-40);
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, MAINSIZE_Height, MAINSIZE_Width, MAINSIZE_Height-40);
        } completion:^(BOOL finished) {
            
        }];
    }
}


#pragma mark - 从系统中捕获所有相片
- (void)getAllPhotosFromAlbum {
     __weak typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            return ;
        }
        else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //创建时间排序
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                
                //获取照片流
                PHFetchResult *smartAlbums1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                [weakSelf getAssetsInAssetCollection:smartAlbums1 option:options isHaveCountZreo:YES];
                
                //获取系统相册
                PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
                [weakSelf getAssetsInAssetCollection:smartAlbums option:options isHaveCountZreo:YES];
                
                // 列出所有用户创建的相册
                PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
                [weakSelf getAssetsInAssetCollection:topLevelUserCollections option:options isHaveCountZreo:YES];
                
                //全部相册
                PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
                NSMutableArray *photoArray = [[NSMutableArray alloc] init];
                NSString *key = [NSString stringWithFormat:@"全部照片   数量%ld", assetsFetchResults.count];
                for (PHAsset *asset in assetsFetchResults) {
                    [photoArray addObject:asset];
                }
                [_photoTitleAndAssetDic setObject:photoArray forKey:key];
                
                
                _photoAmountArray = [_photoTitleAndAssetDic allKeys];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.block) {
                        NSString *key = _photoAmountArray[0];
                        NSArray *assets = _photoTitleAndAssetDic[key];
                        weakSelf.block(nil, assets, YES);
                    }
                    [weakSelf.tableView reloadData];
                });

            });
        }

    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _photoAmountArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSString *key = _photoAmountArray[indexPath.row];
    cell.textLabel.text = key;
    NSArray *assets = _photoTitleAndAssetDic[key];
    [[PHImageManager defaultManager] requestImageForAsset:assets.firstObject targetSize:self.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.block) {
        NSString *key = _photoAmountArray[indexPath.row];
        NSArray *assets = _photoTitleAndAssetDic[key];
        self.block(indexPath, assets, NO);
    }
}


#pragma mark - 获取指定相册内的所有图片
- (void)getAssetsInAssetCollection:(PHFetchResult *)assetCollection option:(PHFetchOptions *)option isHaveCountZreo:(BOOL)isCount {
    BOOL isHavePhoto;
    for (PHCollection *collection in assetCollection) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            
            NSMutableArray *photoArray = [[NSMutableArray alloc] init];
            isHavePhoto = YES;
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
            NSLog(@"名字  %@   %ld",collection.localizedTitle, fetchResult.count);
            NSString *key = [NSString stringWithFormat:@"%@   数量%ld",collection.localizedTitle, fetchResult.count];
            for (PHAsset *asset in fetchResult) {
                if (isCount) {
                    isHavePhoto = NO;
                }
                [photoArray addObject:asset];
            }
            
            if (!isHavePhoto) {
                [_photoTitleAndAssetDic setObject:photoArray forKey:key];
            }
        }
        else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
}

@end
