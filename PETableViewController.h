//
//  PETableViewController.h
//  pecolly
//
//  Created by 利辺羅 on 2014/05/07.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PETableViewSection;

@interface PETableViewController : UITableViewController

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


typedef CGFloat     (^PETableViewCellHeightBlock)       (id object,
                                                         NSIndexPath * indexPath);
typedef NSString *  (^PETableViewCellIdentifierBlock)   (id object,
                                                         NSIndexPath * indexPath);
typedef void        (^PETableViewCellConfigurationBlock)(id object,
                                                         UITableViewCell * cell,
                                                         NSIndexPath * indexPath);

@interface PETableViewSection : NSObject

+ (instancetype)sectionWithObjects:(NSArray *)objects
               cellIdentifierBlock:(PETableViewCellIdentifierBlock)cellIdentifierBlock
                    rowHeightBlock:(PETableViewCellHeightBlock)rowHeightBlock
                configurationBlock:(PETableViewCellConfigurationBlock)configurationBlock;

/// @name Properties

@property(nonatomic, getter=isHidden)   BOOL hidden;
@property(nonatomic)                    BOOL presentsNoContentsCell;

@property (nonatomic, readonly)         NSUInteger numberOfRows;
@property (copy, nonatomic, readonly)   PETableViewCellHeightBlock rowHeightBlock;
@property (copy, nonatomic, readonly)   PETableViewCellIdentifierBlock cellIdentifierBlock;
@property (copy, nonatomic, readonly)   PETableViewCellConfigurationBlock configurationBlock;
@property (weak, nonatomic, readonly)   PETableViewController * controller;

/// @name Managing Objects

@property (strong, nonatomic)           NSArray * objects;

- (void)insertObject:(id)object
             atIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)objects
            atIndexes:(NSIndexSet *)indexSet;

- (void)removeObject:(id)object;
- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)removeObjects:(NSArray *)objects;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexSet;

@end


@interface PECellIdentifier : NSObject

+ (instancetype)identifierFromString:(NSString *)string;

@property (strong, nonatomic) NSString * string;

@end

