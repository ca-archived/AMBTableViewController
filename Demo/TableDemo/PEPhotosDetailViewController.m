//
//  PEPhotosDetailViewController.m
//  AMBTableViewController
//
//  Created by Ernesto Rivera on 2014/05/06.
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

#import "PEPhotosDetailViewController.h"
#import "PEPost.h"

@implementation PEPhotosDetailViewController

- (void)setPost:(PEPost *)post
{
    _post = post;
    
    [self updateAllSections];
    [self reloadComments:self];
}

#pragma mark - Sections

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Setup sections
    __weak typeof(self) weakSelf = self;
    self.sections = @[// A section with hideable cells
                      self.topSection,
                      
                      // A section with a single row of one of two kinds
                      [AMBTableViewSection
                       sectionWithObjects:@[@"author_cell"]
                       sectionUpdateBlock:^(AMBTableViewSection * section)
                       {
                           [section reloadObjectAtIndex:0];
                       }
                       cellHeightBlock:NULL
                       cellIdentifierBlock:^NSString *(id object, NSIndexPath *indexPath)
                       {
                           BOOL ownPost = [weakSelf.post.authorName isEqualToString:@"Me"];
                           return ownPost ? @"author_self" : @"author_other";
                       }
                       cellConfigurationBlock:^(id object,
                                                UITableViewCell * cell,
                                                NSIndexPath * indexPath)
                       {
                           PEPhotosDetailAuthorCell * authorCell = (PEPhotosDetailAuthorCell *)cell;
                           authorCell.authorLabel.text = weakSelf.post.authorName;
                       }],
                      
                      // A section with a single "static" cell hidden when post is nil
                      [AMBTableViewSection
                       sectionWithObjects:@[[AMBCellIdentifier identifierFromString:@"write_comment"]]
                       sectionUpdateBlock:^(AMBTableViewSection * section)
                       {
                           section.hidden = (weakSelf.post == nil);
                       }
                       cellHeightBlock:NULL
                       cellIdentifierBlock:NULL
                       cellConfigurationBlock:NULL],
                      
                      // A section with a dynamic number of cells of dynamic height and a special "no content cell"
                      self.commentsSection,
                      
                      // A section with a single "static" cell of custom height
                      [AMBTableViewSection
                       sectionWithObjects:@[[AMBCellIdentifier identifierFromString:@"footer"]]
                       sectionUpdateBlock:NULL
                       cellHeightBlock:^CGFloat(id object, NSIndexPath * indexPath) { return 120.0; }
                       cellIdentifierBlock:NULL
                       cellConfigurationBlock:NULL]];
    
    [self goToNextPost:self];
}

- (AMBTableViewSection *)topSection
{
    if (!_topSection)
    {
        __weak typeof(self) weakSelf = self;
        NSArray * sectionObjects = @[[AMBCellIdentifier identifierFromString:@"title"],   // 0
                                     [AMBCellIdentifier identifierFromString:@"image"],   // 1
                                     [AMBCellIdentifier identifierFromString:@"tags"],    // 2
                                     [AMBCellIdentifier identifierFromString:@"recipe"]]; // 3
        _topSection = [AMBTableViewSection
                       sectionWithObjects:sectionObjects
                       sectionUpdateBlock:^(AMBTableViewSection *section)
                       {
                           [section reloadObjectAtIndex:0];
                       }
                       cellHeightBlock:^CGFloat(id object,
                                                NSIndexPath * indexPath)
                       {
                           switch ([sectionObjects indexOfObject:object]) // Shouldn't use indexPath.row because we hide/show rows
                           {
                               case 0:
                                   return 40.0;
                               case 1:
                                   return 160.0;
                               case 3:
                                   return 170.0;
                               default:
                                   return -1.0; // Table view's default height
                           }
                       }
                       cellIdentifierBlock:NULL
                       cellConfigurationBlock:^(id object,
                                                UITableViewCell * cell,
                                                NSIndexPath * indexPath)
                       {
                           switch ([sectionObjects indexOfObject:object]) // Shouldn't use indexPath.row because we hide/show rows
                           {
                               case 0:
                               {
                                   PEPhotosDetailTitleCell * titleCell = (PEPhotosDetailTitleCell *)cell;
                                   titleCell.titleLabel.text = weakSelf.post.title;
                                   break;
                               }
                               case 1:
                               {
                                   //PEPhotosDetailImageCell * imageCell = (PEPhotosDetailImageCell *)cell;
                                   break;
                               }
                           }
                       }];
        
        // Initial state
        [_topSection setObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]
                                  hidden:YES];
    }
    return _topSection;
}

