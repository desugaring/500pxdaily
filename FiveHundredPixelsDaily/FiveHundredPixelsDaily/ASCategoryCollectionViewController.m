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

@property NSArray *visibleIndexPaths;

@end

@implementation ASCategoryCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.category.name;
    self.visibleIndexPaths = [NSArray new];
    self.category.delegate = self;
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

    ASImage *image = self.category.images[indexPath.row];
    if (image.thumbnail != nil) {
        cell.imageView.image = image.thumbnail;
        [cell.spinner stopAnimating];
    }

    return cell;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([[self.collectionView indexPathsForVisibleItems] isEqualToArray:self.visibleIndexPaths] == false) {
        self.visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];

        NSMutableArray *newVisibleImages = [NSMutableArray new];
        [self.visibleIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [newVisibleImages addObject:self.category.images[indexPath.item]];
        }];
        [self.category setVisibleImages:newVisibleImages ofSize:ASImageSizeThumbnail];
    }
}

#pragma mark - Category Image Delegate

- (void)thumbnailImageUpdated:(ASImage *)image {
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.category.images indexOfObject:image] inSection:0]]];
}

- (void)numberOfImagesUpdated {
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

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
