//
//  JFCityViewController.m
//  JFFootball
//


#import "LLCityViewController.h"

#import "LLCityTableViewCell.h"
#import "JFAreaDataManager.h"
#import "JFLocation.h"
#import "LLSearchView.h"
#import "Chameleon.h"
#import "MBProgressHUD.h"

#define kCurrentCityInfoDefaults [NSUserDefaults standardUserDefaults]
#define xScreenWidth        ([UIScreen mainScreen].bounds.size.width)
#define xScreenHeight       ([UIScreen mainScreen].bounds.size.height)

@interface LLCityViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate,
JFLocationDelegate,
LLSearchViewDelegate>

{
    NSMutableArray   *_indexMutableArray;           //存字母索引下标数组
    NSMutableArray   *_sectionMutableArray;         //存处理过以后的数组
    NSInteger        _HeaderSectionTotal;           //头section的个数
    
    MBProgressHUD *HUD;
    
}

@property (nonatomic, strong) UITableView *rootTableView;
@property (nonatomic, strong) LLCityTableViewCell *cell;
@property (nonatomic, strong) JFAreaDataManager *manager;
@property (nonatomic, strong) JFLocation *locationManager;
@property (nonatomic, strong) LLSearchView *searchView;

@property (nonatomic, strong) UIView *naviBarTitleView;
@property (nonatomic, strong) UISearchBar *mainSearchBar;
/** 最近访问的城市*/
@property (nonatomic, strong) NSMutableArray *historyCityMutableArray;
/** 热门城市*/
@property (nonatomic, strong) NSArray *hotCityArray;
/** 字母索引*/
@property (nonatomic, strong) NSMutableArray *characterMutableArray;
/** 所有“市”级城市名称*/
@property (nonatomic, strong) NSMutableArray *cityMutableArray;

@property (nonatomic, copy) NSString *cityNow;
@property BOOL isPop;

@end

@implementation LLCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseCityWithName:) name:LLCityTableViewCellDidChangeCityNotification object:nil];
    
    self.naviBarTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.76*xScreenWidth, 31)];
    self.mainSearchBar.center = _naviBarTitleView.center;
    [_naviBarTitleView addSubview:_mainSearchBar];
    self.navigationItem.titleView = _naviBarTitleView;
    
    _isPop =NO;
    _HeaderSectionTotal = 3;
    
    [self.view addSubview:self.rootTableView];
    
    [self backBarButtonItem];
    [self initWithJFAreaDataManaager];
    
    _indexMutableArray = [NSMutableArray array];
    _sectionMutableArray = [NSMutableArray array];
    
    if ([kCurrentCityInfoDefaults objectForKey:@"cityData"]) {
        self.characterMutableArray = [NSKeyedUnarchiver unarchiveObjectWithData:[kCurrentCityInfoDefaults objectForKey:@"cityData"]];
        _sectionMutableArray = [NSKeyedUnarchiver unarchiveObjectWithData:[kCurrentCityInfoDefaults objectForKey:@"sectionData"]];
        [_rootTableView reloadData];
    }else {
        //在子线程中异步执行汉字转拼音再转汉字耗时操作
        dispatch_queue_t serialQueue = dispatch_queue_create("com.city.www", DISPATCH_QUEUE_SERIAL);
        dispatch_async(serialQueue, ^{
            [self processData:^(id success) {
                //回到主线程刷新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_rootTableView reloadData];
                    self.locationManager = [[JFLocation alloc] init];
                    _locationManager.delegate = self;
                });
            }];
        });
    }
    
    self.historyCityMutableArray = [NSKeyedUnarchiver unarchiveObjectWithData:[kCurrentCityInfoDefaults objectForKey:@"historyCity"]];
}

#pragma mark - 添加取消按钮

- (void)backBarButtonItem {
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(backrootTableViewController) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"取消" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

#pragma mark - 初始化数据库，获取所有“市”级城市名称

- (void)initWithJFAreaDataManaager {
    
    _manager = [JFAreaDataManager shareInstance];
    [_manager areaSqliteDBData];
    __weak typeof(self) weakSelf = self;
    [_manager cityData:^(NSMutableArray *dataArray) {
        //立刻生成一个strong引用，以保证实例在执行期间持续存活
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.cityMutableArray = dataArray;
        }
    }];
}

#pragma mark - 选择城市时调用通知函数（前提是点击cell的section < 3）

