//
//  PECollectionViewController.m
//  TableDemo
//
//  Created by 利辺羅 on 2014/05/09.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PECollectionViewController.h"

@implementation PECollectionViewController
{
    NSMutableArray * _mutableSections;
}

@dynamic sections;

+ (NSString *)storyboardName
{
    return NSStringFromClass(self);
}

+ (NSString *)storyboardIdentifier
{
    return NSStringFromClass(self);
}

+ (UIStoryboard *)storyboard
{
    return [UIStoryboard storyboardWithName:self.storyboardName
                                     bundle:nil];
}

- (UIStoryboard *)storyboard
{
    return super.storyboard ?: [self class].storyboard;
}

+ (instancetype)controller
{
    return [self.storyboard instantiateViewControllerWithIdentifier:self.storyboardIdentifier];
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)sectionIndex
{
    PETableViewSection * section = self.sections[sectionIndex];
    return section.numberOfRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve the cell identifier
    PETableViewSection * section = self.sections[indexPath.section];
    id object = section.objects.count ? section.objects[indexPath.row] : nil;
    NSString * cellIdentifier;
    if (section.cellIdentifierBlock)
    {
        cellIdentifier = section.cellIdentifierBlock(object,
                                                     indexPath);
    }
    if (!cellIdentifier && [object isKindOfClass:[PECellIdentifier class]])
    {
        cellIdentifier = ((PECellIdentifier *)object).string;
    }
    NSAssert(cellIdentifier, @"No cell identifier found");
    
    // Dequeue a cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                            forIndexPath:indexPath];
    
    // Configure the cell
    if (section.configurationBlock)
    {
        section.configurationBlock(object,
                                   cell,
                                   indexPath);
    }
    
    return cell;
}

@end

