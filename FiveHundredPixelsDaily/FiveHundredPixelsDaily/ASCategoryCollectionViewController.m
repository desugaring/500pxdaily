//
//  ASCategoryCollectionViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoryCollectionViewController.h"
#import "ASImageCollectionViewCell.h"
#import "ASFHPStore.h"
#import "ASCategory.h"
#import "ASImage.h"

@interface ASCategoryCollectionViewController()

@property NSMutableSet *visibleIndexPaths;

@end

@implementation ASCategoryCollectionViewController

static NSString * const reuseIdentifier = @"Thumbnail";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.category.name;
    self.visibleIndexPaths = [NSMutableSet new];
    self.category.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.category.lastUpdated == nil) {
        [self.category resetImages];
        return;
    }
    NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self.category.lastUpdated toDate:[NSDate date] options:0] hour];
    if(hours >= 1) [self.category resetImages];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.category cancelImageRequests];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.category.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ASImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    ASImage *image = self.category.images[indexPath.item];
    if (image.thumbnail != nil) {
        cell.imageView.image = image.thumbnail;
        [cell.spinner stopAnimating];
    } else {
        [image requestThumbnailImageIfNeeded];
    }

    return cell;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSMutableSet *newIndexPaths = [NSMutableSet setWithArray:[self.collectionView indexPathsForVisibleItems]];
    if ([self.visibleIndexPaths isEqualToSet:newIndexPaths] == false) {
        // Cancel requests for images that are no longer visible
        [self.visibleIndexPaths minusSet:newIndexPaths];
        for (NSIndexPath *indexPath in self.visibleIndexPaths) {
            [(ASImage *)self.category.images[indexPath.item] cancelThumbnailRequestIfNeeded];
        }
        self.visibleIndexPaths = newIndexPaths;
        if (((NSIndexPath *)self.visibleIndexPaths.allObjects.lastObject).item + 50 >= self.category.images.count) [self.category requestImageData];
    }
}

#pragma mark - Category Image Delegate

- (void)imageThumbnailUpdated:(ASImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.category.images indexOfObject:image] inSection:0];
        if ((self.visibleIndexPaths.count == 0) || ([self.visibleIndexPaths containsObject:indexPath] == true)) [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
}

- (void)numberOfImagesUpdated {
    NSLog(@"collection view num o fimages updated for category %@", self.category.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(categoryImageWasSelected:)]) [self.delegate categoryImageWasSelected:self.category.images[indexPath.item]];
}

// Uncomment this method to specify if the specified item should be selected
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
