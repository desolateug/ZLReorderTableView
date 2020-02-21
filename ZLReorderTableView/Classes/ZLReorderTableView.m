//
//  ZLReorderTableView.m
//
//  Created by zlj on 2018/8/19.
//  Copyright © 2018 zlj. All rights reserved.
//

#import "ZLReorderTableView.h"

typedef NS_ENUM(NSUInteger, ZLTableViewScrollDirection) {
    ZLTableViewScrollDirectionUp,
    ZLTableViewScrollDirectionDown,
};

@interface ZLReorderTableView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *snapshot;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, assign) CGPoint pressPoint;
@property (nonatomic, assign) CGPoint initialCenter;
@property (nonatomic, strong) NSIndexPath *fromIndexPath;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) ZLTableViewScrollDirection scrollDirection;

@property (nonatomic, assign) BOOL isReordering;

@end


@implementation ZLReorderTableView

@dynamic delegate;
@dynamic dataSource;

#pragma mark - Override
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setupData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData {
    self.movingScaleRatio = 1.02;
    self.autoScrollSpeed = 8.0;
}

- (void)reloadData {
    // 中断移动
    self.longPressGesture.enabled = NO;
    self.longPressGesture.enabled = self.enableReorder;
    [super reloadData];
}

#pragma mark - Public
- (void)setEnableReorder:(BOOL)enableReorder {
    _enableReorder = enableReorder;
    if (enableReorder) {
        [self addGestureRecognizer:self.longPressGesture];
    } else {
        [self removeGestureRecognizer:self.longPressGesture];
    }
}

# pragma mark - Moving
- (void)longPressGestureAction:(UILongPressGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            // 手指按住位置对应的indexPath，可能为nil
            NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
            if (indexPath) {
                [self startMovingCellAtIndexPath:indexPath];
                self.pressPoint = location;
                self.initialCenter = self.snapshot.center;
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint center = self.initialCenter;
            center.y += location.y - self.pressPoint.y;
            [self updateSnapshootCenter:center];
            [self autoScrollIfNeed];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self endMovingCell];
            [self stopAutoScrollTimer];
        }
            break;
        default:
            break;
    }
}

- (void)updateSnapshootCenter:(CGPoint)center {
    CGFloat minY = self.contentOffset.y;
    if (minY <= 0) {
        minY -= self.contentInset.top;
    }
    CGFloat maxY = self.contentOffset.y + self.bounds.size.height;
    if (maxY >= self.contentSize.height) {
        maxY += self.contentInset.bottom;
    }
    maxY = MIN(maxY, self.contentSize.height);
    center.y = MAX(center.y, minY);
    center.y = MIN(center.y, maxY);
    self.snapshot.center = center;
    
    NSIndexPath *toIndexPath = [self indexPathForRowAtPoint:self.snapshot.center];
    if (!toIndexPath) {
        // 新增行
        CGRect rect = self.bounds;
        rect.origin.y = self.snapshot.center.y - self.bounds.size.height;
        NSArray *upIndexPaths = [self indexPathsForRowsInRect:rect];
        if (upIndexPaths) {
            upIndexPaths = [upIndexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
                if (obj1.section < obj2.section) {
                    return NSOrderedAscending;
                }
                if (obj1.row < obj2.row) {
                    return NSOrderedAscending;
                }
                return NSOrderedDescending;
            }];
            NSIndexPath *lastIndexPath = upIndexPaths.lastObject;
            if (![lastIndexPath isEqual:self.fromIndexPath]) {
                toIndexPath = [NSIndexPath indexPathForRow:lastIndexPath.row+1 inSection:lastIndexPath.section];
            }
        }
    }
    if (toIndexPath && ![toIndexPath isEqual:self.fromIndexPath]) {
        [self moveToNewIndexPath:toIndexPath];
    }
}

