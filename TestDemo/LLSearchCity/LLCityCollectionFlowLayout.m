//
//  LLCityCollectionFlowLayout.m
//  JFFootball
//


#import "LLCityCollectionFlowLayout.h"
//#import "UIDevice-Hardware.h"

@implementation LLCityCollectionFlowLayout

#define xScreenWidth        ([UIScreen mainScreen].bounds.size.width)
#define xScreenHeight       ([UIScreen mainScreen].bounds.size.height)

/// 准备布局
- (void)prepareLayout {
    
    [super prepareLayout];
    //设置item尺寸
    //CGFloat itemW = (self.collectionView.frame.size.width - 60)/ 3;
//    if ([[UIDevice currentDevice] modelInch] <= 4.0f) {
//
//        self.itemSize = CGSizeMake(65, 31);
//
//    } else {
//
//        self.itemSize = CGSizeMake(95, 31);
//
//    }
     self.itemSize = CGSizeMake(95, 31);
    //设置最小间距
    self.minimumLineSpacing = 12;
    self.minimumInteritemSpacing = 14;
    self.sectionInset = UIEdgeInsetsMake(0, 18, 0, 40);
}

@end
