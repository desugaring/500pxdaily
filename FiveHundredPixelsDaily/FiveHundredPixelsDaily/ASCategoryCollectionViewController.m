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

@end

@implementation ASCategoryCollectionViewController

static NSString * const reuseIdentifier = @"Thumbnail";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollViewOffset = 0;
    self.cellSize = CGSizeZero;
    self.navigationItem.title = self.category.name;
    self.category.delegate = self;
    self.numberOfImages = self.category.images.count;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.category addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.category cancelThumbnailDownloads];
    [self.category removeObserver:self forKeyPath:@"state"];
}

- (IBAction)refreshCategory:(id)sender {
    self.numberOfImages = 0;
    self.scrollViewOffset = 0;
    [self.category refreshImages];
}

- (IBAction)refreshAllCategories:(id)sender {
    // Turn all categories stale
    NSManagedObjectContext *context = self.category.managedObjectContext;
    [context performBlockAndWait:^{
        NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntity:self.category.entity];
        request.propertiesToUpdate = @{ @"state" : @(ASCategoryStateRefreshImmediately) };
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
        if (error != nil) NSLog(@"error is %@", error);
    }];
//    [self refreshCategory:self];
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
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RefreshHeader" forIndexPath:indexPath];
        return headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        ASLoadingFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        footerView.loadingLabel.hidden = (self.numberOfImages == self.category.maxNumberOfImages.unsignedIntegerValue);
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
        self.scrollViewOffset = newOffset;
        if ((self.scrollViewOffset/scrollView.contentSize.height)*100 >= 60) [self.category requestImageData];
    }
}

#pragma mark - Category Image Delegate

- (void)imageThumbnailUpdated:(ASImage *)image {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.category.images indexOfObject:image] inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)numberOfImagesUpdatedTo:(NSUInteger)numberOfImages {
    NSLog(@"num of images updated to in VC: %@, images number: %@", @(numberOfImages), @(self.category.images.count));
    self.numberOfImages = numberOfImages;
    [self.collectionView reloadData];
    NSLog(@"reloading from number change");
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(categoryImageWasSelected:)]) [self.delegate categoryImageWasSelected:self.category.images[indexPath.item]];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return ((ASImage *)self.category.images[indexPath.item]).thumbnail != nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        NSNumber *state = ((ASCategory *)object).state;
        NSLog(@"new state for category %@: %@", self.category.name, state);
        if (state.integerValue == ASCategoryStateRefreshImmediately) {
            [self.category refreshImages];
        } else {
            NSLog(@"reloading from state change");
            [self.collectionView reloadData];
        }
    }
}

@end
