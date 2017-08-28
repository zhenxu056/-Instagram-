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
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
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

//从系统中捕获所有相片
- (void)getAllPhotosFromAlbum {
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *smartAlbums1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    BOOL isHavePhoto;
    for (PHCollection *collection in smartAlbums1) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            
            NSMutableArray *photoArray = [[NSMutableArray alloc] init];
            isHavePhoto = NO;
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            NSLog(@"名字  %@   %ld",collection.localizedTitle, fetchResult.count);
            NSString *key = [NSString stringWithFormat:@"%@   数量%ld",collection.localizedTitle, fetchResult.count];
            for (PHAsset *asset in fetchResult) {
                isHavePhoto = YES;
                [photoArray addObject:asset];
            }
            
            if (isHavePhoto) {
                [_photoTitleAndAssetDic setObject:photoArray forKey:key];
            }
        }
        else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    
    for (PHCollection *collection in smartAlbums) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            
            NSMutableArray *photoArray = [[NSMutableArray alloc] init];
            isHavePhoto = NO;
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            NSLog(@"名字  %@   %ld",collection.localizedTitle, fetchResult.count);
            NSString *key = [NSString stringWithFormat:@"%@   数量%ld",collection.localizedTitle, fetchResult.count];
            for (PHAsset *asset in fetchResult) {
                isHavePhoto = YES;
                [photoArray addObject:asset];
            }
            
            if (isHavePhoto) {
                [_photoTitleAndAssetDic setObject:photoArray forKey:key];
            }
        }
        else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
    
    // 列出所有用户创建的相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    for (PHCollection *collection in topLevelUserCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            NSMutableArray *photoArray = [[NSMutableArray alloc] init];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            // 从每一个智能相册中获取到的 PHFetchResult 中包含的才是真正的资源（PHAsset）
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            NSLog(@"用户创建的相册名字  %@   %ld",collection.localizedTitle, fetchResult.count);
            NSString *key = [NSString stringWithFormat:@"%@   数量%ld",collection.localizedTitle, fetchResult.count];
            for (PHAsset *asset in fetchResult) {
                [photoArray addObject:asset];
            }
            [_photoTitleAndAssetDic setObject:photoArray forKey:key];
        }
        else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    NSString *key = [NSString stringWithFormat:@"全部照片   数量%ld", assetsFetchResults.count];
    for (PHAsset *asset in assetsFetchResults) {
        [photoArray addObject:asset];
    }
    [_photoTitleAndAssetDic setObject:photoArray forKey:key];
    
    _photoAmountArray = [_photoTitleAndAssetDic allKeys];
    
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _photoAmountArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSString *key = _photoAmountArray[indexPath.row];
    cell.textLabel.text = key;
    [cell setBackgroundColor:[UIColor redColor]];
//    NSArray *assets = _photoTitleAndAssetDic[key];
//    [[PHImageManager defaultManager] requestImageForAsset:assets.firstObject targetSize:self.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        cell.imageView.image = result;
//    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.block) {
        NSString *key = _photoAmountArray[indexPath.row];
        NSArray *assets = _photoTitleAndAssetDic[key];
        self.block(indexPath, assets);
    }
}

@end
