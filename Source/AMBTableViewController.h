//
//  AMBTableViewController.h
//  AMBTableViewController
//
//  Created by Ernesto Rivera on 2014/05/07.
//  Copyright (c) 2014 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>
@class AMBTableViewSection;

/**
 A controller that manages a UITableView using AMBTableViewSection to be configured.
 
 - Based on Storyboards and Prototype Cells.
 - Modularizes section code.
 - Uses blocks instead of delegate methods.
 - Avoids having section code separated through multiple methods.
 - Sections and individual rows can be hidden/shown, added/removed.
 - Support for dynamic height cells.
 */
@interface AMBTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/// @name Properties

/// The managed table view.
@property (weak, nonatomic) IBOutlet UITableView * tableView;

/// The presented sections.
@property (strong, nonatomic) NSArray * sections;

/// @name Managing Sections

/// Insert a section into the sections array.
/// @param section The section to be inserted.
/// @param index The index to insert the section at.
- (void)insertSection:(AMBTableViewSection *)section
              atIndex:(NSUInteger)index;

/// Remove a section.
/// @param section The section to be removed.
- (void)removeSection:(AMBTableViewSection *)section;

/// Remove the section at a given index.
/// @param index The index of the section to be removed.
- (void)removeSectionAtIndex:(NSUInteger)index;

/// Replace a section for another one.
/// @param sectionToReplace The section to be replaced.
/// @param section The replacing section.
- (void)replaceSection:(AMBTableViewSection *)sectionToReplace
           withSection:(AMBTableViewSection *)section;

/// Replace a section at a given index for another one.
/// @param index The index of the section to be replaced.
/// @param section The replacing section.
- (void)replaceSectionAtIndex:(NSUInteger)index
                  withSection:(AMBTableViewSection *)section;

/// @name Configuring Animations

/// Reload section/row animation. By default `UITableViewRowAnimationNone`.
@property (nonatomic) UITableViewRowAnimation reloadAnimation;

/// Insert section/row animation. By default `UITableViewRowAnimationAutomatic`.
@property (nonatomic) UITableViewRowAnimation insertAnimation;

/// Insert section/row animation. By default `UITableViewRowAnimationFade`.
@property (nonatomic) UITableViewRowAnimation removeAnimation;

/// Execute a block while temporarily overriding reload, insert and remove animations.
/// @param changes The block to be executed.
/// @param animation The animation to be used while executing the changes.
- (void)applyChanges:(void (^)(void))changes
       withAnimation:(UITableViewRowAnimation)animation;

/// Execute a block while temporarily overriding reload, insert and remove animations.
/// @param changes The block to be executed.
/// @param reloadAnimation The animation to be used while reloading sections/rows.
/// @param insertAnimation The animation to be used while inserting sections/rows.
/// @param removeAnimation The animation to be used while removing sections/rows.
- (void)applyChanges:(void (^)(void))changes
 withReloadAnimation:(UITableViewRowAnimation)reloadAnimation
     insertAnimation:(UITableViewRowAnimation)insertAnimation
     removeAnimation:(UITableViewRowAnimation)removeAnimation;

/// @name Convenience Methods

/// Trigger [AMBTableViewSection update] on all sections.
- (void)updateAllSections;

/// Combine several section and row changes between [UITableView beginUpdates] and
/// [UITableView endUpdates].
/// @param changes The changes to be combined.
- (void)combineChanges:(void (^)(void))changes;

/// Retrieve the index path of the row containing a given subview.
/// @param subview A subview of the row.
- (NSIndexPath *)indexPathForRowWithSubview:(UIView *)subview;

/// Calculate the required height for a dynamic height label.
/// @param identifier The identifier of the AMBResizableCell who's height will be calculated.
/// @param text The text that the [AMBResizableCell resizableLabel] should fit.
/// @param numberOfLines The maximum number of lines to be used by the label or `0` for no limits.
/// @discussion A cell instance of the given identifier will be cached to calculate the heights
/// of all future calculations. The original height of the loaded cell will be used as the
/// minimum height to be returned by the function.
- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier
                                  text:(NSString *)text
                limitedToNumberOfLines:(NSInteger)numberOfLines;

