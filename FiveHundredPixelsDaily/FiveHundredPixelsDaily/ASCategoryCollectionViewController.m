//
//  ASCategoryCollectionViewController.m
//  FiveHundredPixelsDaily
//
//  Created by Alex Semenikhine on 2015-04-09.
//  Copyright (c) 2015 Alex Semenikhine. All rights reserved.
//

#import "ASCategoryCollectionViewController.h"
#import "ASImageCollectionViewCell.h"
#import "ASCategory.h"
#import "ASImage.h"
#import "ASLoadingFooterCollectionReusableView.h"

@interface ASCategoryCollectionViewController() <UICollectionViewDelegateFlowLayout>

@property NSUInteger numberOfImages;
@property CGSize cellSize;
@property CGFloat scrollViewOffset;
@property NSTimer *stalenessTimer;

@end

@implementation ASCategoryCollectionViewController

static NSString * const reuseIdentifier = @"Thumbnail";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.category.delegate = self;
    self.scrollViewOffset = 0;
    self.cellSize = CGSizeZero;
    self.navigationItem.title = self.category.name;
    self.numberOfImages = 0; // Gets altered via state attribute changes caught via KVO
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.stalenessTimer = [NSTimer timerWithTimeInterval:30*60 target:self.category selector:@selector(refreshState) userInfo:nil repeats:true];
    [self.category refreshState];
    [self.category addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.category cancelThumbnailDownloads];
    [self.stalenessTimer invalidate];
    [self.category removeObserver:self forKeyPath:@"state"];
}

- (IBAction)refreshCategory:(id)sender {
    self.scrollViewOffset = 0;
    [self.category refreshImages];
}

- (IBAction)refreshAllCategories:(id)sender {
    // Refresh current categories
    [self refreshCategory:self];
    // Turn all other categories state to 'refresh immediately'
    NSManagedObjectContext *context = self.category.managedObjectContext;
    [context performBlock:^{
        NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntity:self.category.entity];
        request.propertiesToUpdate = @{ @"state" : @(ASCategoryStateRefreshImmediately) };
        request.predicate = [NSPredicate predicateWithFormat:@"name != %@" argumentArray:@[self.category.name]];
        request.resultType = NSUpdatedObjectIDsResultType;
        NSError *error;
        NSBatchUpdateResult *objectIDs = (NSBatchUpdateResult *)[context executeRequest:request error:&error];
        // Apply changes to objects in memory by merging them with the updated data in the context
        [objectIDs.result enumerateObjectsUsingBlock:^(NSManagedObjectID *objID, NSUInteger idx, BOOL *stop) {
            ASCategory *category = (ASCategory *)[context objectWithID:objID];
            if ([category isFault] == false) {
                [context refreshObject:category mergeChanges:YES];
            }
        }];
        if (error != nil) NSLog(@"batch update error is %@", error);
    }];
}

#pragma mark - UICollectionView DataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return (self.category.state.integerValue == ASCategoryStateStale) ? CGSizeMake(collectionView.bounds.size.width, 70) : CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(self.collectionView.bounds.size.width, floor(self.collectionView.bounds.size.height/10));
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        if (self.category.state.integerValue == ASCategoryStateStale) {
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RefreshHeader" forIndexPath:indexPath];
            return headerView;
        }
    } else if (kind == UICollectionElementKindSectionFooter) {
        ASLoadingFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        footerView.loadingLabel.hidden = (self.category.state.integerValue == ASCategoryStateBusyGettingImages || self.category.state.integerValue == ASCategoryStateBusyRefreshing) == false;
        return footerView;
    }
    return nil;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat newOffset = scrollView.contentOffset.y+scrollView.bounds.size.height;
    if (newOffset - self.scrollViewOffset > 150) {
        BOOL imagesRequested = false;
        if ((newOffset/scrollView.contentSize.height)*100 >= 60) imagesRequested = [self.category requestImageData];
        if (imagesRequested) self.scrollViewOffset = newOffset;
    }
}

#pragma mark - Category Image Delegate

- (void)imageThumbnailUpdated:(ASImage *)image {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.category.images indexOfObject:image] inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(categoryImageWasSelected:)]) [self.delegate categoryImageWasSelected:self.category.images[indexPath.item]];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return ((ASImage *)self.category.images[indexPath.item]).thumbnail != nil;
}

#pragma mark - Category State Change

- (void)categoryStateChanged {
    switch (self.category.state.integerValue) {
        case ASCategoryStateRefreshImmediately: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCategory:self];
            });
            break;
        }
        case ASCategoryStateStale: {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.numberOfImages = self.category.images.count;
                [self.collectionView reloadData];
            });
            break;
        }
        case ASCategoryStateBusyRefreshing: {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.numberOfImages = 0;
                [self.collectionView reloadData];
            });
            break;
        }
        case ASCategoryStateBusyGettingImages: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            break;
        }
        case ASCategoryStateFree: {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.numberOfImages = self.category.images.count;
                [self.collectionView reloadData];
            });
            break;
        }
        case ASCategoryStateUpToDate: {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.numberOfImages = self.category.images.count;
                [self.collectionView reloadData];
            });
            break;
        }
        default:
            break;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        [self categoryStateChanged];
    }
}

@end