- (void)chooseCityWithName:(NSNotification *)info {
    NSDictionary *cityDic = info.userInfo;
    NSString *cityName = [[NSString alloc] init];
    if ([[cityDic valueForKey:@"cityName"] isEqualToString:@"全城"]) {
        __weak typeof(self) weakSelf = self;
        [_manager currentCity:[kCurrentCityInfoDefaults objectForKey:@"cityNumber"] currentCityName:^(NSString *name) {
            [kCurrentCityInfoDefaults setObject:name forKey:@"currentCity"];
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
        
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(cityName:)]) {
                    [strongSelf.delegate cityName:name];
                }
            }

        }];
    }else {
        cityName = [cityDic valueForKey:@"cityName"];
        [kCurrentCityInfoDefaults setObject:[cityDic valueForKey:@"cityName"] forKey:@"currentCity"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(cityName:)]) {
            [self.delegate cityName:cityName];
        }
        [_manager cityNumberWithCity:[cityDic valueForKey:@"cityName"] cityNumber:^(NSString *cityNumber) {
            [kCurrentCityInfoDefaults setObject:cityNumber forKey:@"cityNumber"];
        }];
        
        [self historyCity:cityName];
    }
    
    //销毁通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 数组、视图 初始化

- (NSArray *)hotCityArray {
    if (!_hotCityArray) {
        _hotCityArray = @[@"北京市", @"上海市", @"广州市", @"深圳市", @"武汉市", @"天津市", @"西安市", @"南京市", @"杭州市", @"成都市", @"重庆市",@"郑州市"];
    
    }
    return _hotCityArray;
}

- (NSMutableArray *)historyCityMutableArray {
    if (!_historyCityMutableArray) {
        _historyCityMutableArray = [[NSMutableArray alloc] init];
    }
    return _historyCityMutableArray;
}

- (NSMutableArray *)characterMutableArray {
    if (!_characterMutableArray) {
        _characterMutableArray = [NSMutableArray arrayWithObjects:@"!", @"#", @"$", nil];
    }
    return _characterMutableArray;
}