@end


/// @name  AMBTableViewSection Blocks

/// A block used to return the name of the section.
/// @param section The section that whose title to return.
/// @return String to be used for the title of the section
typedef NSString * (^AMBTableViewSectionTitleBlock)(AMBTableViewSection * section);

/// A block where any aspect of the section can be changed and rows can set to be shown/hidden,
/// reloaded, etc.
/// @param The section to be updated.
typedef void (^AMBTableViewSectionUpdateBlock) (AMBTableViewSection * section);

/// Calculate the height of the cell corresponding to a given section object.
/// @param object The object who's corresponing cell needs to be calculated.
/// @param indexPath The index path of the corresponding cell.
/// @return The desired height. When there is no [AMBTableViewSection cellHeightBlock] or the
/// block returns a negative height the default [UITableView rowHeight] is used.
typedef CGFloat (^AMBTableViewCellHeightBlock) (id object,
                                                NSIndexPath * indexPath);

/// The Prototype Cell identifier that should be loaded for a given object.
/// @param object The object who's corresponing cell needs to be calculated.
/// @param indexPath The index path of the corresponding cell.
/// @return A Prototype Cell identifier.
/// @discussion Depending on the kind of object this method may never be called.
/// @see [AMBTableViewSection objects].
typedef NSString * (^AMBTableViewCellIdentifierBlock) (id object,
                                                       NSIndexPath * indexPath);

/// A block used to configure a cell for a given object and index path.
/// @param object The object who's corresponing cell will be configured.
/// @param cell The cell to be configured.
/// @param indexPath The index path of the corresponding cell.
typedef void (^AMBTableViewCellConfigurationBlock)(id object,
                                                   UITableViewCell * cell,
                                                   NSIndexPath * indexPath);


/**
 An object that groups blocks of code to manage rows in a table view section.
 
 Sections use an abstract list of objects to be managed.
 
 - An object corresponds to a cell when it is not set to hidden.
 - A non-hidden object gets a cell loaded by a given identifier unless the object is
 already a UITableViewCell.
 - If the object is a AMBCellIdentifier then cellIdentifierBlock is skipped for that cell.
 - When presentsNoContentCell is set to `YES` all blocks are called with a `nil` object.
 - Hidding/showing/inserting/removing objects automatically updates the corresponding table cells.
 
 A section can be set to hidden, in which case it ignores its objects and returns `0` as its numberOfRows.
 */
@interface AMBTableViewSection : NSObject

/// @name Creating Sections

/// Create and return a new section.
/// @param objects An abstract list of objects to be presented by the section.
/// @param sectionUpdateBlock An optinal block to be called on update on
/// [AMBTableViewController updateAllSections] calls.
/// @param cellHeightBlock An optional block to be called on [UITableView tableView:heightForRowAtIndexPath:].
/// @param cellIdentifierBlock The block to be called when a cell needs to be loaded.
/// @param cellConfigurationBlock An optional block to be called to configure a loaded or reused cell.
+ (instancetype)sectionWithObjects:(NSArray *)objects
                sectionUpdateBlock:(AMBTableViewSectionUpdateBlock)sectionUpdateBlock
                   cellHeightBlock:(AMBTableViewCellHeightBlock)cellHeightBlock
               cellIdentifierBlock:(AMBTableViewCellIdentifierBlock)cellIdentifierBlock
            cellConfigurationBlock:(AMBTableViewCellConfigurationBlock)cellConfigurationBlock;

/// @name Properties

/// Whether the section should be hidden or not. Default `NO`.
/// @discussion When set to `YES` the numberOfRows returns `0`.
@property(nonatomic, getter=isHidden)   BOOL hidden;

