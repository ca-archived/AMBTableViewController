//
//  PEPhotosDetailViewController.m
//  pecolly
//
//  Created by 利辺羅 on 2014/05/06.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PEPhotosDetailViewController.h"
#import "PEPost.h"

@implementation PEPhotosDetailViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.sections = @[self.topSection,
                      self.authorSection,
                      self.writeCommentSection,
                      self.commentsSection,
                      
                      [PETableViewSection
                       sectionWithObjects:@[[PECellIdentifier identifierFromString:@"footer"]]
                       cellIdentifierBlock:NULL
                       rowHeightBlock:^CGFloat(id object,
                                               NSIndexPath * indexPath)
                       {
                           return 120.0;
                       }
                       configurationBlock:NULL
                       ]];
    
    [self goToNextPost:self];
}

- (void)setPost:(PEPost *)post
{
    _post = post;
    
    BOOL ownPost = [post.authorName isEqualToString:@"Me"];
    self.authorSection.objects = @[[PECellIdentifier identifierFromString:ownPost ? @"author_self" : @"author_other"]];
    
    [self.tableView reloadData];
    
    [self reloadComments:self];
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
    PETableViewSection * section = self.sections[indexPath.section];
    id objectToHide = section.visibleObjects[indexPath.row];
    [section setObject:objectToHide
                hidden:YES];
}

- (IBAction)follow:(id)sender
{
}

- (IBAction)reloadComments:(id)sender
{
    self.commentsSection.objects = @[[PECellIdentifier identifierFromString:@"loading_comments"]];
    
    // Simulate async message loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       self.commentsSection.objects = @[@"Message 1",
                                                        @"Message 2",
                                                        @"Message 3",
                                                        [PECellIdentifier identifierFromString:@"load_more_comments"]];
                   });
}

- (IBAction)loadMoreComments:(id)sender
{
    id loadingCommentsObject = [PECellIdentifier identifierFromString:@"loading_comments"];
    [self combineChanges:^
    {
        // Remove "load more"
        [self.commentsSection removeObjectAtIndex:self.commentsSection.objects.count - 1];
        
        // Add "loading"
        [self.commentsSection addObject:loadingCommentsObject];
    }];
    
    // Simulate async message loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       [self combineChanges:^
                        {
                            [self.commentsSection removeObject:loadingCommentsObject];
                            [self.commentsSection addObjects:@[@"Additional Message 1",
                                                               @"Additional Message 2",
                                                               @"Additional Message 3",
                                                               [PECellIdentifier identifierFromString:@"load_more_comments"]]];
                        }];
                   });
}

- (IBAction)writeComment:(id)sender
{
    static NSUInteger count = 1;
    [self.commentsSection insertObject:[NSString stringWithFormat:@"My message %@", @(count++)]
                               atIndex:0];
}

- (IBAction)deleteComment:(UIButton *)sender
{
    NSIndexPath * indexPath = [self indexPathForRowWithSubview:sender];
    PETableViewSection * section = self.sections[indexPath.section];
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

#pragma mark - Sections

- (PETableViewSection *)topSection
{
    if (!_topSection)
    {
        __weak typeof(self) weakSelf = self;
        NSArray * sectionObjects = @[[PECellIdentifier identifierFromString:@"title"],   // 0
                                     [PECellIdentifier identifierFromString:@"image"],   // 1
                                     [PECellIdentifier identifierFromString:@"tags"],    // 2
                                     [PECellIdentifier identifierFromString:@"recipe"]]; // 3
        _topSection = [PETableViewSection
                       sectionWithObjects:sectionObjects
                       cellIdentifierBlock:NULL
                       rowHeightBlock:^CGFloat(id object,
                                               NSIndexPath * indexPath)
                       {
                           switch ([sectionObjects indexOfObject:object]) // Can't use indexPath.row beacuse we hide/show rows
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
                       configurationBlock:^(id object,
                                            UITableViewCell * cell,
                                            NSIndexPath * indexPath)
                       {
                           switch (indexPath.row)
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

- (PETableViewSection *)authorSection
{
    if (!_authorSection)
    {
        __weak typeof(self) weakSelf = self;
        _authorSection = [PETableViewSection
                          sectionWithObjects:nil
                          cellIdentifierBlock:NULL
                          rowHeightBlock:NULL
                          configurationBlock:^(id object,
                                               UITableViewCell * cell,
                                               NSIndexPath * indexPath)
                          {
                              PEPhotosDetailAuthorCell * authorCell = (PEPhotosDetailAuthorCell *)cell;
                              authorCell.authorLabel.text = weakSelf.post.authorName;
                          }];
    }
    return _authorSection;
}

- (PETableViewSection *)writeCommentSection
{
    if (!_writeCommentSection)
    {
        _writeCommentSection = [PETableViewSection
                                sectionWithObjects:@[[PECellIdentifier identifierFromString:@"write_comment"]]
                                cellIdentifierBlock:NULL
                                rowHeightBlock:NULL
                                configurationBlock:NULL];
    }
    return _writeCommentSection;
}

- (PETableViewSection *)commentsSection
{
    if (!_commentsSection)
    {
        _commentsSection = [PETableViewSection
                            sectionWithObjects:@[[PECellIdentifier identifierFromString:@"loading_comments"]]
                            cellIdentifierBlock:^NSString *(id object,
                                                            NSIndexPath * indexPath)
                            {
                                return ([object isKindOfClass:[PECellIdentifier class]] ? nil :     // Loading comments
                                        (object ? @"comment" :                                      // A comment
                                         @"no_comments"));                                          // No content cell
                            }
                            rowHeightBlock:^CGFloat(id object,
                                                    NSIndexPath * indexPath)
                            {
                                return ([object isKindOfClass:[PECellIdentifier class]] ? -1.0 :    // Loading comments (default height)
                                        (object ? 170.0 :                                           // A comment
                                         88.0));                                                    // No content cell
                            }
                            configurationBlock:^(id object,
                                                 UITableViewCell * cell,
                                                 NSIndexPath * indexPath)
                            {
                                if ([cell isKindOfClass:[PEPhotosDetailMessageCell class]] &&
                                    [object isKindOfClass:[NSString class]])
                                {
                                    ((PEPhotosDetailMessageCell *)cell).bodyLabel.text = (NSString *)object;
                                }
                            }];
        _commentsSection.presentsNoContentCell = YES;
    }
    return _commentsSection;
}

@end


#pragma mark - Cells


@implementation PEPhotosDetailTitleCell

@end


@implementation PEPhotosDetailImageCell

@end


@implementation PEPhotosDetailAuthorCell

@end


@implementation PEPhotosDetailMessageCell

@end

