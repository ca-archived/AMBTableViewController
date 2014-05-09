//
//  PEPhotosDetailViewController.h
//  pecolly
//
//  Created by 利辺羅 on 2014/05/06.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PETableViewController.h"

@interface PEPhotosDetailViewController : PETableViewController

@property (strong, nonatomic) id post;

@property (strong, nonatomic) PETableViewSection * topSection;
@property (strong, nonatomic) PETableViewSection * authorSelfSection;
@property (strong, nonatomic) PETableViewSection * authorOtherSection;
@property (strong, nonatomic) PETableViewSection * writeCommentSection;
@property (strong, nonatomic) PETableViewSection * commentsSection;

- (IBAction)tappedFollow:(id)sender;
- (IBAction)reloadComments:(id)sender;
- (IBAction)writeComment:(id)sender;
- (IBAction)deleteComment:(UIButton *)sender;

@end

#pragma mark - Cells

@interface PEPhotosDetailTitleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UILabel * dateLabel;

@end


@interface PEPhotosDetailImageCell : UITableViewCell

@end


@interface PEPhotosDetailAuthorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView * avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton * followButton;

@end


@interface PEPhotosDetailMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * bodyLabel;

@end