/// Whether the section should present a special "No Content" cell when objects is empty. Default `NO`.
/// @discussion When set to `YES` the numberOfRows returns `1` and cellHeightBlock, cellIdentifierBlock and
/// cellConfigurationBlock will all be called with an `nil` object.
@property(nonatomic)                    BOOL presentsNoContentCell;

/// The number of rows that the section returns to [UITableView tableView:numberOfRowsInSection:].
@property (nonatomic, readonly)         NSUInteger numberOfRows;

/// The AMBTableViewController assigned when the section is added to [AMBTableViewController sections].
@property (weak, nonatomic)             AMBTableViewController * controller;

/// An optional block to be called on [UITableView tableView:titleForHeaderInSection:].
@property (copy, nonatomic)             AMBTableViewSectionTitleBlock sectionTitleBlock;

/// An optinal block to be called on update on [AMBTableViewController updateAllSections] calls.
@property (copy, nonatomic)             AMBTableViewSectionUpdateBlock sectionUpdateBlock;

/// An optional block to be called on [UITableView tableView:heightForRowAtIndexPath:].
@property (copy, nonatomic)             AMBTableViewCellHeightBlock cellHeightBlock;

/// The block to be called when a cell needs to be loaded.
@property (copy, nonatomic)             AMBTableViewCellIdentifierBlock cellIdentifierBlock;

/// An optional block to be called to configure a loaded or reused cell.
@property (copy, nonatomic)             AMBTableViewCellConfigurationBlock cellConfigurationBlock;

/// @name Managing Objects

/// The list of objects that the section handles.
@property (strong, nonatomic)           NSArray * objects;

/// The list of non-hidden objects. That is objects that have a corresping cell.
@property (strong, nonatomic, readonly) NSArray * visibleObjects;

/// An index set of all the currently hidden objects.
@property (strong, nonatomic, readonly) NSIndexSet * hiddenObjectsIndexSet;

/// @name Adding and Removing Objects

/// Add an object to objects.
/// @param object The object to be added.
- (void)addObject:(id)object;

/// Add some new objects to appended to the section objects.
/// @param objects The objects to be added.
- (void)addObjects:(NSArray *)objects;

/// Insert an object at a given index.
/// @param object The object to be inserted.
/// @param index The index where the object should be inserted.
- (void)insertObject:(id)object
             atIndex:(NSUInteger)index;

/// Insert new objects at some given indexes.
/// @param objects The object to be inserted.
/// @param indexSet The indexes where the objects should be inserted.
- (void)insertObjects:(NSArray *)objects
            atIndexes:(NSIndexSet *)indexSet;

/// Remove an object.
/// @param object The object to be removed.
- (void)removeObject:(id)object;

/// Remove an object at a given index.
/// @param index The index of the object to be removed.
- (void)removeObjectAtIndex:(NSUInteger)index;

/// Remove several objects.
/// @param objects The objects to be removed.
- (void)removeObjects:(NSArray *)objects;

/// Remove several objects at the given indexes.
/// @param indexSet The indexes of the objects to be removed.
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexSet;

/// @name Moving Objects

/// Move an object to a given index.
/// @param object The object to move.
/// @param index The index to move the object to.
- (void)moveObject:(id)object
           toIndex:(NSUInteger)index;

/// Move an object from a given index to a new one.
/// @param oldIndex The original object index.
/// @param index The index to move the object to.
- (void)moveObjectAtIndex:(NSUInteger)oldIndex
                  toIndex:(NSUInteger)index;

/// @name Hiding and Showing Objects

/// Whether an object is hidden.
/// @param object The subject object.
- (BOOL)isObjectHidden:(id)object;

/// Whether an object at a given index is hidden.
/// @param index The subject object index.
- (BOOL)isObjectAtIndexHidden:(NSUInteger)index;

