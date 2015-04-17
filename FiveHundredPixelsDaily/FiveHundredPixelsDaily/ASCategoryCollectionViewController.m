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

@property ASCategory *activeCategory;
@property NSSet *visibleCells;

@end

@implementation ASCategoryCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.visibleCells = [NSSet new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.title = [self.model activeCategory].name;

    self.activeCategory = [self.model activeCategory];
    [self.activeCategory addObserver:self forKeyPath:@"images" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.activeCategory removeObserver:self forKeyPath:@"images"];
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
    return self.activeCategory.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ASImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    ASImage *image = self.activeCategory.images[indexPath.row];
    if (image.thumbnail != nil) {
        cell.imageView.image = image.thumbnail;
        [cell.spinner stopAnimating];
    }

    return cell;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSSet *newVisibleCells = [NSSet setWithArray:[self.collectionView indexPathsForVisibleItems]];
    if ([newVisibleCells isEqualToSet:self.visibleCells] == false) {
        // Mark images that are no longer visible, by subtracting new visible cells from the old. Anything left over is no longer visible.
        NSMutableSet *oldCells = [self.visibleCells mutableCopy];
        [oldCells minusSet:newVisibleCells];
        for (NSIndexPath *indexPath in oldCells) {
            ((ASImage *)self.activeCategory.images[indexPath.row]).thumbnailVisible = false;
        }
        // Mark images that are newly visible, by subtracting old visible cells from the new.
        NSMutableSet *newCells = [newVisibleCells mutableCopy];
        [newCells minusSet:self.visibleCells];
        for (NSIndexPath *indexPath in newCells) {
            ((ASImage *)self.activeCategory.images[indexPath.row]).thumbnailVisible = true;
        }
    }

    // Load more images if needed
    NSInteger distantImageIndex = ((NSIndexPath *)newVisibleCells.allObjects.lastObject).row + 50;
    if (self.activeCategory.images.count < distantImageIndex && self.activeCategory.images.count != self.activeCategory.maxNumberOfImages) {
        [self.activeCategory requestImageData];
    }
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
