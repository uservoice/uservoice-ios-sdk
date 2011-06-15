//
//  UVBaseGroupedCell.m
//  UserVoice
//
//  Created by Scott Rutherford on 02/07/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVBaseGroupedCell.h"
#import "UVClientConfig.h"

#define UV_BASE_GROUPED_CELL_BG 50;

@implementation UVBaseGroupedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
	CGFloat screenWidth = [UVClientConfig getScreenWidth];

    // Configure the view for the selected state
	UIView *selectedBackView = [[[UIView alloc] initWithFrame:CGRectMake(-10, 0, screenWidth, 71)] autorelease];
	selectedBackView.backgroundColor = [UIColor clearColor];
	self.selectedBackgroundView = selectedBackView;
}

- (void)layoutSubviews {	
    [super layoutSubviews];
	
	UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	backView.backgroundColor = [UIColor clearColor];
	self.backgroundView = backView; 
}

- (void)dealloc {
    [super dealloc];
}


@end