- (LLSearchView *)searchView {
    if (!_searchView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        _searchView = [[LLSearchView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _searchView.delegate = self;
    }
    return _searchView;
}

#pragma mark - 汉字转拼音再转成汉字
-(void)processData:(void (^) (id))success {
    for (int i = 0; i < _cityMutableArray.count; i ++) {
        NSString *str = _cityMutableArray[i]; //一开始的内容
        if (str.length) {  //下面那2个转换的方法一个都不能少
            NSMutableString *ms = [[NSMutableString alloc] initWithString:str];
            //汉字转拼音
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {

                if ([[(NSString *)str substringToIndex:1] compare:@"长"] == NSOrderedSame)
                {
                    [ms replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chang"];
                }
            }
           
            //拼音转英文
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                //字符串截取第一位，并转换成大写字母
                NSString *firstStr = [[ms substringToIndex:1] uppercaseString];
                //如果不是字母开头的，转为＃
                BOOL isLetter = [self matchLetter:firstStr];
                if (!isLetter)
                    firstStr = @"#";
                
                //如果还没有索引
                if (_indexMutableArray.count <= 0) {
                    //保存当前这个做索引
                    [_indexMutableArray addObject:firstStr];
                    //用这个字母做字典的key，将当前的标题保存到key对应的数组里面去
                    NSMutableArray *array = [NSMutableArray arrayWithObject:str];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:array,firstStr, nil];
                    [_sectionMutableArray addObject:dic];
                }else{
                    //如果索引里面包含了当前这个字母，直接保存数据
                    if ([_indexMutableArray containsObject:firstStr]) {
                        //取索引对应的数组，保存当前标题到数组里面
                        NSMutableArray *array = _sectionMutableArray[0][firstStr];
                        [array addObject:str];
                        //重新保存数据
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:array,firstStr, nil];
                        [_sectionMutableArray addObject:dic];
                    }else{
                        //如果没有包含，说明是新的索引
                        [_indexMutableArray addObject:firstStr];
                        //用这个字母做字典的key，将当前的标题保存到key对应的数组里面去
                        NSMutableArray *array = [NSMutableArray arrayWithObject:str];
                        NSMutableDictionary *dic = _sectionMutableArray[0];
                        [dic setObject:array forKey:firstStr];
                        [_sectionMutableArray addObject:dic];
                    }
                }
            }
        }
    }
    
    //将字母排序
    NSArray *compareArray = [[_sectionMutableArray[0] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    _indexMutableArray = [NSMutableArray arrayWithArray:compareArray];
    
    //判断第一个是不是字母，如果不是放到最后一个
    BOOL isLetter = [self matchLetter:_indexMutableArray[0]];
    if (!isLetter) {
        //获取数组的第一个元素
        NSString *firstStr = [_indexMutableArray firstObject];
        //移除第一项元素
        [_indexMutableArray removeObjectAtIndex:0];
        //插入到最后一个位置
        [_indexMutableArray insertObject:firstStr atIndex:_indexMutableArray.count];
    }
    
    [self.characterMutableArray addObjectsFromArray:_indexMutableArray];
    NSData *cityData = [NSKeyedArchiver archivedDataWithRootObject:self.characterMutableArray];
    NSData *sectionData = [NSKeyedArchiver archivedDataWithRootObject:_sectionMutableArray];
    
    //拼音转换太耗时，这里把第一次转换结果存到单例中
    [kCurrentCityInfoDefaults setValue:cityData forKey:@"cityData"];
    [kCurrentCityInfoDefaults setObject:sectionData forKey:@"sectionData"];
    success(@"成功");
}

#pragma mark - 匹配是不是字母开头

- (BOOL)matchLetter:(NSString *)str {
    //判断是否以字母开头
    NSString *ZIMU = @"^[A-Za-z]+$";
    NSPredicate *regextestA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ZIMU];
    
    if ([regextestA evaluateWithObject:str] == YES)
        return YES;
    else
        return NO;
}

#pragma mark - 取消按钮点击事件

- (void)backrootTableViewController {
    
    if (_isPop == YES) {
     
        [self.searchView removeFromSuperview];
        [_mainSearchBar resignFirstResponder];
        _isPop =NO;
        _mainSearchBar.text = @"";
        [HUD hideAnimated:YES];
        
    } else {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

#pragma mark - searchbar 懒加载

- (UISearchBar *)mainSearchBar {
    
    if (!_mainSearchBar) {
        
        CGFloat sbHeight = 27.0f;
        CGFloat sbRadius = sbHeight / 2.0f - 1.0f;
        
        if (@available(iOS 11.0, *)) {
            sbHeight = 40.0f;
            sbRadius = sbHeight / 2.0f - 2.0f;
        }
        
        CGRect searchBarFrame = CGRectMake(0, 0, xScreenWidth*0.76, sbHeight);
        
        _mainSearchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
        _mainSearchBar.delegate = self;
        _mainSearchBar.backgroundImage = [[UIImage alloc] init];
        _mainSearchBar.barTintColor = [UIColor whiteColor];
        
        UITextField *searchField = [_mainSearchBar valueForKey:@"searchField"];
        if (searchField) {
            searchField.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
            searchField.textColor = [UIColor colorWithHexString:@"#333333"];
            searchField.font = [UIFont systemFontOfSize:15];
            searchField.layer.cornerRadius = sbRadius;
            searchField.layer.borderColor = [UIColor clearColor].CGColor;
            searchField.layer.masksToBounds = YES;
        }
        _mainSearchBar.placeholder = @"请输入城市名称";
        [_mainSearchBar setImage:[UIImage imageNamed:@"llsc_icon_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        
    }
    
    return _mainSearchBar;
}

#pragma mark - tableview 懒加载

- (UITableView *)rootTableView {
    if (!_rootTableView) {
        _rootTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _rootTableView.delegate = self;
        _rootTableView.dataSource = self;
        _rootTableView.sectionIndexColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
        [_rootTableView registerClass:[LLCityTableViewCell class] forCellReuseIdentifier:@"cityCell"];
        [_rootTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityNameCell"];
    }
    return _rootTableView;
}

#pragma mark - tableview 数据源 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _characterMutableArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section < _HeaderSectionTotal ? 1 : [_sectionMutableArray[0][_characterMutableArray[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.imageView.image = [UIImage imageNamed:@"llsc_icon_address"];
        NSString *locationCity = [kCurrentCityInfoDefaults objectForKey:@"locationCity"];
        cell.textLabel.text = locationCity ? locationCity : @"正在定位...";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    if ( indexPath.section < _HeaderSectionTotal ) {
        self.cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];

        if (indexPath.section == _HeaderSectionTotal - 2) {
            _cell.cityNameArray = self.historyCityMutableArray;
        }
        if (indexPath.section == _HeaderSectionTotal - 1) {
            _cell.cityNameArray = self.hotCityArray;
        }
    return _cell;
    }else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityNameCell" forIndexPath:indexPath];
        NSArray *currentArray = _sectionMutableArray[0][_characterMutableArray[indexPath.section]];
        cell.textLabel.text = currentArray[indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
          
        return indexPath.section == (_HeaderSectionTotal - 1) ? 180 : 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }else{
        return 34;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_HeaderSectionTotal == 3) {
        switch (section) {
            case 0:
                return @"";
                break;
            case 1:
                return @"历史访问城市";
                break;
            case 2:
                return @"热门搜索";
                break;
            default:
                return _characterMutableArray[section];
                break;
        }
    }else {
        switch (section) {
            case 1:
                return @"";
                break;
            case 2:
                return @"历史访问城市";
                break;
            case 3:
                return @"热门搜索";
                break;
            default:
                return _characterMutableArray[section];
                break;
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    if (section<_HeaderSectionTotal) {
        view.tintColor = [UIColor whiteColor];
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        header.textLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        header.textLabel.font = [UIFont systemFontOfSize:14];
    } else {
        
       view.tintColor = [UIColor colorWithHexString:@"#eeeeee"];
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        header.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        header.textLabel.font = [UIFont systemFontOfSize:17];
    }
    
}

//设置右侧索引的标题，这里返回的是一个数组哦！
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return _characterMutableArray;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [kCurrentCityInfoDefaults setObject:cell.textLabel.text forKey:@"currentCity"];
    [_manager cityNumberWithCity:cell.textLabel.text cityNumber:^(NSString *cityNumber) {
        [kCurrentCityInfoDefaults setObject:cityNumber forKey:@"cityNumber"];
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cityName:)]) {
        [self.delegate cityName:cell.textLabel.text];
    }
    [self historyCity:cell.textLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - searchBar 代理 方法

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    if (_searchView.resultMutableArray.count > 0 ) {

        [ _searchView.resultMutableArray removeAllObjects];
        [ _searchView.rootTableView reloadData];

    }
    _isPop = YES;
    [self.view addSubview:self.searchView];
     _searchView.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
   
    return YES;
}

// searchBar文本改变时即调用
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [HUD hideAnimated:YES];
    
    [_manager searchCityData:searchText result:^(NSMutableArray *result) {
        if ([result count] > 0) {
            
            _searchView.resultMutableArray = result;
        } else {
        
                HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self.view addSubview:HUD];
                HUD.mode = MBProgressHUDModeText;
                HUD.label.text = @"啊哦，暂时没有你要的内容哦";
                HUD.label.textColor = [UIColor colorWithHexString:@"#ffffff"];
                HUD.bezelView.backgroundColor = [UIColor colorWithHexString:@"#737373"];
                [self.view bringSubviewToFront:HUD];
        }
    }];
    
    [_mainSearchBar resignFirstResponder];
    
}

// 点击键盘搜索按钮时调用
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

#pragma mark - LLSearchViewDelegate 方法

- (void)searchResults:(NSDictionary *)dic {
\
    [kCurrentCityInfoDefaults setObject:[dic valueForKey:@"city"] forKey:@"currentCity"];
    [kCurrentCityInfoDefaults setObject:[dic valueForKey:@"city_number"] forKey:@"cityNumber"];
    NSString *nameStr = [dic valueForKey:@"city"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cityName:)]) {
        [self.delegate cityName:nameStr];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self historyCity:[dic valueForKey:@"city"]];
}

#pragma mark - JFLocationDelegate方法

- (void)locating {
    NSLog(@"定位中。。。");
}

//定位成功
- (void)currentLocation:(NSDictionary *)locationDictionary {
    
    NSString *city = [locationDictionary valueForKey:@"City"];
    [kCurrentCityInfoDefaults setObject:city forKey:@"locationCity"];
    [_manager cityNumberWithCity:city cityNumber:^(NSString *cityNumber) {
    [kCurrentCityInfoDefaults setObject:cityNumber forKey:@"cityNumber"];
    }];
    _cityNow = city;
    [self historyCity:city];
    [_rootTableView reloadData];
}

/// 添加历史访问城市
- (void)historyCity:(NSString *)city {

    //避免重复添加，先删除再添加
    [_historyCityMutableArray removeObject:city];
    [_historyCityMutableArray insertObject:city atIndex:0];
    if (_historyCityMutableArray.count > 3) {
        [_historyCityMutableArray removeLastObject];
    }
    NSData *historyCityData = [NSKeyedArchiver archivedDataWithRootObject:self.historyCityMutableArray];
    [kCurrentCityInfoDefaults setObject:historyCityData forKey:@"historyCity"];
}

/// 拒绝定位
- (void)refuseToUsePositioningSystem:(NSString *)message {
    NSLog(@"%@",message);
}

/// 定位失败
- (void)locateFailure:(NSString *)message {
    NSLog(@"%@",message);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
