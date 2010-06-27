//
//  ItemListTableViewCell.h
//  7digital
//
//  Created by John McKerrell on 27/06/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemListTableViewCell : UITableViewCell {
    NSDictionary *itemData;
    BOOL checked;
    BOOL checking;
}

@property (nonatomic,retain) NSDictionary *itemData;
@property () BOOL checked;
@property () BOOL checking;

@end
