//
//  JFCityCollectionViewCell.m
//  JFFootball
//


#import "LLCityCollectionViewCell.h"

//3rdLibs
#import "Chameleon.h"

@interface LLCityCollectionViewCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation LLCityCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
        label.textColor = [UIColor colorWithHexString:@"#333333"];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        self.label = label;
    }
    return self;    
}

/// 设置collectionView cell的border
- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.layer.cornerRadius = 15.5;
    self.layer.masksToBounds = YES;
}

- (void)setTitle:(NSString *)title {
    
    self.label.text = title;
}

@end
