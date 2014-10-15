//
//  AMBTableViewController.m
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

#import "AMBTableViewController.h"

@implementation AMBTableViewController
{
    NSMutableArray * _mutableSections;
    BOOL _useCustomAnimations;
    UITableViewRowAnimation _customReloadAnimation;
    UITableViewRowAnimation _customInsertAnimation;
    UITableViewRowAnimation _customRemoveAnimation;
}

@dynamic sections;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.reloadAnimation = UITableViewRowAnimationNone;
    self.insertAnimation = UITableViewRowAnimationAutomatic;
    self.removeAnimation = UITableViewRowAnimationFade;
}

- (NSString *)description
{
    return [[[[[NSString stringWithFormat:@"<%@: %p; sections: %@>", NSStringFromClass(self.class), self, self.sections]
               stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
              stringByReplacingOccurrencesOfString:@"    \\" withString:@"      "]
             stringByReplacingOccurrencesOfString:@">\\\"" withString:@">\""]
            stringByReplacingOccurrencesOfString:@"\n)>\"" withString:@"\n    )>\""];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
    tableView.dataSource = self;
    tableView.delegate = self;
}

#pragma mark - Managing sections

- (void)setSections:(NSArray *)sections
{
    _mutableSections = [NSMutableArray arrayWithArray:sections];
    for (AMBTableViewSection * section in sections)
    {
        section.controller = self;
    }
    [self updateAllSections];
    
    [self.tableView reloadData];
}

- (NSArray *)sections
{
    return _mutableSections;
}

- (void)insertSection:(AMBTableViewSection *)section
              atIndex:(NSUInteger)index
{
    NSAssert(index <= self.sections.count, @"Can't insert section at invalid index");
    
    [_mutableSections insertObject:section
                           atIndex:index];
    section.controller = self;
    [section update];
    
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:self.insertAnimation];
}

- (void)removeSection:(AMBTableViewSection *)section
{
    NSUInteger index = [self.sections indexOfObject:section];
    NSAssert(index != NSNotFound, @"Can't remove inexistent section");
    
    [self removeSectionAtIndex:index];
}

- (void)removeSectionAtIndex:(NSUInteger)index
{
    NSAssert(index < self.sections.count, @"Can't remove section at invalid index");
    
    [_mutableSections removeObjectAtIndex:index];
    
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:self.removeAnimation];
}

- (void)replaceSection:(AMBTableViewSection *)sectionToReplace
           withSection:(AMBTableViewSection *)section
{
    NSUInteger index = [self.sections indexOfObject:section];
    NSAssert(index != NSNotFound, @"Can't replace inexistent section");
    
    [self replaceSectionAtIndex:index
                    withSection:section];
}

- (void)replaceSectionAtIndex:(NSUInteger)index
                  withSection:(AMBTableViewSection *)section
{
    NSAssert(index < self.sections.count, @"Can't replace section at invalid index");
    
    [_mutableSections replaceObjectAtIndex:index
                                withObject:section];
    section.controller = self;
    
    [section reload];
}

#pragma mark - Configuring animations

- (UITableViewRowAnimation)reloadAnimation
{
    return _useCustomAnimations ? _customReloadAnimation : _reloadAnimation;
}

- (UITableViewRowAnimation)insertAnimation
{
    return _useCustomAnimations ? _customInsertAnimation : _insertAnimation;
}

- (UITableViewRowAnimation)removeAnimation
{
    return _useCustomAnimations ? _customRemoveAnimation : _removeAnimation;
}

- (void)applyChanges:(void (^)(void))changes
       withAnimation:(UITableViewRowAnimation)animation
{
    [self applyChanges:changes
   withReloadAnimation:animation
       insertAnimation:animation
       removeAnimation:animation];
}

