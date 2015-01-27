//
//  KCTools.h
//  BluetoothLE-Connect
//
//  Created by CHANGHUNG-WEI on 2014/12/25.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define kDeviceWidth  [UIScreen mainScreen].bounds.size.width

#define UUID_SERVICE_IMMEDIATE_ALERT    @"1802"
#define UUID_SERVICE_LINKLOSS           @"1803"
#define UUID_SERVICE_BATTERY            @"180f"
#define UUID_SERVICE_SIMPLE_KEY         @"ffe0"
#define UUID_SERVICE_TX_POWER           @"1804"


#define CBUUID_SERVICE_BATTERY          [CBUUID UUIDWithString:UUID_SERVICE_BATTERY]
#define CBUUID_SERVICE_LINKLOSS         [CBUUID UUIDWithString:UUID_SERVICE_LINKLOSS]
#define CBUUID_SERVICE_SIMPLE_KEY       [CBUUID UUIDWithString:UUID_SERVICE_SIMPLE_KEY]
#define CBUUID_SERVICE_IMMEDIATE_ALERT  [CBUUID UUIDWithString:UUID_SERVICE_IMMEDIATE_ALERT]
#define CBUUID_SERVICE_TX_POWER       [CBUUID UUIDWithString:UUID_SERVICE_TX_POWER]

#define EXCEPTED_SERVICE_CBUUIDS @[CBUUID_SERVICE_BATTERY, CBUUID_SERVICE_SIMPLE_KEY, CBUUID_SERVICE_IMMEDIATE_ALERT,CBUUID_SERVICE_TX_POWER]

#define UUID_CHARACT_BATTERY               @"2a19"
#define UUID_CHARACT_IMMEDIATE_ALERT       @"2a06"
#define UUID_CHARACT_SIMPLEKEY             @"ffe1"
#define UUID_CHARACT_TX_POWER              @"2a07"

#define CBUUID_CHARACT_BATTERY             [CBUUID UUIDWithString:UUID_CHARACT_BATTERY]
#define CBUUID_CHARACT_IMMEDIATE_ALERT     [CBUUID UUIDWithString:UUID_CHARACT_IMMEDIATE_ALERT]
#define CBUUID_CHARACT_SIMPLEKEY           [CBUUID UUIDWithString:UUID_CHARACT_SIMPLEKEY]
#define CBUUID_CHARACT_TX_POWER            [CBUUID UUIDWithString:UUID_CHARACT_TX_POWER]

#define CFUUID_TO_NSSTRING(x)   (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, x));

@interface KCTools : NSObject

@end

@interface CBUUID (StringExtraction)

- (NSString *)representativeString;

@end

@interface CBPeripheral (SmartServiceGet)

@property (readonly, nonatomic) CBService *batteryService;
@property (readonly, nonatomic) CBService *simpleKeyService;
@property (readonly, nonatomic) CBService *immediateAlertService;
@property (readonly, nonatomic) CBService *linkLossService;
@property (readonly, nonatomic) CBService *txPowerService;

@end
