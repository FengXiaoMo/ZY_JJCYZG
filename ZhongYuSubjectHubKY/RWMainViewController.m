//
//  RWMainViewController.m
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/4/26.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWMainViewController.h"
#import "RWDataBaseManager.h"
#import "RWChooseSubViewController.h"
#import <SVProgressHUD.h>
#import "RWWelcomeController.h"
#import "RWMainViewController+Drawer.h"
#import "RWMainViewController+CountDownView.h"

@interface RWMainViewController ()

<
    UIAlertViewDelegate,
    WKNavigationDelegate,
    WKUIDelegate
>

@property (nonatomic,strong)RWDataBaseManager *baseManager;

@end

@implementation RWMainViewController

@synthesize baseManager;
@synthesize deployManager;

- (void)initBar
{
    self.navigationItem.title = @"基金从业资讯";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
    self.navigationController.navigationBar.translucent = NO;
 
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton =
                [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"admin_gg"]
                                                style:UIBarButtonItemStyleDone
                                               target:self
                                               action:@selector(drawerSwitch)];
    
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)toWelcomeView
{
    RWWelcomeController *welcomeView = [[RWWelcomeController alloc] init];
    
    [self presentViewController:welcomeView animated:NO completion:nil];
}

- (void)initManagersAndDatas
{
    _requestManager = [[RWRequsetManager alloc] init];
    
    baseManager = [RWDataBaseManager defaultManager];
    
    deployManager = [RWDeployManager defaultManager];
}

- (void)initInformationView
{
    _informationView = [[WKWebView alloc] init];
    
    _informationView.UIDelegate = self;
    _informationView.navigationDelegate = self;
    
    [self.view addSubview:_informationView];
    
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.top.equalTo(self.view.mas_top).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    
    NSURLRequest *requset = [NSURLRequest requestWithURL:
                [NSURL URLWithString:@"http://www.zhongyuedu.com/tgm/test/test4/"]];
    
    [_informationView loadRequest:requset];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
    
    [SVProgressHUD showWithStatus:@"正在加载..."];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [SVProgressHUD dismiss];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [SVProgressHUD dismiss];
    
    [RWRequsetManager warningToViewController:self Title:@"网络连接失败，请检查网络" Click:^{
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MAIN_NAV
    
    [self initManagersAndDatas];
    
    [self initBar];
    
    [self initInformationView];
    
    [self compositionDrawer];
    
    [self examineWhetherShowTestCountDownView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tabBarController.view.window insertSubview:_drawerView atIndex:0];
    
    _drawerCenter = _drawerView.center;
    
    if ([[deployManager deployValueForKey:FIRST_OPEN_APPILCATION] boolValue])
    {
        [self toWelcomeView];
        
        return;
    }
    
    if (_countDown)
    {
        [_countDown rollTestNameAndDays];
    }
}

#pragma mark - RWRequsetDelegate

- (void)requestError:(NSError *)error Task:(NSURLSessionDataTask *)task {
    
    [SVProgressHUD dismiss];
    
    if (_requestManager.reachabilityStatus == AFNetworkReachabilityStatusUnknown)
    {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        
        [SVProgressHUD setFont:[UIFont systemFontOfSize:14]];
        
        [SVProgressHUD setMinimumDismissTimeInterval:0.1];
    
        [SVProgressHUD showInfoWithStatus:@"当前无网络，请检查网络设置"];
                
    }
}

#pragma mark +CountDown

- (void)countDownView:(RWCountDownView *)countDown DidClickCloseButton:(UIImageView *)closeButton
{
    [self removeCountDownView];
}

@end
