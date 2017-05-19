//
//  ContactInfoTableViewCell.h
//  ContactList
//
//  Created by Ivy Xing on 5/17/17.
//  Copyright © 2017 Ivy Xing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactInfoTableViewCell : UITableViewCell

+(NSString *)cellIdentifier;
+ (void)registerCellForTableView:(UITableView *)tableView;
- (void)tableView:(UITableView *)tableView setupCellWithObject:(id)object;

@end
