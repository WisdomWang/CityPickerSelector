//
//  ViewController.m
//  TestDemo
//
//  Created by wangzhen on 2018/1/5.
//  Copyright © 2018年 coolfar. All rights reserved.
//

#import "ViewController.h"
#import "LLCityViewController.h"
@interface ViewController ()<LLCityViewControllerDelegate> {
    
    UILabel *label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    label = [[UILabel alloc]init];
    label.center = self.view.center;
    label.bounds = CGRectMake(0, 0, 200, 30);
    label.textColor = [UIColor blackColor];
    label.text = @"选择的城市为：";
    [self.view addSubview:label];
    
    UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    iconBtn.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-100);
    iconBtn.bounds = CGRectMake(0, 0, 100, 50);
    [iconBtn setTitle:@"选择城市" forState:UIControlStateNormal];
    iconBtn.layer.masksToBounds = YES;
    iconBtn.layer.cornerRadius = 10.0f;
    iconBtn.backgroundColor = [UIColor greenColor];
    [iconBtn addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:iconBtn];
    
    
}

- (void)popView {
    
    LLCityViewController *city = [LLCityViewController new];
    city.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:city];
    [self presentViewController:nav animated:YES completion:nil];
    
}
- (void)cityName:(NSString *)name {
    
    label.text = [NSString stringWithFormat:@"选择的城市为：%@",name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
