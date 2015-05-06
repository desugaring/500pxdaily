//
//  ASPhotosAlbumsTableViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-05-03.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASPhotosAlbumsTableViewController.h"
#import "ASPhotosAlbumTableViewCell.h"

@interface ASPhotosAlbumsTableViewController() <PHPhotoLibraryChangeObserver>

@property PHFetchResult *photosAlbums;
@property NSString *activeAlbumName;
@property NSString *activeAlbumIdentifier;

@end

@implementation ASPhotosAlbumsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"New"] style:UIBarButtonItemStylePlain target:self action:@selector(handleAddButtonItem:)];

    // Get Active Album
    self.activeAlbumName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveAlbum"];
    self.activeAlbumIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"ActiveAlbumIdentifier"];

    // Get Albums
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    self.photosAlbums = albums;

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:self.photosAlbums];
        if (changeDetails != nil) {
            self.photosAlbums = [changeDetails fetchResultAfterChanges];
            [self.tableView reloadData];
        }
    });
}

- (void)closeModal:(UIBarButtonItem *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.activeAlbumName forKey:@"ActiveAlbum"];
    [[NSUserDefaults standardUserDefaults] setObject:self.activeAlbumIdentifier forKey:@"ActiveAlbumIdentifier"];
    
    [self dismissViewControllerAnimated:true completion:nil];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photosAlbums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASPhotosAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Album" forIndexPath:indexPath];
    PHCollection *collection = (PHCollection *)[self.photosAlbums objectAtIndex:indexPath.row];

    [cell configureCellWithCollection:collection];
    if ([collection.localizedTitle isEqualToString:self.activeAlbumName]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];
    }

    return cell;
}

- (void)handleAddButtonItem:(id)sender
{
    // Prompt user from new album title.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Create New Album", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Album Name", @"");
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSString *title = textField.text;

        // Create new album.
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error creating album: %@", error);
            }
        }];
    }]];
    alertController.view.tintColor = [UIColor blackColor];

    [self.tableView deselectRowAtIndexPath:(NSIndexPath *)sender animated:false];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASPhotosAlbumTableViewCell *cell = (ASPhotosAlbumTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    self.activeAlbumName = cell.collection.localizedTitle;
    self.activeAlbumIdentifier = cell.collection.localIdentifier;
}

@end
