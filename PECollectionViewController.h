//
//  PECollectionViewController.h
//  TableDemo
//
//  Created by 利辺羅 on 2014/05/09.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PETableViewController.h"

@interface PECollectionViewController : UICollectionViewController

+ (instancetype)controller;

+ (NSString *)storyboardName;
+ (NSString *)storyboardIdentifier;
+ (UIStoryboard *)storyboard;

/// @name Managing Sections

@property (strong, nonatomic) NSArray * sections;

- (void)insertSection:(PETableViewSection *)section
              atIndex:(NSUInteger)index;

- (void)removeSection:(PETableViewSection *)section;
- (void)removeSectionAtIndex:(NSUInteger)index;

- (void)replaceSection:(PETableViewSection *)sectionToReplace
           withSection:(PETableViewSection *)section;
- (void)replaceSectionAtIndex:(NSUInteger)index
                  withSection:(PETableViewSection *)section;

@end