- (AMBTableViewSection *)commentsSection
{
    if (!_commentsSection)
    {
        __weak typeof(self) weakSelf = self;
        _commentsSection = [AMBTableViewSection
                            sectionWithObjects:@[[AMBCellIdentifier identifierFromString:@"loading_comments"]]
                            sectionUpdateBlock:NULL
                            cellHeightBlock:^CGFloat(id object,
                                                     NSIndexPath * indexPath)
                            {
                                if ([object isKindOfClass:[AMBCellIdentifier class]])
                                {
                                    return -1.0; // Loading comments (default height)
                                }
                                if (!object)
                                {
                                    return 88.0; // No content cell
                                }
                                
                                // Dynamic height comments
                                return [weakSelf heightForResizableCellWithIdentifier:@"comment"
                                                                                 text:object
                                                               limitedToNumberOfLines:0];
                            }
                            cellIdentifierBlock:^NSString *(id object,
                                                            NSIndexPath * indexPath)
                            {
                                return (object ? @"comment" : // A comment
                                        @"no_comments");      // No content cell
                            }
                            cellConfigurationBlock:^(id object,
                                                     UITableViewCell * cell,
                                                     NSIndexPath * indexPath)
                            {
                                if ([cell isKindOfClass:[PEPhotosDetailCommentCell class]] &&
                                    [object isKindOfClass:[NSString class]])
                                {
                                    ((PEPhotosDetailCommentCell *)cell).bodyLabel.text = (NSString *)object;
                                }
                            }];
        
        // Enable section title
        _commentsSection.sectionTitleBlock = ^NSString *(AMBTableViewSection * section)
        {
            return @"Comments";
        };
        
        // Enable "no content cell"
        _commentsSection.presentsNoContentCell = YES;
    }
    return _commentsSection;
}

#pragma mark - Actions

- (IBAction)goToNextPost:(id)sender
{
    PEPost * nextPost = [PEPost new];
    nextPost.authorName = [self.post.authorName isEqualToString:@"Me"] ? @"Another author" : @"Me";
    static NSUInteger count = 1;
    nextPost.title = [NSString stringWithFormat:@"Post %@ by %@", @(count++), nextPost.authorName];
    
    self.post = nextPost;
}

- (IBAction)follow:(id)sender
{
    NSLog(@"Follow tapped.");
}

#pragma mark - Toggling details

- (IBAction)toggleDetails:(id)sender
{
    // Hide if all hiddeable rows are hidden, show all otherwise
    [self.topSection setObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)]
                                  hidden:(![self.topSection isObjectAtIndexHidden:1] &&
                                          ![self.topSection isObjectAtIndexHidden:2] &&
                                          ![self.topSection isObjectAtIndexHidden:3])];
}

- (IBAction)hideDetail:(id)sender
{
    NSIndexPath * indexPath = [self indexPathForRowWithSubview:sender];
    AMBTableViewSection * section = self.sections[indexPath.section];
    id objectToHide = section.visibleObjects[indexPath.row];
    [section setObject:objectToHide
                hidden:YES];
}

#pragma mark - Handling comments

- (IBAction)reloadComments:(id)sender
{
    self.commentsSection.objects = @[[AMBCellIdentifier identifierFromString:@"loading_comments"]];
    
    // Simulate async message loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       self.commentsSection.objects = @[@"Message 1",
                                                        @"Message 2",
                                                        @"Message 3",
                                                        [AMBCellIdentifier identifierFromString:@"load_more_comments"]];
                   });
}

- (IBAction)loadMoreComments:(id)sender
{
    id loadingCommentsObject = [AMBCellIdentifier identifierFromString:@"loading_comments"];
    [self combineChanges:^
     {
         // Remove "load more"
         [self.commentsSection removeObjectAtIndex:self.commentsSection.objects.count - 1];
         
         // Add "loading"
         [self.commentsSection addObject:loadingCommentsObject];
     }];
    
    // Simulate async message loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       [self combineChanges:^
                        {
                            [self.commentsSection removeObject:loadingCommentsObject];
                            [self.commentsSection addObjects:@[@"Additional Message 1",
                                                               @"Additional Message 2",
                                                               @"Additional Message 3",
                                                               [AMBCellIdentifier identifierFromString:@"load_more_comments"]]];
                        }];
                   });
}

- (IBAction)writeComment:(id)sender
{
    static NSUInteger count = 1;
    NSString * comment = [NSString stringWithFormat:@"My message %@", @(count)];
    for (NSUInteger i = 0; i < count; i++)
    {
        comment = [comment stringByAppendingString:@"\nbla bla bla"];
    }
    count++;
    [self.commentsSection insertObject:comment
                               atIndex:0];
}

- (IBAction)deleteComment:(UIButton *)sender
{
    NSIndexPath * indexPath = [self indexPathForRowWithSubview:sender];
    AMBTableViewSection * section = self.sections[indexPath.section];
    id objectToDelete = section.visibleObjects[indexPath.row];
    NSLog(@"Deleting indexPath: %@ object %@", indexPath, objectToDelete);
    
    // Update UI
    [self combineChanges:^
     {
         [section removeObject:objectToDelete];
         
         // Only "load more" left?
         if (section.objects.count == 1)
         {
             // Remove it as well to let the no content cell appear
             [section removeObjectAtIndex:0];
         }
     }];
}

@end


#pragma mark - Cells


@implementation PEPhotosDetailTitleCell

@end


@implementation PEPhotosDetailImageCell

@end


@implementation PEPhotosDetailAuthorCell

@end


@implementation PEPhotosDetailCommentCell

@synthesize resizableView = _resizableView;

@end

