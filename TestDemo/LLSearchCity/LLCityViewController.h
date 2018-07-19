//
//  LLCityViewController.h
//  JFFootball
//

#import <UIKit/UIKit.h>

@protocol LLCityViewControllerDelegate <NSObject>

- (void)cityName:(NSString *)name;

@end

@interface LLCityViewController : UIViewController

@property (nonatomic, weak) id<LLCityViewControllerDelegate> delegate;
@end
