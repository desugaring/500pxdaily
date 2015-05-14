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
#import "ASLoadingFooterCollectionReusableView.h"

@interface ASCategoryCollectionViewController() <UICollectionViewDelegateFlowLayout>

@property NSMutableSet *visibleIndexPaths;
@property NSUInteger numberOfImages;
@property CGSize cellSize;
@property BOOL showRefreshBanner;
@property BOOL loadingMore;

@end

@implementation ASCategoryCollectionViewController

static NSString * const reuseIdentifier = @"Thumbnail";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showRefreshBanner = false;
    self.cellSize = CGSizeZero;
    self.navigationItem.title = self.category.name;
    self.visibleIndexPaths = [NSMutableSet new];
    self.category.delegate = self;
    self.numberOfImages = self.category.images.count;
    self.loadingMore = self.category.maxNumberOfImages != self.numberOfImages;
    if (self.numberOfImages == 0) [self.category requestImageData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.category.lastUpdated isEqualToDate:[NSDate distantPast]]) {
        NSLog(@"!!!refreshing category because it is old or nil %@", self.category.name);
        [self refreshCategory:self];
        return;
    } else {
        NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self.category.lastUpdated toDate:[NSDate date] options:0] hour];
        if(hours >= 1) {
            self.showRefreshBanner = true;
        }
    }
//#warning for debugging only
//    self.showRefreshBanner = true;
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.category cancelThumbnailDownloads];
}

- (IBAction)refreshCategory:(id)sender {
    self.showRefreshBanner = false;
    self.numberOfImages = 0;
    [self.category resetImages];
}

- (IBAction)refreshAllCategories:(id)sender {
    NSManagedObjectContext *context = self.category.managedObjectContext;
    [context performBlock:^{
        NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntity:self.category.entity];
        request.propertiesToUpdate = @{ @"lastUpdated" : [NSDate distantPast] };
        request.resultType = NSUpdatedObjectIDsResultType;
        NSError *error;
        NSBatchUpdateResult *objectIDs = (NSBatchUpdateResult *)[context executeRequest:request error:&error];
        [objectIDs.result enumerateObjectsUsingBlock:^(NSManagedObjectID *objID, NSUInteger idx, BOOL *stop) {
            ASCategory *category = (ASCategory *)[context objectWithID:objID];
            if ([category isFault] == false) {
                [context refreshObject:category mergeChanges:YES];
            }
        }];
        if (error != nil) NSLog(@"error is %@", error);
        [self refreshCategory:self];
    }];
}

#pragma mark - UICollectionView DataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return self.showRefreshBanner ? CGSizeMake(collectionView.bounds.size.width, 40) : CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RefreshHeader" forIndexPath:indexPath];
        return headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        ASLoadingFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        footerView.loadingLabel.hidden = !self.loadingMore;
        return footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(self.collectionView.bounds.size.width, floor(self.collectionView.bounds.size.height/10));
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfImages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ASImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    ASImage *image = self.category.images[indexPath.item];
    if (image.thumbnail != nil) {
        cell.imageView.image = image.thumbnail;
        [cell.spinner stopAnimating];
    } else {
        [cell.spinner startAnimating];
        [image requestThumbnailImageIfNeeded];
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (CGSizeEqualToSize(self.cellSize, CGSizeZero) == true) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        NSUInteger numberOfCellsPerRow = screenSize.width > screenSize.height ? 5 : 3;
        CGFloat width = floor([[UIScreen mainScreen] bounds].size.width/numberOfCellsPerRow);
        self.cellSize = CGSizeMake(width, width);
    }

    return self.cellSize;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.cellSize = CGSizeZero;
        [self.collectionView reloadData];
    } completion:nil];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSMutableSet *newIndexPaths = [NSMutableSet setWithArray:[self.collectionView indexPathsForVisibleItems]];
    if ([self.visibleIndexPaths isEqualToSet:newIndexPaths] == false) {
        // Cancel requests for images that are no longer visible
        [self.visibleIndexPaths minusSet:newIndexPaths];
        for (NSIndexPath *indexPath in self.visibleIndexPaths) {
            ASImage *image = (ASImage *)self.category.images[indexPath.item];
#warning implement this using tasks instead
//            if (image.activeRequest != nil && image.thumbnail == nil) {
//                [image.activeRequest cancel];
//                NSLog(@"cancelling %@", image.name);
//            }
        }
        self.visibleIndexPaths = newIndexPaths;
        if (((NSIndexPath *)self.visibleIndexPaths.allObjects.lastObject).item + 50 >= self.category.images.count) [self.category requestImageData];
    }
}

#pragma mark - Category Image Delegate

- (void)imageThumbnailUpdated:(ASImage *)image {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.category.images indexOfObject:image] inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)numberOfImagesUpdatedTo:(NSUInteger)numberOfImages {
    NSLog(@"num of images updated to in VC: %@", @(numberOfImages));
    self.numberOfImages = numberOfImages;
    self.loadingMore = numberOfImages != self.category.maxNumberOfImages;
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(categoryImageWasSelected:)]) [self.delegate categoryImageWasSelected:self.category.images[indexPath.item]];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return ((ASImage *)self.category.images[indexPath.item]).thumbnail != nil;
}

@end
