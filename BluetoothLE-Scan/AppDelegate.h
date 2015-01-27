//
//  AppDelegate.h
//  GW3demo
//
//  Created by hungWei on 2014/2/10.
//  Copyright (c) 2014年 globalsat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;
@class CBCentralManager;

@protocol BLEOberver <NSObject>

@optional

- (void) didDiscoverPeripheral:(CBPeripheral*)peripheral;
- (void) didConnectPeripheral:(CBPeripheral*)peripheral;
- (void) didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSString*)errorMessage;
- (void) didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSString*)errorMessage;

@end


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *discoveredPeripherals;

@property (strong, nonatomic) CBCentralManager *cbCentralManager;

@property (strong, nonatomic) NSMutableArray *BLEObservers;

@end


