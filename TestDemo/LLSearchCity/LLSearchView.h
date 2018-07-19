//
//  LLSearchView.h
//  JFFootball
//


#import <UIKit/UIKit.h>

@protocol LLSearchViewDelegate <NSObject>

- (void)searchResults:(NSDictionary *)dic;

@end

@interface LLSearchView : UIView

@property (nonatomic, strong) NSMutableArray *resultMutableArray;
@property (nonatomic, weak) id<LLSearchViewDelegate> delegate;

@property (nonatomic, strong) UITableView *rootTableView;
@property (nonatomic, strong) UIView *headerView;
@end
