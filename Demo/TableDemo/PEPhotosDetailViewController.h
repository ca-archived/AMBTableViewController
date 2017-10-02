//
//  PEPhotosDetailViewController.h
//  AMBTableViewController
//
//  Created by Ernesto Rivera on 2014/05/06.
//  Copyright (c) 2014-2017 CyberAgent Inc.
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

#import <AMBTableViewController/AMBTableViewController.h>
@class PEPost;

@interface PEPhotosDetailViewController : AMBTableViewController

@property (strong, nonatomic) PEPost * post;

@property (strong, nonatomic) AMBTableViewSection * topSection;
@property (strong, nonatomic) AMBTableViewSection * authorSection;
@property (strong, nonatomic) AMBTableViewSection * writeCommentSection;
@property (strong, nonatomic) AMBTableViewSection * commentsSection;

- (IBAction)goToNextPost:(id)sender;
- (IBAction)toggleDetails:(id)sender;
- (IBAction)hideDetail:(UIButton *)sender;
- (IBAction)follow:(id)sender;
- (IBAction)reloadComments:(id)sender;
- (IBAction)loadMoreComments:(id)sender;
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


@interface PEPhotosDetailCommentCell : UITableViewCell <AMBResizableCell>

@property (weak, nonatomic) IBOutlet UILabel * bodyLabel;

@end