- (void)applyChanges:(void (^)(void))changes
 withReloadAnimation:(UITableViewRowAnimation)reloadAnimation
     insertAnimation:(UITableViewRowAnimation)insertAnimation
     removeAnimation:(UITableViewRowAnimation)removeAnimation
{
    if (_useCustomAnimations)
    {
        // Override emdded calls
        changes();
    }
    else
    {
        _useCustomAnimations = YES;
        _customReloadAnimation = reloadAnimation;
        _customInsertAnimation = insertAnimation;
        _customRemoveAnimation = removeAnimation;
        
        changes();
        
        _useCustomAnimations = NO;
    }
}

#pragma mark - Convenience methods

- (void)updateAllSections
{
    for (AMBTableViewSection * section in self.sections)
    {
        [section update];
    }
}

- (void)combineChanges:(void (^)(void))changes
{
    [self.tableView beginUpdates];
    
    changes();
    
    [self.tableView endUpdates];
}

- (NSIndexPath *)indexPathForRowWithSubview:(UIView *)subview
{
    CGPoint point = [self.tableView convertPoint:subview.center
                                        fromView:subview.superview];
    return [self.tableView indexPathForRowAtPoint:point];
}

- (CGFloat)heightForResizableCellWithIdentifier:(NSString *)identifier
                                           text:(NSString *)text
                         limitedToNumberOfLines:(NSInteger)numberOfLines
{
    static NSMutableDictionary * cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      cache = [NSMutableDictionary dictionary];
                  });
    
    NSString * uniqueCellIdenfier = [NSString stringWithFormat:@"%@-%@", NSStringFromClass([self class]), identifier];
    NSDictionary * cachedValues = cache[uniqueCellIdenfier];
    CGFloat minimumHeight;
    CGSize sizeDifference;
    UIView * resizableView;
    
    if (!cachedValues)
    {
        UITableViewCell<AMBResizableCell> * cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        
        NSAssert([cell conformsToProtocol:@protocol(AMBResizableCell)], @"Cell doesn't conform to the AMBResizableCell protocol.");
        
        minimumHeight = cell.frame.size.height;
        resizableView = cell.resizableView;
        sizeDifference = cell.frame.size;
        sizeDifference.width -= resizableView.frame.size.width;
        sizeDifference.height -= resizableView.frame.size.height;
        
        NSAssert(resizableView, @"No resizableView set in cell");
        
        cachedValues = @{@"minimumHeight"  : @(minimumHeight),
                         @"sizeDifference" : [NSValue valueWithCGSize:sizeDifference],
                         @"resizableView"  : resizableView};
        cache[uniqueCellIdenfier] = cachedValues;
    }
    else
    {
        minimumHeight = ((NSNumber *)cachedValues[@"minimumHeight"]).floatValue;
        sizeDifference = ((NSNumber *)cachedValues[@"sizeDifference"]).CGSizeValue;
        resizableView = cachedValues[@"resizableView"];
    }
    
    CGFloat heightThatFits = 0.0;
    CGRect frame = CGRectMake(0.0,
                              0.0,
                              self.tableView.frame.size.width - sizeDifference.width,
                              CGFLOAT_MAX);
    if ([resizableView isKindOfClass:[UILabel class]])
    {
        UILabel * resizableLabel = (UILabel *)resizableView;
        resizableLabel.text = text;
        heightThatFits = [resizableLabel textRectForBounds:frame
                                    limitedToNumberOfLines:numberOfLines].size.height;
    }
    else if ([resizableView isKindOfClass:[UITextView class]])
    {
        UITextView * resizableTextView = (UITextView *)resizableView;
        resizableTextView.text = text;
        heightThatFits = [resizableTextView sizeThatFits:frame.size].height;
        // TODO: Adjust to numberOfLines
    }
    else
    {
        NSAssert(false, @"The provided resizableView class '%@' is not supported", NSStringFromClass([resizableView class]));
    }
    
    CGFloat cellSeparatorHeight = (self.tableView.separatorStyle == UITableViewCellSeparatorStyleNone) ? 0.0 : 1.0;
    return MAX(heightThatFits + sizeDifference.height + cellSeparatorHeight,
               minimumHeight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSAssert(self.tableView, @"Table view not yet set.");
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)sectionIndex
{
    AMBTableViewSection * section = self.sections[sectionIndex];
    NSUInteger numberOfRows = section.numberOfRows;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve the cell identifier
    AMBTableViewSection * section = self.sections[indexPath.section];
    id object = section.objects.count ? section.visibleObjects[indexPath.row] : nil;
    
    UITableViewCell * cell;
    
    // Already a cell?
    if ([object isKindOfClass:[UITableViewCell class]])
    {
        cell = object;
    }
    
    // Get a cell idenfier
    else
    {
        NSString * cellIdentifier;
        if ([object isKindOfClass:[AMBCellIdentifier class]])
        {
            cellIdentifier = ((AMBCellIdentifier *)object).string;
        }
        else if (section.cellIdentifierBlock)
        {
            cellIdentifier = section.cellIdentifierBlock(object,
                                                         indexPath);
        }
        NSAssert(cellIdentifier, @"No cell identifier found");
        
        // Dequeue a cell
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        NSAssert(cell, @"No cell could be dequeued with the given identifier.");
    }
    
    // Configure the cell
    if (section.cellConfigurationBlock)
    {
        section.cellConfigurationBlock(object,
                                       cell,
                                       indexPath);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMBTableViewSection * section = self.sections[indexPath.section];
    id object = section.objects.count ? section.visibleObjects[indexPath.row] : nil;
    if (section.cellHeightBlock)
    {
        CGFloat height = section.cellHeightBlock(object,
                                                 indexPath);
        return height < 0 ? self.tableView.rowHeight : height;
    }
    return self.tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)sectionIndex
{
    AMBTableViewSection * section = self.sections[sectionIndex];
    if (section.sectionTitleBlock) {
        return section.sectionTitleBlock(section);
    }
    return nil;
}

@end


@implementation AMBTableViewSection
{
    NSMutableArray * _mutableObjects;
    NSMutableIndexSet * _hiddenObjectsMutableIndexSet;
}

@dynamic objects;
@dynamic hiddenObjectsIndexSet;

+ (instancetype)sectionWithObjects:(NSArray *)objects
                sectionUpdateBlock:(AMBTableViewSectionUpdateBlock)sectionUpdateBlock
                   cellHeightBlock:(AMBTableViewCellHeightBlock)cellHeightBlock
               cellIdentifierBlock:(AMBTableViewCellIdentifierBlock)cellIdentifierBlock
            cellConfigurationBlock:(AMBTableViewCellConfigurationBlock)cellConfigurationBlock
{
    AMBTableViewSection * section = [self new];
    section.objects = objects;
    section.sectionUpdateBlock = sectionUpdateBlock;
    section.cellHeightBlock = cellHeightBlock;
    section.cellIdentifierBlock = cellIdentifierBlock;
    section.cellConfigurationBlock = cellConfigurationBlock;
    return section;
}

- (NSUInteger)numberOfRows
{
    return (self.hidden ? 0 :                                   // Hidden
            (self.objects.count ? self.visibleObjects.count :   // Not empty
             (self.presentsNoContentCell ? 1 :                  // Empty but presents a no content cell
              0)));                                             // Empty and doesn't present a no content cell
}

- (AMBTableViewController *)controller
{
    if (_controller)
    {
        // Make sure the section is still in the controller
        if (![_controller.sections containsObject:self])
        {
            _controller = nil;
        }
    }
    return _controller;
}

- (void)setHidden:(BOOL)hidden
{
    if (_hidden == hidden)
        return;
    
    _hidden = hidden;
    
    [self reload];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p%@%@; numberOfRows: %@%@; objects (%@): %@%@>",
            NSStringFromClass(self.class), self,
            self.controller ? [NSString stringWithFormat:@"; index: %@", @([self.controller.sections indexOfObject:self])] : @"",
            self.hidden ? @"; hidden: YES" : @"",
            @(self.numberOfRows),
            self.presentsNoContentCell ? @"; presentsNoContentCell: YES" : @"",
            @(self.objects.count), self.objects,
            self.hiddenObjectsIndexSet.count ? [NSString stringWithFormat:@"; hiddenObjectsIndexSet: %@", self.hiddenObjectsIndexSet] : @""];
}

