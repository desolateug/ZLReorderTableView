//
//  ZLViewController.m
//  ZLReorderTableView
//
//  Created by zlj on 02/20/2020.
//  Copyright (c) 2020 zlj. All rights reserved.
//

#import "ZLViewController.h"
#import <ZLReorderTableView.h>

NSString *CANTMOVETEXT = @"Can't be moved.";
NSString *CANTMOVETOTEXT = @"Can't insert into.";

@interface ZLViewController () <
    ZLReorderTableViewDelegate,
    ZLReorderTableViewDataSource
>

@property (nonatomic, strong) ZLReorderTableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataSource;

@end

@implementation ZLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupSubviews];
}

- (void)setupData {
    NSMutableArray *dataSource = [NSMutableArray array];
    for (int section = 0; section < 3; section++) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        for (int row = 0; row < 6; row ++) {
            NSString *text = [NSString stringWithFormat:@"%d-%d", section, row];
            [sectionArray addObject:text];
        }
        [dataSource addObject:sectionArray];
    }
    
    dataSource[0][0] = [dataSource[0][0] stringByAppendingFormat:@" %@", CANTMOVETEXT];
    dataSource[0][2] = [dataSource[0][2] stringByAppendingFormat:@" %@", CANTMOVETEXT];
//    dataSource[1][3] = [dataSource[1][3] stringByAppendingFormat:@" %@", CANTMOVETEXT];
    
    dataSource[0][0] = [dataSource[0][0] stringByAppendingFormat:@" %@", CANTMOVETOTEXT];
//    dataSource[1][0] = [dataSource[1][0] stringByAppendingFormat:@" %@", CANTMOVETOTEXT];
    
    self.dataSource = dataSource;
}

- (void)setupSubviews {
    self.tableView = [[ZLReorderTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.enableReorder = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"section %ld", section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:(1.0f - (CGFloat)(indexPath.section + 1)/([tableView numberOfSections] + 1)) green:1.f blue:1.0f alpha:1.0f];
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}

- (BOOL)zl_tableView:(ZLReorderTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.dataSource[indexPath.section][indexPath.row];
    return ![text containsString:CANTMOVETEXT];
}

- (BOOL)zl_tableView:(ZLReorderTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
         toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableArray *sectionArray = self.dataSource[toIndexPath.section];
    if (toIndexPath.row < sectionArray.count) {
        NSString *text = sectionArray[toIndexPath.row];
        return ![text containsString:CANTMOVETOTEXT];
    }
    // insert
    return YES;
}

- (void)zl_tableView:(ZLReorderTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSString *object = self.dataSource[indexPath.section][indexPath.row];
    
    NSMutableArray *sectionArray1 = self.dataSource[indexPath.section];
    [sectionArray1 removeObjectAtIndex:indexPath.row];
    if (sectionArray1.count == 0) {
        [self.dataSource removeObject:sectionArray1];
    }
    
    NSMutableArray *sectionArray2 = self.dataSource[toIndexPath.section];
    [sectionArray2 insertObject:object atIndex:toIndexPath.row];
}

@end
