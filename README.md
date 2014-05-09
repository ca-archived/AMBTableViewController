iOS-PETableViewController
=========================

Storyboard-centric block-based controller that simplifies management and sync of UITableView and its dataSource

## Features

Extracted from the included Demo.

### Creating Sections

```obj-c
topSection = [PETableViewSection
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
               
authorSelfSection = [PETableViewSection
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
authorSelfSection.hidden = YES;

authorOtherSection = [PETableViewSection
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
authorOtherSection.hidden = YES;

commentsSection = [PETableViewSection
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
commentsSection.presentsNoContentsCell = YES;
```

### Configuring The Initial Table Configuration

```obj-c
tableViewController.sections = @[topSection,
                                 authorSelfSection,
                                 authorOtherSection,
                                 writeCommentSection,
                                 commentsSection,
                                 
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
```

### Updating Contents Later

```obj-c

- (void)setPost:(id)post
{
    _post = post;
    
    self.authorSelfSection.hidden = !post.isOwnPost;
    self.authorOtherSection.hidden = post.isOwnPost;
    
    [self.tableView reloadData];
    
    [self reloadComments:self];
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
```
