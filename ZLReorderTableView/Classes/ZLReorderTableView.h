//
//  ZLReorderTableView.h
//
//  Created by zlj on 2018/8/19.
//  Copyright © 2018 zlj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLReorderTableView;
@protocol ZLReorderTableViewDelegate <UITableViewDelegate>

@optional
/**
 开始移动
 @param indexPath 初始位置
 */
- (void)zl_tableView:(ZLReorderTableView *)tableView willMoveRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 结束移动
 @param indexPath 新位置
 */
- (void)zl_tableView:(ZLReorderTableView *)tableView didMoveRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol ZLReorderTableViewDataSource <UITableViewDataSource>

/**
 移动cell到指定位置
 @param indexPath 初始位置
 @param toIndexPath 新位置
 */
- (void)zl_tableView:(ZLReorderTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

@optional
/**
 是否允许移动cell，默认YES
 @param indexPath 位置
 */
- (BOOL)zl_tableView:(ZLReorderTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 是否允许移动cell到指定位置，只对indexPath.row==0的cell有意义，默认YES
 @param indexPath 初始位置
 @param toIndexPath 新位置
 */
- (BOOL)zl_tableView:(ZLReorderTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface ZLReorderTableView : UITableView

/// 是否开启排序，默认NO
@property (nonatomic, assign) BOOL enableReorder;
/// 是否正在排序
@property (nonatomic, assign, readonly) BOOL isReordering;

/// 移动时，cell的缩放比例，默认1.02
@property (nonatomic, assign) CGFloat movingScaleRatio;
/// 移动到边界时每帧自动滚动的速度，默认5
@property (nonatomic, assign) CGFloat autoScrollSpeed;

@property (nonatomic, weak) id<ZLReorderTableViewDelegate> delegate;
@property (nonatomic, weak) id<ZLReorderTableViewDataSource> dataSource;

@end