#pragma mark - Managing objects

- (void)setObjects:(NSArray *)objects
{
    _mutableObjects = [NSMutableArray arrayWithArray:objects];
    _hiddenObjectsMutableIndexSet = [NSMutableIndexSet indexSet];
    [self updateVisibleObjects];
    
    // Reload section
    [self reload];
}

- (NSArray *)objects
{
    return _mutableObjects;
}

- (NSIndexSet *)hiddenObjectsIndexSet
{
    return _hiddenObjectsMutableIndexSet;
}

- (void)updateVisibleObjects
{
    NSMutableArray * visibleObjects = [NSMutableArray arrayWithArray:self.objects];
    [visibleObjects removeObjectsAtIndexes:self.hiddenObjectsIndexSet];
    _visibleObjects = visibleObjects;
}

- (void)addObject:(id)object
{
    [self insertObjects:@[object]
              atIndexes:[NSIndexSet indexSetWithIndex:self.objects.count]];
}

- (void)addObjects:(NSArray *)objects
{
    [self insertObjects:objects
              atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.objects.count,
                                                                           objects.count)]];
}

- (void)insertObject:(id)object
             atIndex:(NSUInteger)index
{
    [self insertObjects:@[object]
              atIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)insertObjects:(NSArray *)objects
            atIndexes:(NSIndexSet *)indexSet
{
    NSAssert(objects.count == indexSet.count, @"Trying to insert objects with an ummatching number of indexes");
    
    // Was empty? Prefer setObjects
    if (self.objects.count == 0)
    {
        self.objects = objects;
        return;
    }
    
    [_mutableObjects insertObjects:objects
                         atIndexes:indexSet];
    [self updateVisibleObjects];
    
    // Update table view
    [self insertRowsWithIndexes:[self rowIndexSetForVisibleObjectsInIndexSet:indexSet]];
}

- (void)removeObject:(id)object
{
    [self removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:[self.objects indexOfObject:object]]];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)removeObjects:(NSArray *)objects
{
    [self removeObjectsAtIndexes:[self indexSetForObjects:objects]];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexSet
{
    [_mutableObjects removeObjectsAtIndexes:indexSet];
    
    // Got empty? Prefer setObjects
    if (_mutableObjects.count == 0)
    {
        self.objects = nil;
        return;
    }
    
    [_hiddenObjectsMutableIndexSet removeIndexes:indexSet];
    [self updateVisibleObjects];
    
    // Update table view
    [self deleteRowsWithIndexes:[self rowIndexSetForVisibleObjectsInIndexSet:indexSet]];
}

- (void)moveObject:(id)object
           toIndex:(NSUInteger)index
{
    [self moveObjectAtIndex:[self.objects indexOfObject:object]
                    toIndex:index];
    
}

- (void)moveObjectAtIndex:(NSUInteger)oldIndex
                  toIndex:(NSUInteger)index
{
    id object = _mutableObjects[oldIndex];
    [_mutableObjects removeObjectAtIndex:oldIndex];
    [_mutableObjects insertObject:object
                          atIndex:index];
    
    if ([_hiddenObjectsMutableIndexSet containsIndex:oldIndex])
    {
        [_hiddenObjectsMutableIndexSet removeIndex:oldIndex];
        [_hiddenObjectsMutableIndexSet addIndex:index];
    }
    else
    {
        [self updateVisibleObjects];
    }
    
    if (!self.controller.tableView || self.hidden)
        return;
    
    NSUInteger sectionIndex = [self.controller.sections indexOfObject:self];
    [self.controller.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex
                                                                     inSection:sectionIndex]
                                      toIndexPath:[NSIndexPath indexPathForRow:index
                                                                     inSection:sectionIndex]];
}

