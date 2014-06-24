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

- (void)updateAllSections;

- (NSIndexPath *)indexPathForRowWithSubview:(UIView *)subview;

/// @name Combining Multiple Section/Row Changes

- (void)combineChanges:(void (^)(void))changes;

/// @name Convenience Methods

- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier
                                  text:(NSString *)text
                limitedToNumberOfLines:(NSInteger)numberOfLines;

@end


@protocol PEResizableCell <NSObject>

@property (weak, nonatomic) IBOutlet UILabel * resizableLabel;

@end


typedef void       (^PETableViewSectionUpdateBlock)    (PETableViewSection * section);
typedef CGFloat    (^PETableViewCellHeightBlock)       (id object,
                                                        NSIndexPath * indexPath);
typedef NSString * (^PETableViewCellIdentifierBlock)   (id object,
                                                        NSIndexPath * indexPath);
typedef void       (^PETableViewCellConfigurationBlock)(id object,
                                                        UITableViewCell * cell,
                                                        NSIndexPath * indexPath);

@interface PETableViewSection : NSObject

+ (instancetype)sectionWithObjects:(NSArray *)objects
                sectionUpdateBlock:(PETableViewSectionUpdateBlock)sectionUpdateBlock
                   cellHeightBlock:(PETableViewCellHeightBlock)cellHeightBlock
               cellIdentifierBlock:(PETableViewCellIdentifierBlock)cellIdentifierBlock
                configurationBlock:(PETableViewCellConfigurationBlock)configurationBlock;

/// @name Properties

@property(nonatomic, getter=isHidden)   BOOL hidden;
@property(nonatomic)                    BOOL presentsNoContentCell;

@property (nonatomic, readonly)         NSUInteger numberOfRows;

@property (weak, nonatomic)             PETableViewController * controller;
@property (copy, nonatomic)             PETableViewSectionUpdateBlock sectionUpdateBlock;
@property (copy, nonatomic)             PETableViewCellHeightBlock cellHeightBlock;
@property (copy, nonatomic)             PETableViewCellIdentifierBlock cellIdentifierBlock;
@property (copy, nonatomic)             PETableViewCellConfigurationBlock configurationBlock;

/// @name Update and Reload Section and Objects

- (void)update;
- (void)reload;

- (void)reloadObject:(id)object;
- (void)reloadObjectAtIndex:(NSUInteger)index;

- (void)reloadObjects:(NSArray *)objects;
- (void)reloadObjectsAtIndexes:(NSIndexSet *)indexSet;

/// @name Managing Objects

@property (strong, nonatomic)           NSArray * objects;
@property (strong, nonatomic, readonly) NSArray * visibleObjects;
@property (strong, nonatomic, readonly) NSIndexSet * hiddenObjectsIndexSet;

- (void)addObject:(id)object;
- (void)addObjects:(NSArray *)objects;

- (void)insertObject:(id)object
             atIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)objects
            atIndexes:(NSIndexSet *)indexSet;

- (void)removeObject:(id)object;
- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)removeObjects:(NSArray *)objects;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexSet;

- (BOOL)isObjectHidden:(id)object;
- (BOOL)isObjectAtIndexHidden:(NSUInteger)index;

- (void)setObject:(id)object
           hidden:(BOOL)hidden;
- (void)setObjectAtIndex:(NSUInteger)index
                  hidden:(BOOL)hidden;

- (void)setObjects:(NSArray *)objects
            hidden:(BOOL)hidden;
- (void)setObjectsAtIndexes:(NSIndexSet *)indexSet
                     hidden:(BOOL)hidden;

@end


@interface PECellIdentifier : NSObject

+ (instancetype)identifierFromString:(NSString *)string;

@property (strong, nonatomic) NSString * string;

@end

