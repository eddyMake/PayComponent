//
//  PayComponent.h
//  Blue_app
//
//  Created by targetios on 2018/10/24.
//  Copyright © 2018年 eddy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PayCancelNotification;
extern NSString * const PayProcessingNotification;
extern NSString * const PaySuccessNotification;
extern NSString * const PayFailureNotification;

@interface PayComponent : NSObject

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;

+ (void)applicationDidBecomeActive:(UIApplication *)application;


/**
 *  发起支付请求，此方法收到用户在第三方操作后将会发送相关状态的通知
 *
 *  @param param 拼接好的订单参数，后台服务器返回直接使用，支付宝为NSString型，微信为NSDictionary类型
 */
+ (void)payWithPayType:(PayType)payType param:(id)param;

/**
 *  检查微信是否已被用户安装
 *
 *  @return 已安装返回YES，未安装返回NO。
 */
+ (BOOL)isWeChatAppInstalled;

@end
