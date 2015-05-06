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

@interface ASSettingsTableViewController ()

@property NSArray *sections;
@property (weak) ASStore *fhpStore;
@property NSString *activePhotosAlbumName;
@property NSInteger numberOfActiveCategories;

@end

@implementation ASSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];

    self.sections = @[@"Description", @"Photos", @"Number", @"Categories"];

    self.numberOfActiveCategories = 0;
    for (ASCategory *category in self.fhpStore.categories) {
        if (category.isDaily.boolValue == true) self.numberOfActiveCategories++;
    }
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
        return self.store.categories.count;
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
        [cell configureCellWithCategory:self.store.categories[indexPath.row]];
        if (cell.category.isDaily.boolValue == true) [self.tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];

        return cell;
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.sections[section] isEqualToString:@"Description"]) {
        return @"What is 500px Daily?";
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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.numberOfActiveCategories--;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.numberOfActiveCategories >= 3 ? nil : indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.numberOfActiveCategories++;
}


@end