- (BOOL)isObjectHidden:(id)object
{
    return [self isObjectAtIndexHidden:[self.objects indexOfObject:object]];
}

- (BOOL)isObjectAtIndexHidden:(NSUInteger)index
{
    return [self.hiddenObjectsIndexSet containsIndex:index];
}

- (void)setObject:(id)object
           hidden:(BOOL)hidden
{
    [self setObjectsAtIndexes:[NSIndexSet indexSetWithIndex:[self.objects indexOfObject:object]]
                       hidden:hidden];
}

- (void)setObjectAtIndex:(NSUInteger)index
                  hidden:(BOOL)hidden
{
    [self setObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]
                       hidden:hidden];
}

- (void)setObjects:(NSArray *)objects
            hidden:(BOOL)hidden
{
    [self setObjectsAtIndexes:[self indexSetForObjects:objects]
                       hidden:hidden];
}

- (void)setObjectsAtIndexes:(NSIndexSet *)indexSet
                     hidden:(BOOL)hidden
{
    if (hidden)
    {
        NSMutableIndexSet * newObjectIndexesToHide = [NSMutableIndexSet indexSet];
        [newObjectIndexesToHide addIndexes:indexSet];
        [newObjectIndexesToHide removeIndexes:self.hiddenObjectsIndexSet];
        
        if (newObjectIndexesToHide.count)
        {
            NSIndexSet * newRowIndexesToDelete = [self rowIndexSetForVisibleObjectsInIndexSet:newObjectIndexesToHide];
            
            [_hiddenObjectsMutableIndexSet addIndexes:newObjectIndexesToHide];
            [self updateVisibleObjects];
            
            [self deleteRowsWithIndexes:newRowIndexesToDelete];
        }
    }
    else
    {
        NSMutableIndexSet * newIndexesToShow = [NSMutableIndexSet indexSet];
        for (NSUInteger index = indexSet.lastIndex;
             index != NSNotFound;
             index = [indexSet indexLessThanIndex:index])
        {
            if ([self.hiddenObjectsIndexSet containsIndex:index])
                [newIndexesToShow addIndex:index];
        }
        
        if (newIndexesToShow.count)
        {
            [_hiddenObjectsMutableIndexSet removeIndexes:newIndexesToShow];
            [self updateVisibleObjects];
            
            NSIndexSet * newRowIndexesToInsert = [self rowIndexSetForVisibleObjectsInIndexSet:newIndexesToShow];
            [self insertRowsWithIndexes:newRowIndexesToInsert];
        }
    }
}

