//
//  SetCell.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cell_icon;
@property (weak, nonatomic) IBOutlet UILabel *cell_label;
@property (weak, nonatomic) IBOutlet UILabel *cell_title;
@end

NS_ASSUME_NONNULL_END
