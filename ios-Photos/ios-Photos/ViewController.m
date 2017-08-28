//
//  ViewController.m
//  ios-Photos
//
//  Created by zj-db0631 on 2017/7/13.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "ViewController.h"

#import <Photos/Photos.h>
#import "SencondViewController.h"
#import "SelectPhotoView.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *photoAmountArray;

@property (nonatomic, strong) NSMutableDictionary *photoTitleAndAssetDic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SelectPhotoView *senced = [[SelectPhotoView alloc] initWithFrame:self.view.bounds complete:^(NSIndexPath *tableViewIndexPath, NSArray *assets) {
        
    }];
    [self.view addSubview:senced];
    
    _photoTitleAndAssetDic = [[NSMutableDictionary alloc] init];
    
    [self getAllPhotosFromAlbum];
}

- (NSString *)transformAblumTitle:(NSString *)title {
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }
    return nil;
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

    //所有相册
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
//    for (PHAsset *asset in assetsFetchResults) {
//        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            [_photoAmountArray addObject:result];
//            NSLog(@"%@\n",info);
//        }];
//    }
    
    _photoAmountArray = [_photoTitleAndAssetDic allKeys];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _photoAmountArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _photoAmountArray[indexPath.row]; 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = _photoAmountArray[indexPath.row];
    [self performSegueWithIdentifier:@"gotoPush" sender:_photoTitleAndAssetDic[key]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoPush"]) {
        SencondViewController *VC = segue.destinationViewController;
        VC.assetArray = (NSArray *)sender;
    }
}

@end