#pragma mark - Reloading Section and Objects

- (void)update
{
    if (self.sectionUpdateBlock)
    {
        self.sectionUpdateBlock(self);
    }
}

- (void)reload
{
    if (self.controller.tableView)
    {
        NSUInteger sectionIndex = [self.controller.sections indexOfObject:self];
        [self.controller.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                 withRowAnimation:self.controller.reloadAnimation];
    }
}

- (void)reloadObject:(id)object
{
    [self reloadObjectsAtIndexes:[NSIndexSet indexSetWithIndex:[self.objects indexOfObject:object]]];
}

- (void)reloadObjectAtIndex:(NSUInteger)index
{
    [self reloadObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)reloadObjects:(NSArray *)objects
{
    [self reloadObjectsAtIndexes:[self indexSetForObjects:objects]];
}

- (void)reloadObjectsAtIndexes:(NSIndexSet *)indexSet
{
    if (!self.controller.tableView || self.hidden)
        return;
    
    NSMutableIndexSet * visibleObjectIndexesToReload = [NSMutableIndexSet indexSet];
    [visibleObjectIndexesToReload addIndexes:indexSet];
    [visibleObjectIndexesToReload removeIndexes:self.hiddenObjectsIndexSet];
    
    if (visibleObjectIndexesToReload.count)
    {
        NSArray * pathsToReload = [self indexPathsForRowIndexes:[self rowIndexSetForVisibleObjectsInIndexSet:visibleObjectIndexesToReload]];
        [self.controller.tableView reloadRowsAtIndexPaths:pathsToReload
                                         withRowAnimation:self.controller.reloadAnimation];
    }
}

- (void)reloadOrHideObjectAtIndex:(NSUInteger)index
                             when:(BOOL)reloadWhenTrue
{
    if (reloadWhenTrue)
    {
        [self reloadObjectAtIndex:index];
        [self setObjectAtIndex:index
                        hidden:NO];
    }
    else
    {
        [self setObjectAtIndex:index
                        hidden:YES];
    }
}

#pragma mark - Scrolling to objects

- (void)scrollToObject:(id)object
      atScrollPosition:(UITableViewScrollPosition)scrollPosition
              animated:(BOOL)animated
{
    [self scrollToObjectAtIndex:[self.objects indexOfObject:object]
               atScrollPosition:scrollPosition
                       animated:animated];
}

- (void)scrollToObjectAtIndex:(NSUInteger)index
             atScrollPosition:(UITableViewScrollPosition)scrollPosition
                     animated:(BOOL)animated
{
    if (!self.controller.tableView || self.hidden)
        return;
    
    NSIndexSet * indexSet = [self rowIndexSetForVisibleObjectsInIndexSet:[NSIndexSet indexSetWithIndex:index]];
    if (indexSet.count == 1)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:indexSet.firstIndex
                                                     inSection:[self.controller.sections indexOfObject:self]];
        [self.controller.tableView scrollToRowAtIndexPath:indexPath
                                         atScrollPosition:scrollPosition
                                                 animated:animated];
    }
}

