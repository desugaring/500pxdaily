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
#import "ASSettingsDescriptionTableViewCell.h"
#import "ASSettingsPhotosTableViewCell.h"
#import "ASSettingsNumberTableViewCell.h"
#import "ASSettingsCategoryTableViewCell.h"

@interface ASSettingsTableViewController ()

@property NSArray *sections;
@property (weak) ASStore *fhpStore;
@property NSString *activePhotosAlbumName;

@end

@implementation ASSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeModal:)];

    self.sections = @[@"Description", @"Photos", @"Number", @"Categories"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.activePhotosAlbumName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveAlbum"];
    [self.tableView reloadData];
}

- (void)closeModal:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    } else if ([self.sections[section] isEqualToString:@"Number"]) {
        return 1;
    } else if ([self.sections[section] isEqualToString:@"Categories"]) {
        return self.store.categories.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sections[indexPath.section] isEqualToString:@"Description"]) {
        ASSettingsDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];

        return cell;

    } else if ([self.sections[indexPath.section] isEqualToString:@"Photos"]) {
        ASSettingsPhotosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photos" forIndexPath:indexPath];
        cell.photosAlbumLabel.text = self.activePhotosAlbumName;
        return cell;

    } else if ([self.sections[indexPath.section] isEqualToString:@"Number"]) {
        ASSettingsNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Number" forIndexPath:indexPath];

        NSInteger number = [[NSUserDefaults standardUserDefaults] integerForKey:@"NumberOfImagesPerCategory"];
        cell.stepper.value = (double)number;
        [cell stepperValueChanged:cell.stepper];

        return cell;

    } else if ([self.sections[indexPath.section] isEqualToString:@"Categories"]) {
        ASSettingsCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Category" forIndexPath:indexPath];
        [cell configureCellWithCategory:self.store.categories[indexPath.row]];

        return cell;
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.sections[section] isEqualToString:@"Description"]) {
        return @"What is 500px Daily?";
    } else if ([self.sections[section] isEqualToString:@"Photos"]) {
        return @"Downloaded Photos Album";
    } else if ([self.sections[section] isEqualToString:@"Number"]) {
        return @"Number of photos per category, per day";
    } else if ([self.sections[section] isEqualToString:@"Categories"]) {
        return @"Categories";
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    headerView.textLabel.textColor = [UIColor whiteColor];
    headerView.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sections[indexPath.section] isEqualToString:@"Description"]) {
        return 60;
    } else if ([self.sections[indexPath.section] isEqualToString:@"Photos"]) {
        return 40;
    } else if ([self.sections[indexPath.section] isEqualToString:@"Number"]) {
        return 40;
    } else if ([self.sections[indexPath.section] isEqualToString:@"Categories"]) {
        return 40;
    }
    
    return 0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowPhotosAlbums"]) {
        //
    }
}


@end