- (BOOL)canMoveIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(zl_tableView:canMoveRowAtIndexPath:)]) {
        return [self.dataSource zl_tableView:self canMoveRowAtIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)canMoveToNewIndexPath:(NSIndexPath *)toIndexPath {
    if ([self.dataSource respondsToSelector:@selector(zl_tableView:canMoveRowAtIndexPath:toIndexPath:)]) {
        return [self.dataSource zl_tableView:self canMoveRowAtIndexPath:self.fromIndexPath toIndexPath:toIndexPath];
    }
    return YES;
}

- (void)moveToNewIndexPath:(NSIndexPath *)toIndexPath {
    if (![self canMoveToNewIndexPath:toIndexPath]) {
        return;
    }
    NSInteger sectionsOld = [self.dataSource numberOfSectionsInTableView:self];
    if ([self.dataSource respondsToSelector:@selector(zl_tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [self.dataSource zl_tableView:self moveRowAtIndexPath:self.fromIndexPath toIndexPath:toIndexPath];
    }
    NSInteger sectionsNow = [self.dataSource numberOfSectionsInTableView:self];
    // 回调里可能修改了数据源，此处需要校验
    if (sectionsOld == sectionsNow) {
        [self moveRowAtIndexPath:self.fromIndexPath toIndexPath:toIndexPath];
        self.fromIndexPath = toIndexPath;
    } else {
        [self reloadData];
    }
}

- (void)startMovingCellAtIndexPath:(NSIndexPath *)indexPath {
    self.isReordering = YES;
    self.fromIndexPath = indexPath;
    if ([self.delegate respondsToSelector:@selector(zl_tableView:willMoveRowAtIndexPath:)]) {
        [self.delegate zl_tableView:self willMoveRowAtIndexPath:indexPath];
    }
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    self.snapshot = [self snapshotView:cell];
    [self addSubview:self.snapshot];
    cell.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.snapshot.alpha = 0.95;
        self.snapshot.transform = CGAffineTransformMakeScale(self.movingScaleRatio, self.movingScaleRatio);
    }];
}

- (void)endMovingCell {
    if (!self.fromIndexPath || !self.snapshot) {
        return;
    }
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.fromIndexPath];
    [UIView animateWithDuration:0.25 animations:^{
        self.snapshot.transform = CGAffineTransformIdentity;
        // 容错
        if (cell) {
            self.snapshot.alpha = 1;
            self.snapshot.center = cell.center;
        } else {
            self.snapshot.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        cell.hidden = NO;
        [self.snapshot removeFromSuperview];
        self.snapshot = nil;
        self.fromIndexPath = nil;
        self.isReordering = NO;
        if ([self.delegate respondsToSelector:@selector(zl_tableView:didMoveRowAtIndexPath:)]) {
            [self.delegate zl_tableView:self didMoveRowAtIndexPath:self.fromIndexPath];
        }
    }];
}

- (UIView *)snapshotView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = view.center;
    snapshot.layer.shadowOffset = CGSizeZero;
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.3;
    
    return snapshot;
}

#pragma mark - Auto scroll
- (void)autoScrollIfNeed {
    // 到边界自动滚动
    if ([self checkIfSnapshotReachEdge]) {
        [self startAutoScrollTimer];
    } else{
        [self stopAutoScrollTimer];
    }
}

- (BOOL)checkIfSnapshotReachEdge {
    CGFloat minY = CGRectGetMinY(self.snapshot.frame);
    CGFloat maxY = CGRectGetMaxY(self.snapshot.frame);
    if (minY < self.contentOffset.y) {
        self.scrollDirection = ZLTableViewScrollDirectionUp;
        return YES;
    }
    if (maxY > self.bounds.size.height + self.contentOffset.y) {
        self.scrollDirection = ZLTableViewScrollDirectionDown;
        return YES;
    }
    return NO;
}

- (void)startAutoScrollTimer {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAutoScrollTimer {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)startAutoScroll {
    if (self.scrollDirection == ZLTableViewScrollDirectionUp) {
        if (self.contentOffset.y > -self.contentInset.top) {
            [self setContentOffset:CGPointMake(0, self.contentOffset.y - self.autoScrollSpeed)];
            CGPoint center = CGPointMake(self.snapshot.center.x, self.snapshot.center.y - self.autoScrollSpeed);
            [self updateSnapshootCenter:center];
        }
    } else {
        if (self.contentOffset.y + self.bounds.size.height < self.contentSize.height + self.contentInset.bottom) {
            [self setContentOffset:CGPointMake(0, self.contentOffset.y + self.autoScrollSpeed)];
            CGPoint center = CGPointMake(self.snapshot.center.x, self.snapshot.center.y + self.autoScrollSpeed);
            [self updateSnapshootCenter:center];
        }
    }

    // 由于tableView复用机制，此处需重置隐藏状态
    [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        cell.hidden = [indexPath compare:self.fromIndexPath] == NSOrderedSame;
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _longPressGesture) {
        CGPoint location = [gestureRecognizer locationInView:self];
        NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
        return [self canMoveIndexPath:indexPath];
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - Lazy
- (UILongPressGestureRecognizer *)longPressGesture {
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureAction:)];
        _longPressGesture.delegate = self;
    }
    return _longPressGesture;
}

@end