#pragma mark - Internal Methods

- (void)insertRowsWithIndexes:(NSIndexSet *)rowIndexSet
{
    if (!self.controller.tableView || self.hidden)
        return;
    
    NSArray * indexPaths = [self indexPathsForRowIndexes:rowIndexSet];
    [self.controller.tableView insertRowsAtIndexPaths:indexPaths
                                     withRowAnimation:self.controller.insertAnimation];
}

- (void)deleteRowsWithIndexes:(NSIndexSet *)rowIndexSet
{
    if (!self.controller.tableView || self.hidden)
        return;
    
    NSArray * indexPaths = [self indexPathsForRowIndexes:rowIndexSet];
    [self.controller.tableView deleteRowsAtIndexPaths:indexPaths
                                     withRowAnimation:self.controller.removeAnimation];
}

- (NSIndexSet *)indexSetForObjects:(NSArray *)objects
{
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    for (id object in objects)
    {
        [indexSet addIndex:[self.objects indexOfObject:object]];
    }
    return indexSet;
}

- (NSIndexSet *)rowIndexSetForVisibleObjectsInIndexSet:(NSIndexSet *)indexSet
{
    NSMutableIndexSet * rowIndexSet = [NSMutableIndexSet indexSet];
    NSUInteger countOfHiddenObjectsBelowIndex;
    for (NSUInteger index = indexSet.firstIndex;
         index != NSNotFound;
         index = [indexSet indexGreaterThanIndex:index])
    {
        countOfHiddenObjectsBelowIndex = [self.hiddenObjectsIndexSet countOfIndexesInRange:NSMakeRange(0, index)];
        [rowIndexSet addIndex:index - countOfHiddenObjectsBelowIndex];
    }
    return rowIndexSet;
}

- (NSArray *)indexPathsForRowIndexes:(NSIndexSet *)indexSet
{
    NSUInteger sectionIndex = [self.controller.sections indexOfObject:self];
    NSMutableArray * indexPaths = [NSMutableArray array];
    for (NSUInteger index = indexSet.firstIndex;
         index != NSNotFound;
         index = [indexSet indexGreaterThanIndex:index])
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index
                                                 inSection:sectionIndex]];
    }
    return indexPaths;
}

@end


@implementation AMBCellIdentifier

+ (instancetype)identifierFromString:(NSString *)string
{
    AMBCellIdentifier * identifier = [AMBCellIdentifier new];
    identifier.string = string;
    return identifier;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), self.string];
}

@end

