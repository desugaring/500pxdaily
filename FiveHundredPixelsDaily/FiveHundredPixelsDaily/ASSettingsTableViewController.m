//
//  ASSettingsTableViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-28.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASSettingsTableViewController.h"
#import "ASStore.h"
#import "ASCategory.h"
#import "ASSettingsPhotosTableViewCell.h"
#import "ASSettingsCategoryTableViewCell.h"

int const MAX_NUMBER_OF_DAILY_CATEGORIES = 3;

@interface ASSettingsTableViewController ()

@property NSArray *sections;
@property NSString *activePhotosAlbumName;
@property NSMutableArray *selectedCategories;
@property NSUInteger categoriesCount;
@property NSUInteger categoriesSection;

@end

@implementation ASSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = false;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];

    self.sections = @[@"Description", @"Photos", @"Number", @"Categories"];
    self.categoriesCount = self.store.categories.count;

    self.categoriesSection = [self.sections indexOfObject:@"Categories"];
    self.selectedCategories = [NSMutableArray arrayWithCapacity:self.categoriesCount];
    [self.store.categories enumerateObjectsUsingBlock:^(ASCategory *category, NSUInteger idx, BOOL *stop) {
        if (category.isDaily.boolValue == true) [self.selectedCategories addObject:[NSIndexPath indexPathForRow:idx inSection:self.categoriesSection]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.activePhotosAlbumName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveAlbum"];
    [self.tableView reloadData];
}

- (void)closeModal:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.sections[section] isEqualToString:@"Description"]) {
        return 1;
    } else if ([self.sections[section] isEqualToString:@"Photos"]) {
        return 1;
    } else if ([self.sections[section] isEqualToString:@"Categories"]) {
        return self.categoriesCount;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sections[indexPath.section] isEqualToString:@"Description"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];

        return cell;

    } else if ([self.sections[indexPath.section] isEqualToString:@"Photos"]) {
        ASSettingsPhotosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photos" forIndexPath:indexPath];
        cell.photosAlbumLabel.text = self.activePhotosAlbumName;
        
        return cell;

    } else if ([self.sections[indexPath.section] isEqualToString:@"Categories"]) {
        ASSettingsCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category" forIndexPath:indexPath];
        ASCategory *category = self.store.categories[indexPath.row];
        [cell configureCellWithCategory:category];
        
        if ([self.selectedCategories containsObject:indexPath] == true) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.backgroundColor = [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:1];
        }

        return cell;
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.sections[section] isEqualToString:@"Description"]) {
        return @"What is DailyPhotos for 500px?";
    } else if ([self.sections[section] isEqualToString:@"Photos"]) {
        return @"Downloaded Photos Album";
    } else if ([self.sections[section] isEqualToString:@"Categories"]) {
        return @"Categories";
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    headerView.textLabel.textColor = [UIColor whiteColor];
    headerView.backgroundView.backgroundColor = [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:0.8];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sections[indexPath.section] isEqualToString:@"Description"]) {
        return 60;
    } else if ([self.sections[indexPath.section] isEqualToString:@"Photos"]) {
        return 44;
    } else if ([self.sections[indexPath.section] isEqualToString:@"Categories"]) {
        return 44;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.categoriesSection) return;
    
    ASSettingsCategoryTableViewCell *cell = (ASSettingsCategoryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([self.selectedCategories containsObject:indexPath] == true) {
        [self.selectedCategories removeObject:indexPath];
        cell.category.isDaily = @(false);
    } else {
        if (self.selectedCategories.count == MAX_NUMBER_OF_DAILY_CATEGORIES) return;
        [self.selectedCategories addObject:indexPath];
        cell.category.isDaily = @(true);
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
