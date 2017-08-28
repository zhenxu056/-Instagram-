//
//  ViewController.m
//  InstagramProject
//
//  Created by zj-db0631 on 2017/7/11.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "ViewController.h"

#import <Photos/Photos.h>
#import "SelectPhotoCollectionViewCell.h"
#import "MTImageZooView.h"
#import "SelectPhotoView.h"

static dispatch_once_t onceToken;

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _collectionHeight;
    CGFloat _showPhotoHeight;
    CGFloat _lastContentOffset;
    
    CGFloat _arraiveShowView;
    
    BOOL _isShowViewArriveTop;
    BOOL _isCollectionArriveTop;
    
    BOOL _isStarAnimate;
    BOOL _isCloseAnimate;
    
    BOOL _isFristClose;
    BOOL _isFristStar;
    BOOL _isOpenSelectPhoto;
    BOOL _isPullDownFrist;
    
    SelectPhotoView *selectView;
}

@property (weak, nonatomic) IBOutlet UIView *selectPhotoView;
@property (weak, nonatomic) IBOutlet MTImageZooView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *showImageMenuView;
@property (weak, nonatomic) IBOutlet UIView *showBottomView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewDisTopConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showPhotoViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *photoArray;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
//    _scrollView.scrollsToTop = NO;
    
    _isShowViewArriveTop = NO;
    _isCollectionArriveTop = NO;
    _isCloseAnimate = YES;
    
    _isFristClose = NO;
    _isFristStar = YES;
    _isOpenSelectPhoto = NO;
    
    _collectionHeight = MAINSIZE_Height/3;
    _showPhotoHeight = MAINSIZE_Height/3*2;
    
    self.scrollViewHeight.constant = MAINSIZE_Height+_showPhotoHeight-40;
    self.collectionViewDisTopConstaint.constant = _showPhotoHeight;
    self.collectionViewViewHeight.constant = _collectionHeight;
    self.showPhotoViewHeight.constant = _showPhotoHeight;
    
    [self setUI];
}

- (void)setUI {
    __weak typeof(self) weakSelf = self;
    selectView = [[SelectPhotoView alloc] initWithFrame:CGRectMake(0, MAINSIZE_Height, MAINSIZE_Width, MAINSIZE_Height-40) complete:^(NSIndexPath *tableViewIndexPath, NSArray *assets, BOOL isFristOpen) {
        weakSelf.photoArray = [assets mutableCopy];
        [[PHImageManager defaultManager] requestImageForAsset:assets.firstObject targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            _imageScrollView.displayImage = result;
            if (!isFristOpen) {
                [weakSelf selectPhotoAction:nil];
            } 
        }];
        
        [weakSelf.collectionView reloadData];
    }];
    [self.view addSubview:selectView];
    
    //添加在CollectionView上
    UIPanGestureRecognizer * collectionViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPanAction:)];
    collectionViewPan.delegate = self;
    [self.collectionView addGestureRecognizer:collectionViewPan];
    
    [self.imageScrollView bringSubviewToFront:self.showImageMenuView];
    [self.imageScrollView bringSubviewToFront:self.showBottomView];
}

#pragma mark - Action
#pragma mark -- SelectPhotosAction

- (IBAction)selectPhotoAction:(UIButton *)sender {
    if (!_isOpenSelectPhoto) {
        selectView.isStarAn = YES;
        [UIView animateWithDuration:0.3 animations:^{
            selectView.frame = CGRectMake(0, 40, MAINSIZE_Width, MAINSIZE_Height-40);
        } completion:^(BOOL finished) {
            if (finished) {
                _isOpenSelectPhoto = YES;
            }
        }];
    }
    else {
        selectView.isStarAn = NO;
        [UIView animateWithDuration:0.3 animations:^{
            selectView.frame = CGRectMake(0, MAINSIZE_Height, MAINSIZE_Width, MAINSIZE_Height-40);
        } completion:^(BOOL finished) {
            if (finished) {
                _isOpenSelectPhoto = NO;
            }
        }];
    }
    
}



