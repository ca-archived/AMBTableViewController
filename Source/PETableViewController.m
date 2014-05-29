//
//  PETableViewController.m
//  pecolly
//
//  Created by 利辺羅 on 2014/05/07.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PETableViewController.h"

@implementation PETableViewController
{
    NSMutableArray * _mutableSections;
}

@dynamic sections;

- (NSString *)description
{
    return [[[[[NSString stringWithFormat:@"<%@: %p; sections: %@>", NSStringFromClass(self.class), self, self.sections]
               stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]
              stringByReplacingOccurrencesOfString:@"    \\" withString:@"      "]
             stringByReplacingOccurrencesOfString:@">\\\"" withString:@">\""]
            stringByReplacingOccurrencesOfString:@"\n)>\"" withString:@"\n    )>\""];
}

#pragma mark - Managing sections

- (void)setSections:(NSArray *)sections
{
    _mutableSections = [NSMutableArray arrayWithArray:sections];
    for (PETableViewSection * section in sections)
    {
        section.controller = self;
    }
    
    [self.tableView reloadData];
}

- (NSArray *)sections
{
    return _mutableSections;
}

- (void)insertSection:(PETableViewSection *)section
              atIndex:(NSUInteger)index
{
    NSAssert(index <= self.sections.count, @"Can't insert section at invalid index");
    
    [_mutableSections insertObject:section
                           atIndex:index];
    section.controller = self;
    
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeSection:(PETableViewSection *)section
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
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)replaceSection:(PETableViewSection *)sectionToReplace
           withSection:(PETableViewSection *)section
{
    NSUInteger index = [self.sections indexOfObject:section];
    NSAssert(index != NSNotFound, @"Can't replace inexistent section");
    
    [self replaceSectionAtIndex:index
                    withSection:section];
}

- (void)replaceSectionAtIndex:(NSUInteger)index
                  withSection:(PETableViewSection *)section
{
    NSAssert(index < self.sections.count, @"Can't replace section at invalid index");
    
    [_mutableSections replaceObjectAtIndex:index
                                withObject:section];
    section.controller = self;
    [section reload];
}

- (NSIndexPath *)indexPathForRowWithSubview:(UIView *)subview
{
    CGPoint point = [self.tableView convertPoint:subview.center
                                        fromView:subview.superview];
    return [self.tableView indexPathForRowAtPoint:point];
}

#pragma mark - Combining changes

- (void)combineChanges:(void (^)(void))changes
{
    if (self.tableView)
    {
        [self.tableView beginUpdates];
    }
    
    changes();
    
    if (self.tableView)
    {
        [self.tableView endUpdates];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)sectionIndex
{
    PETableViewSection * section = self.sections[sectionIndex];
    NSUInteger numberOfRows = section.numberOfRows;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve the cell identifier
    PETableViewSection * section = self.sections[indexPath.section];
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
        if ([object isKindOfClass:[PECellIdentifier class]])
        {
            cellIdentifier = ((PECellIdentifier *)object).string;
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
    if (section.configurationBlock)
    {
        section.configurationBlock(object,
                                   cell,
                                   indexPath);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PETableViewSection * section = self.sections[indexPath.section];
    id object = section.objects.count ? section.visibleObjects[indexPath.row] : nil;
    if (section.rowHeightBlock)
    {
        CGFloat height = section.rowHeightBlock(object,
                                                indexPath);
        return height < 0 ? self.tableView.rowHeight : height;
    }
    return self.tableView.rowHeight;
}

@end


@implementation PETableViewSection
{
    NSMutableArray * _mutableObjects;
    NSMutableIndexSet * _hiddenObjectsMutableIndexSet;
}

@dynamic objects;
@dynamic hiddenObjectsIndexSet;

+ (instancetype)sectionWithObjects:(NSArray *)objects
               cellIdentifierBlock:(PETableViewCellIdentifierBlock)cellIdentifierBlock
                    rowHeightBlock:(PETableViewCellHeightBlock)rowHeightBlock
                configurationBlock:(PETableViewCellConfigurationBlock)configurationBlock
{
    PETableViewSection * section = [PETableViewSection new];
    section.objects = objects;
    section.cellIdentifierBlock = cellIdentifierBlock;
    section.rowHeightBlock = rowHeightBlock;
    section.configurationBlock = configurationBlock;
    return section;
}

- (NSUInteger)numberOfRows
{
    return (self.hidden ? 0 :                                   // Hidden
            (self.objects.count ? self.visibleObjects.count :   // Not empty
             (self.presentsNoContentCell ? 1 :                  // Empty but presents a no content cell
              0)));                                             // Empty and doesn't present a no content cell
}

- (PETableViewController *)controller
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
    
    // Update table view
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
    if (self.objects.count == 0)
    {
        self.objects = nil;
        return;
    }
    
    [_hiddenObjectsMutableIndexSet removeIndexes:indexSet];
    [self updateVisibleObjects];
    
    // Update table view
    [self deleteRowsWithIndexes:[self rowIndexSetForVisibleObjectsInIndexSet:indexSet]];
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

- (void)reload
{
    if (self.controller)
    {
        NSUInteger sectionIndex = [self.controller.sections indexOfObject:self];
        [self.controller.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                 withRowAnimation:UITableViewRowAnimationNone];
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
    if (self.controller)
    {
        NSMutableIndexSet * visibleObjectIndexesToReload = [NSMutableIndexSet indexSet];
        [visibleObjectIndexesToReload addIndexes:indexSet];
        [visibleObjectIndexesToReload removeIndexes:self.hiddenObjectsIndexSet];
        
        if (visibleObjectIndexesToReload.count)
        {
            NSArray * pathsToReload = [self indexPathsForRowIndexes:[self rowIndexSetForVisibleObjectsInIndexSet:visibleObjectIndexesToReload]];
            [self.controller.tableView reloadRowsAtIndexPaths:pathsToReload
                                             withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - Internal Methods

- (void)insertRowsWithIndexes:(NSIndexSet *)rowIndexSet
{
    if (self.controller)
    {
        [self.controller.tableView insertRowsAtIndexPaths:[self indexPathsForRowIndexes:rowIndexSet]
                                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)deleteRowsWithIndexes:(NSIndexSet *)rowIndexSet
{
    if (self.controller)
    {
        [self.controller.tableView deleteRowsAtIndexPaths:[self indexPathsForRowIndexes:rowIndexSet]
                                         withRowAnimation:UITableViewRowAnimationFade];
    }
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


@implementation PECellIdentifier

+ (instancetype)identifierFromString:(NSString *)string
{
    PECellIdentifier * identifier = [PECellIdentifier new];
    identifier.string = string;
    return identifier;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), self.string];
}

@end

