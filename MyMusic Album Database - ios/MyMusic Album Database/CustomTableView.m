//
//  CustomTableView.m
//  MyMusic Album Database
//
//  Created by Scott Caruso on 1/23/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import "CustomTableView.h"

@implementation CustomTableView
@synthesize artistLabel,albumLabel,year;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
