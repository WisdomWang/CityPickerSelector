//
//  LLCityTableViewCell.m
//  JFFootball
//


#import "LLCityTableViewCell.h"

#import "Masonry.h"
#import "LLCityCollectionFlowLayout.h"
#import "LLCityCollectionViewCell.h"

NSString * const LLCityTableViewCellDidChangeCityNotification = @"LLCityTableViewCellDidChangeCityNotification";

static NSString *ID = @"cityCollectionViewCell";

@interface LLCityTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation LLCityTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self addSubview:self.collectionView];
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[[LLCityCollectionFlowLayout alloc] init]];
        [_collectionView registerClass:[LLCityCollectionViewCell class] forCellWithReuseIdentifier:ID];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (void)setCityNameArray:(NSArray *)cityNameArray {
    
    _cityNameArray = cityNameArray;
    [_collectionView reloadData];
}

#pragma mark UICollectionViewDataSource 数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _cityNameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LLCityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.title = _cityNameArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cityName = _cityNameArray[indexPath.row];
    NSDictionary *cityNameDic = @{@"cityName":cityName};
    [[NSNotificationCenter defaultCenter] postNotificationName:LLCityTableViewCellDidChangeCityNotification object:self userInfo:cityNameDic];
}


@end
