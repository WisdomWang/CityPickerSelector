//
//  LLSearchView.m
//  JFFootball
//


#import "LLSearchView.h"

//3rdLibs
#import "Chameleon.h"

static NSString *ID = @"searchCell";

@interface LLSearchView ()<UITableViewDelegate, UITableViewDataSource>


@end

@implementation LLSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)setResultMutableArray:(NSMutableArray *)resultMutableArray {
    
    _resultMutableArray = resultMutableArray;
    [self addSubview:self.rootTableView];
    [_rootTableView reloadData];
}

- (UITableView *)rootTableView {
    
    if (!_rootTableView) {
        _rootTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [_rootTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
        _rootTableView.delegate = self;
        _rootTableView.dataSource = self;
        _rootTableView.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
        _rootTableView.tableHeaderView = self.headerView;
        _rootTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _rootTableView;
}

- (UIView *)headerView {

    if (!_headerView) {
        
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 8)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
        [self addSubview:_headerView];
    }
    return _headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_resultMutableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    NSDictionary *dataDic = _resultMutableArray[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@，%@",[dataDic valueForKey:@"city"],[dataDic valueForKey:@"super"]];
    cell.textLabel.text = text;
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dataDic = _resultMutableArray[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResults:)]) {
        [self.delegate searchResults:dataDic];
    }
}
@end
