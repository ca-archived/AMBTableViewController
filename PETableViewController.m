//
//  PETableViewController.m
//  pecolly
//
//  Created by 利辺羅 on 2014/05/07.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PETableViewController.h"

// Private properties
@interface PETableViewSection ()

@property (weak, nonatomic)   PETableViewController * controller;
@property (copy, nonatomic)   PETableViewCellHeightBlock rowHeightBlock;
@property (copy, nonatomic)   PETableViewCellIdentifierBlock cellIdentifierBlock;
@property (copy, nonatomic)   PETableViewCellConfigurationBlock configurationBlock;

@end


@implementation PETableViewController
{
    NSMutableArray * _mutableSections;
}

@dynamic sections;

- (NSString *)description
{
    return [[[[[NSString stringWithFormat:@"<%@: %p sections: %@>", NSStringFromClass(self.class), self, self.sections]
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
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return section.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
    id object = section.objects.count ? section.objects[indexPath.row] : nil;
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
}

@dynamic objects;

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
    return (self.hidden ? 0 :                           // Hidden?
            (self.objects.count ?:                      // Not empty?
             (self.presentsNoContentsCell ? 1 : 0)));   // Empty but presents no contents cell?
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
    
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p%@%@ numberOfRows: %@%@ objects: %@>",
            NSStringFromClass(self.class), self,
            self.controller ? [NSString stringWithFormat:@" index : %@", @([self.controller.sections indexOfObject:self])] : @"",
            self.hidden ? @" hidden: YES" : @"",
            @(self.numberOfRows),
            self.presentsNoContentsCell ? @" presentsNoContentsCell: YES" : @"",
            self.objects];
}

#pragma mark - Managing objects

- (void)setObjects:(NSArray *)objects
{
    _mutableObjects = [NSMutableArray arrayWithArray:objects];
    
    // Update table view
    if (self.controller)
    {
        NSUInteger sectionIndex = [self.controller.sections indexOfObject:self];
        [self.controller.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSArray *)objects
{
    return _mutableObjects;
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
    
    // Update table view
    if (self.controller)
    {
        NSMutableArray * indexPaths = [NSMutableArray array];
        NSUInteger sectionIndex = [self.controller.sections indexOfObject:self];
        for (NSUInteger index = indexSet.firstIndex;
             index != NSNotFound;
             index = [indexSet indexGreaterThanIndex:index])
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index
                                                     inSection:sectionIndex]];
        }
        [self.controller.tableView insertRowsAtIndexPaths:indexPaths
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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
    NSMutableIndexSet * indexSet = [NSMutableIndexSet indexSet];
    for (id object in objects)
    {
        [indexSet addIndex:[self.objects indexOfObject:object]];
    }
    [self removeObjectsAtIndexes:indexSet];
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
    
    // Update table view
    if (self.controller)
    {
        NSMutableArray * indexPaths = [NSMutableArray array];
        NSUInteger sectionIndex = [self.controller.sections indexOfObject:self];
        for (NSUInteger index = indexSet.firstIndex;
             index != NSNotFound;
             index = [indexSet indexGreaterThanIndex:index])
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index
                                                     inSection:sectionIndex]];
        }
        [self.controller.tableView deleteRowsAtIndexPaths:indexPaths
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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

