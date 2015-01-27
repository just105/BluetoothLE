//
//  AppDelegate.m
//  GW3demo
//
//  Created by Hung on 2014/2/10.
//  Copyright (c) 2014年 globalsat. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate () <CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@implementation AppDelegate

- (id) init
{
    
    self = [super init];
    
    if (self) {
        
        // Custom initialization
        self.discoveredPeripherals = [[NSMutableArray alloc] init];
        self.BLEObservers = [[NSMutableArray alloc]init];
        
    }
    return self;
    
}
#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"[BLESMasterViewController] CBCentralManagerStatePoweredOn");
            
            [_cbCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FF30"]] options:nil];    // do scan for peripheral
            break;
            
        default:
            NSLog(@"[BLESMasterViewController] CBCentralManagerStateUnknown");
            
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"[%@] is discovered.", peripheral.name);
    
    if (![self.discoveredPeripherals containsObject:peripheral]) {
        
        [self.discoveredPeripherals insertObject:peripheral atIndex:0];
        
        for (id<BLEOberver>observer in self.BLEObservers) {
            if ([observer respondsToSelector:@selector(didDiscoverPeripheral:)])
                [observer didDiscoverPeripheral:peripheral];
        }
    }
    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"[AppDelegate] didConnectPeripheral %@", peripheral.name);
    
    for (id<BLEOberver>observer in self.BLEObservers) {
        if ([observer respondsToSelector:@selector(didConnectPeripheral:)])
            [observer didConnectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"[AppDelegate] didDisconnectPeripheral %@, error:%@", peripheral.name, error.description);
    
    for (id<BLEOberver>observer in self.BLEObservers) {
        if ([observer respondsToSelector:@selector(didDisconnectPeripheral:error:)])
            [observer didDisconnectPeripheral:peripheral error:error.localizedDescription];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"[AppDelegate] didFailToConnectPeripheral %@, error:%@", peripheral.name, error.description);
    
    for (id<BLEOberver>observer in self.BLEObservers) {
        if ([observer respondsToSelector:@selector(didFailToConnectPeripheral:error:)])
            [observer didFailToConnectPeripheral:peripheral error:error.localizedDescription];
    }
}

#pragma mark applicaion's life cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    _cbCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