/// Hide/show an object corresponding cell.
/// @param object The object to be hidden/shown.
/// @param hidden Whether to show or hide the object.
- (void)setObject:(id)object
           hidden:(BOOL)hidden;

/// Hide/show an object at a given index.
/// @param index The index f the object to be hidden/shown.
/// @param hidden Whether to show or hide the object.
- (void)setObjectAtIndex:(NSUInteger)index
                  hidden:(BOOL)hidden;

/// Hide/show several objects.
/// @param objects The objects to be hidden/shown.
/// @param hidden Whether to show or hide the objects.
- (void)setObjects:(NSArray *)objects
            hidden:(BOOL)hidden;

/// Hide/show several objects at given indexes.
/// @param indexSet The indexes of the object to be hidden/shown.
/// @param hidden Whether to show or hide the objects.
- (void)setObjectsAtIndexes:(NSIndexSet *)indexSet
                     hidden:(BOOL)hidden;

/// @name Update and Reload the Section

/// Update the section by calling its sectionUpdateBlock.
- (void)update;

/// Force the table view to fully reload the section.
/// @note Prefer setting sectionUpdateBlock and calling update when possible.
- (void)reload;

/// @name Update and Reload Specific Objects

/// Reload a given object's cell.
/// @param object The object who's cell should be reloaded.
- (void)reloadObject:(id)object;

/// Reload an object at a given index.
/// @param index The index object to be reloaded.
- (void)reloadObjectAtIndex:(NSUInteger)index;

/// Reload several objects.
/// @param objects The objects to be reloaded.
- (void)reloadObjects:(NSArray *)objects;

/// Reload several objects at given indexes.
/// @param indexSet The indexes of the objects to be reloaded.
- (void)reloadObjectsAtIndexes:(NSIndexSet *)indexSet;

/// Convenience method to either show and reload, or hide an object
/// depending on the evaluation of a condition.
/// @param index The index object to be shown/hidden.
/// @param reloadWhenTrue A condition that determines what to do with the object.
- (void)reloadOrHideObjectAtIndex:(NSUInteger)index
                             when:(BOOL)reloadWhenTrue;

/// @name Scrolling to Objects

/// Scroll to a given object.
/// @param object The object to be scrolled to.
/// @param scrollPosition The position to be scrolled to.
/// @param animated Whether to animate the scrolling.
- (void)scrollToObject:(id)object
      atScrollPosition:(UITableViewScrollPosition)scrollPosition
              animated:(BOOL)animated;

/// Scroll to an object at a given index.
/// @param index The index of the object to be scrolled to.
/// @param scrollPosition The position to be scrolled to.
/// @param animated Whether to animate the scrolling.
- (void)scrollToObjectAtIndex:(NSUInteger)index
             atScrollPosition:(UITableViewScrollPosition)scrollPosition
                     animated:(BOOL)animated;

@end


/**
 An object that can be used to populate a [AMBTableViewSection objects] while
 directly specifying the cell to be loaded.
 
 Useful for cells that require little or no configuration besides being loaded.
 */
@interface AMBCellIdentifier : NSObject

/// Create and return a new object.
/// @param string An existing Prototype Cell identifier.
+ (instancetype)identifierFromString:(NSString *)string;

/// The Prototype Cell identifier to be loaded.
@property (strong, nonatomic) NSString * string;

@end


/**
 A protocol that when implemented by a UITableViewCell enables using
 [AMBTableViewController heightForCellWithIdentifier:text:limitedToNumberOfLines:]
 to easily calculate dynamic-sized cells.
 */
@protocol AMBResizableCell <NSObject>

/// The label that determines the required height of the cell.
/// @discussion The original cell height is saved and used as the minimum height to used
/// for the cell.
/// @note The label should be set to use flexible height and automatically grow/shrink
/// when its parent cell changes adjusts its height.
@property (weak, nonatomic) IBOutlet UILabel * resizableLabel;

@end

