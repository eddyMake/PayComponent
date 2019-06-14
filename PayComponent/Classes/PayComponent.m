//
//  PayComponent.m
//  Blue_app
//
//  Created by targetios on 2018/10/24.
//  Copyright © 2018年 eddy. All rights reserved.
//

#import "PayComponent.h"
#import "Alipay.h"
#import "WeChatPay.h"

NSString * const PayCancelNotification     = @"PayCancelNotification";
NSString * const PayProcessingNotification = @"PayProcessingNotification";
NSString * const PaySuccessNotification    = @"PaySuccessNotification";
NSString * const PayFailureNotification    = @"PayFailureNotification";

PayType _payType;
BOOL _isPayProcessing;

@implementation PayComponent

/**
 *  向第三方支付终端程序注册本应用。
 */
+ (void)registerApp
{
    [WeChatPay registerApp];
    
    _isPayProcessing = NO;
}


/**
 *  处理第三方支付通过URL启动App时传递的数据，需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 *
 *  @param URL 第三方支付启动本应用时传递过来的URL
 *
 *  @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)URL
{
    [Alipay handleOpenURL:URL];
    
    if ([URL.description hasPrefix:[NSString stringWithFormat:@"%@://pay", kWeChatAppID]])
    {
        return [WeChatPay handleOpenURL:URL];
    }
    else
    {
        return NO;
    }
    
    return YES;
}

/**
 *  处理重新回到app内时的支付状态，需要在 applicationDidBecomeActive: 中调用。
 */
+ (void)applicationDidBecomeActive
{
    if (_isPayProcessing)
    {
        NSDictionary *notificationUserInfo = @{@"PayType": @(_payType)};

        [self postNotificationWithName:PayProcessingNotification userInfo:notificationUserInfo];
        
        _isPayProcessing = NO;
    }
}

+ (void)payWithPayType:(PayType)payType param:(id)param
{
    _payType = payType;
    _isPayProcessing = YES;
    
    NSDictionary *notificationUserInfo = @{@"PayType": @(payType)};
    
    if (payType == PayTypeAlipay)
    {
        [Alipay payWithOrderString:param completionHandler:^(NSDictionary *resultDic) {
            
            _isPayProcessing = NO;
            
            NSString *resultCodeString = resultDic[@"resultStatus"];
            
            if ([resultCodeString isEqualToString:@"9000"])
            {
                // 成功
                [self postNotificationWithName:PaySuccessNotification userInfo:notificationUserInfo];
            }
            else if ([resultCodeString isEqualToString:@"6001"])
            {
                // 取消
                [self postNotificationWithName:PayCancelNotification userInfo:notificationUserInfo];
            }
            else if ([resultCodeString isEqualToString:@"4000"])
            {
                // 失败
                [self postNotificationWithName:PayFailureNotification userInfo:notificationUserInfo];
            }
        }];
    }
    else if (payType == PayTypeWechatPay)
    {
        [WeChatPay payWithParamDictionary:param completionHandler:^(PayResp *payResp) {
            
            _isPayProcessing = NO;
            
            if (payResp.errCode == WXSuccess)
            {
                // 成功
                [self postNotificationWithName:PaySuccessNotification userInfo:notificationUserInfo];
            }
            else if (payResp.errCode == WXErrCodeUserCancel)
            {
                // 取消
                [self postNotificationWithName:PayCancelNotification userInfo:notificationUserInfo];
            }
            else
            {
                // 失败
                [self postNotificationWithName:PayFailureNotification userInfo:notificationUserInfo];
            }
        }];
    }
}

+ (void)postNotificationWithName:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
}

+ (BOOL)isWeChatAppInstalled
{
    return [WeChatPay isAppInstalled];
}

#pragma mark - ********

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerApp];
    
    return YES;
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self handleOpenURL:url];
}

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self handleOpenURL:url];
}

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    return [self handleOpenURL:url];
}

+ (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self applicationDidBecomeActive];
}

@end
