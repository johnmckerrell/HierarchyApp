//
//  ItemListTableViewCell.m
//  7digital
//
//  Created by John McKerrell on 27/06/2010.
//  Copyright 2010 MKE Computing Ltd. All rights reserved.
//

#import "ItemListTableViewCell.h"


@implementation ItemListTableViewCell

/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

- (NSDictionary*) itemData {
    return itemData;
}

- (void) setItemData:(NSDictionary *)data {
    [data retain];
    [itemData release];
    itemData = data;
    
    // Configure the cell...
    self.textLabel.text = [itemData objectForKey:@"title"];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
}

- (BOOL) checked {
    return checked;
}

- (void) setChecked:(BOOL) _checked {
    checked = _checked;
    self.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (BOOL) checking {
    return checking;
}

- (void) setChecking:(BOOL) _checking {
    checking = _checking;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)dealloc {
    [super dealloc];
}


@end