#pragma mark -- CollectionViewPanAction

- (void)collectionViewPanAction:(UIPanGestureRecognizer *)sender {
    static CGPoint oldPoint;
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        oldPoint = [sender locationInView:self.view];
    }
    CGPoint newPoint = [sender locationInView:self.view];
    if (_showPhotoHeight >= newPoint.y && newPoint.y >= 40) {
        if (!_isShowViewArriveTop) {
            
            dispatch_once(&onceToken, ^{
                
                _arraiveShowView = oldPoint.y - _showPhotoHeight;
            
            });
            
            [self.collectionView setContentOffset:CGPointMake(0, _arraiveShowView)];
            
            if (_isCloseAnimate) {
                [self.scrollView setContentOffset:CGPointMake(0.0, _showPhotoHeight-newPoint.y)];
            }
            
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGPoint offset = scrollView.contentOffset;
        if (offset.y > 0 && offset.y < _showPhotoHeight-40) {
            self.collectionViewViewHeight.constant = _collectionHeight + offset.y;
        }
    }
    else {
        CGPoint offset = scrollView.contentOffset;
        if (offset.y <= 0) {
            _isPullDownFrist = YES;
        }
        else {
            _isPullDownFrist = NO;
        }
        if (_isPullDownFrist) {
//            [self closeAnimate];
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if (scrollView == self.collectionView) {
//        NSLog(@"我到了----");
//    }
//    else {
//        NSLog(@"我到了=====");
//        
//    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.collectionView) {
        NSLog(@"我到了----");
    }
    else {
        NSLog(@"我到了=====");
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGPoint offset = _scrollView.contentOffset;
//    NSLog(@"我到了");
    if (_isCloseAnimate) {
        if (offset.y > 40) {
            [self starAnimate];
        }
        else {
            [self closeAnimate];
        }
    }
    
    if (_isStarAnimate) {
        if (offset.y < _showPhotoHeight - 45) {
            [self closeAnimate];
        }
        else {
            [self starAnimate];
        }
    }
    
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    _lastContentOffset = scrollView.contentOffset.y;
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        return YES;
    }
    if ([otherGestureRecognizer.view isMemberOfClass:[UIScrollView class]]) {
        return YES;
    }
    if ([otherGestureRecognizer.view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
//    return 50;
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectPhotoCollectionViewCell" forIndexPath:indexPath];
    [[PHImageManager defaultManager] requestImageForAsset:self.photoArray[indexPath.row] targetSize:CGSizeMake((MAINSIZE_Width)/4-2, MAINSIZE_Width/4-6) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.image setImage:result];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestImageForAsset:self.photoArray[indexPath.row] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.imageScrollView.displayImage = result;
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((MAINSIZE_Width)/4-2, MAINSIZE_Width/4-6);
}

#pragma mark - PrivateMethod

- (void)starAnimate {
    __weak typeof(self) weakSelf = self;
    self.imageScrollView.isClose = NO;
    _isCloseAnimate = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf.scrollView setContentOffset:CGPointMake(0.0, _showPhotoHeight-40)];
    } completion:^(BOOL finished) {
        if (finished) {
            onceToken = 0;//清除单利
            _isStarAnimate = YES;
            _isShowViewArriveTop = YES;
            _isFristStar = YES;
            weakSelf.collectionViewViewHeight.constant = MAINSIZE_Height-40;
            [self.imageScrollView setIsClose:NO];
            
        }
    }];
}

- (void)closeAnimate {
    __weak typeof(self) weakSelf = self;
    self.imageScrollView.isClose = YES;
    _isStarAnimate = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf.scrollView setContentOffset:CGPointMake(0.0, 0.0)];
    } completion:^(BOOL finished) {
        if (finished) {
            _isCloseAnimate = YES;
            _isShowViewArriveTop = NO;
            _isFristStar = YES;
            weakSelf.collectionViewViewHeight.constant = _collectionHeight;
            [weakSelf.imageScrollView setIsClose:YES];
        }
    }];
}

@end
