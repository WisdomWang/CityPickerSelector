//
//  LLCityTableViewCell.h
//  JFFootball
//


#import <UIKit/UIKit.h>

//选择定位城市、历史访问城市和热门城市的通知（用来修改“当前：”后面的城市名称）
extern NSString * const LLCityTableViewCellDidChangeCityNotification;

@interface LLCityTableViewCell : UITableViewCell

@property (nonatomic, copy) NSArray *cityNameArray;

@end
