//
//  PEPhotosDetailViewController.m
//  pecolly
//
//  Created by 利辺羅 on 2014/05/06.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PEPhotosDetailViewController.h"

@implementation PEPhotosDetailViewController

+ (NSString *)storyboardName
{
    return @"PhotosDetail";
}

+ (instancetype)controllerForPost:(id)post
{
    PEPhotosDetailViewController * controller = [self controller];
    controller.post = post;
    return controller;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.sections = @[self.topSection,
                      self.authorSelfSection,
                      self.authorOtherSection,
                      self.writeCommentSection,
                      self.commentsSection,
                      
                      [PETableViewSection
                       sectionWithObjects:@[[PECellIdentifier identifierFromString:@"Footer"]]
                       cellIdentifierBlock:NULL
                       rowHeightBlock:^CGFloat(id object,
                                               NSIndexPath * indexPath)
                       {
                           return 120.0;
                       }
                       configurationBlock:NULL
                       ]];
    
    self.post = @"Post";
}

- (void)setPost:(id)post
{
    _post = post;
    
    if (YES) // Own post
    {
        self.authorSelfSection.hidden = NO;
    }
    
    [self.tableView reloadData];
    
    [self reloadComments:self];
}

#pragma mark - Actions

- (IBAction)tappedFollow:(id)sender
{
}

- (IBAction)reloadComments:(id)sender
{
    // Simulate async message loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       self.commentsSection.objects = @[@"Message 1",
                                                        @"Message 2",
                                                        @"Message 3"];
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
    CGPoint point = [self.tableView convertPoint:sender.center
                                        fromView:sender.superview];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    PETableViewSection * section = self.sections[indexPath.section];
    id objectToDelete = section.objects[indexPath.row];
    NSLog(@"Deleting indexPath: %@ object %@", indexPath, objectToDelete);
    
    // Update UI
    [section removeObject:objectToDelete];
}

#pragma mark - Sections

- (PETableViewSection *)topSection
{
    if (!_topSection)
    {
        _topSection = [PETableViewSection
                       sectionWithObjects:@[[PECellIdentifier identifierFromString:@"PEPhotosDetailTitleCell"],
                                            [PECellIdentifier identifierFromString:@"PEPhotosDetailImageCell"]]
                       cellIdentifierBlock:NULL
                       rowHeightBlock:^CGFloat(id object,
                                               NSIndexPath * indexPath)
                       {
                           switch (indexPath.row)
                           {
                               case 0:
                                   return 40.0;
                               case 1:
                                   return 320.0;
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
                                   titleCell.textLabel.text = @"Hi!";
                                   break;
                               }
                               case 1:
                               {
                                   //PEPhotosDetailImageCell * imageCell = (PEPhotosDetailImageCell *)cell;
                                   break;
                               }
                               case 2:
                               {
                                   PEPhotosDetailAuthorCell * authorCell = (PEPhotosDetailAuthorCell *)cell;
                                   authorCell.authorLabel.text = @"Me";
                                   break;
                               }
                           }
                       }];
    }
    return _topSection;
}

- (PETableViewSection *)authorSelfSection
{
    if (!_authorSelfSection)
    {
        _authorSelfSection = [PETableViewSection
                              sectionWithObjects:@[[PECellIdentifier identifierFromString:@"PEPhotosDetailAuthorCell_self"]]
                              cellIdentifierBlock:NULL
                              rowHeightBlock:NULL
                              configurationBlock:^(id object,
                                                   UITableViewCell * cell,
                                                   NSIndexPath * indexPath)
                              {
                                  PEPhotosDetailAuthorCell * authorCell = (PEPhotosDetailAuthorCell *)cell;
                                  authorCell.authorLabel.text = @"Me";
                              }];
        _authorSelfSection.hidden = YES;
    }
    return _authorSelfSection;
}

- (PETableViewSection *)authorOtherSection
{
    if (!_authorOtherSection)
    {
        _authorOtherSection = [PETableViewSection
                               sectionWithObjects:@[[PECellIdentifier identifierFromString:@"PEPhotosDetailAuthorCell"],
                                                    [PECellIdentifier identifierFromString:@"Mane"]]
                               cellIdentifierBlock:NULL
                               rowHeightBlock:NULL
                               configurationBlock:^(id object,
                                                    UITableViewCell * cell,
                                                    NSIndexPath * indexPath)
                               {
                                   switch (indexPath.row)
                                   {
                                       case 0:
                                       {
                                           PEPhotosDetailAuthorCell * authorCell = (PEPhotosDetailAuthorCell *)cell;
                                           authorCell.authorLabel.text = @"Other author";
                                           break;
                                       }
                                   }
                               }];
        _authorOtherSection.hidden = YES;
    }
    return _authorOtherSection;
}

- (PETableViewSection *)writeCommentSection
{
    if (!_writeCommentSection)
    {
        _writeCommentSection = [PETableViewSection
                                sectionWithObjects:@[[PECellIdentifier identifierFromString:@"WriteComment"]]
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
                            sectionWithObjects:nil // Start empty
                            cellIdentifierBlock:^NSString *(id object,
                                                            NSIndexPath * indexPath)
                            {
                                return object ? @"PEPhotosDetailMessageCell" : @"NoComments" ;
                            }
                            rowHeightBlock:^CGFloat(id object,
                                                    NSIndexPath * indexPath)
                            {
                                return object ? 170.0 : 88.0;
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
        _commentsSection.presentsNoContentsCell = YES;
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

