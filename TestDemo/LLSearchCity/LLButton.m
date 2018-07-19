//
//  LLButton.m
//  JFFootball
//


#import "LLButton.h"

//3rdLibs
#import "Masonry.h"

@interface LLButton ()

@property (nonatomic, strong) UILabel *jfLabel;
@property (nonatomic, strong) UIImageView *jfImageView;

@end

@implementation LLButton

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self titleLabel:frame];
        [self imageView:frame];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    
    self.jfLabel.text = title;
    CGRect tempFrame = self.jfLabel.frame;
    tempFrame.size.width = self.frame.size.width - 10;
    self.jfLabel.frame = tempFrame;
}

- (void)setTitleColor:(UIColor *)titleColor {
    
    self.jfLabel.textColor = titleColor;
}

- (void)setImageName:(NSString *)imageName {
    
    self.jfImageView.image = [UIImage imageNamed:imageName];
}

- (void)titleLabel:(CGRect)frame {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 10, frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    [self addSubview:label];
    self.jfLabel = label;
}

- (void)imageView:(CGRect)frame {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(7);
        make.height.offset(5);
        make.right.equalTo(self.mas_right).offset(-5);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    self.jfImageView = imageView;
}

@end
