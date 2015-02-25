//
//  chatCellTableViewCell.h
//  PubNubDemo
//
//  Created by Brian Lee on 2/23/15.
//  Copyright (c) 2015 Brian Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chatCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *message;

@end
