//
//  CustomTableView.h
//  MyMusic Album Database
//
//  Created by Scott Caruso on 1/23/14.
//  Copyright (c) 2014 Scott Caruso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableView : UITableViewCell
{

}

@property (nonatomic) IBOutlet UILabel *albumLabel; //outlet for the Twitter icon
@property (nonatomic) IBOutlet UILabel *artistLabel;
@property (nonatomic) IBOutlet UILabel *year;

@end
