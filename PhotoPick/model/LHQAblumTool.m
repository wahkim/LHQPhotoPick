//
//  LHQAblumTool.m
//  PhotoPick
//
//  Created by Hq.Lin on 2017/11/16.
//  Copyright © 2017年 lin. All rights reserved.
//

#import "LHQAblumTool.h"

@implementation LHQAblumList

@end

@implementation LHQAblumTool

+ (instancetype)shareAblumTool
{
    static dispatch_once_t onceToken;
    static LHQAblumTool *tool = nil;
    dispatch_once(&onceToken, ^{
        tool = [[LHQAblumTool alloc]init];
    });
    return tool;
}

#pragma mark -- 获取所有相册列表
- (NSArray<LHQAblumList *> *)getPhotoAblumList
{
    NSMutableArray<LHQAblumList *> *photoAblumList = [NSMutableArray array];
    
    //获取所有智能相册
    PHFetchResult *smartAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAblums enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
       //过滤掉视频和最近删除
        if (![collection.localizedTitle isEqualToString:@"Recently Deleted"] || [collection.localizedTitle isEqualToString:@"Videos"]) {
            NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:YES];
            if (assets.count > 0) {
                LHQAblumList *ablum = [[LHQAblumList alloc]init];
                ablum.title = [self transformAblumTitle:collection.localizedTitle];
                ablum.count = assets.count;
                ablum.headImageAsset = assets.firstObject;
                ablum.assetCollecttion = collection;
                [photoAblumList addObject:ablum];
            }
        }
    }];
    
    //获取用户创建的相册
    PHFetchResult *userAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAblums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:YES];
        if (assets.count > 0) {
            LHQAblumList *ablum = [[LHQAblumList alloc]init];
            ablum.title = collection.localizedTitle;
            ablum.count = assets.count;
            ablum.headImageAsset = assets.firstObject;
            ablum.assetCollecttion = collection;
            [photoAblumList addObject:ablum];
        }
    }];
    
    return photoAblumList;
}
- (NSString *)transformAblumTitle:(NSString *)title
{
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
    } else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    }
    return nil;
}
#pragma mark -- 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    
    return assets;
}
#pragma mark -- 获取指定相册内所有的图片
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *array = [NSMutableArray array];
    
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:YES];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [array addObject:obj];
        }
    }];
    return array;
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

#pragma mark -- 获取asset对应的图片
-  (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.resizeMode = resizeMode;//控制照片尺寸
    option.networkAccessAllowed = YES;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        completion(result);
    }];
}














@end
