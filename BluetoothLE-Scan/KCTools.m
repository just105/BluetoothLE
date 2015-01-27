//
//  KCTools.m
//  BluetoothLE-Connect
//
//  Created by CHANGHUNG-WEI on 2014/12/25.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import "KCTools.h"
#import <CoreBluetooth/CoreBluetooth.h>



@implementation KCTools

@end

//=======================================
@implementation CBUUID (StringExtraction)

- (NSString *)representativeString;
{
    NSData *data = [self data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

@end
//=======================================

@implementation CBPeripheral (SmartServiceGet)

-(CBService*) simpleKeyService
{
    return [self serviceByUUID:UUID_SERVICE_SIMPLE_KEY];
}

-(CBService*) batteryService
{
    return [self serviceByUUID:UUID_SERVICE_BATTERY];
}

-(CBService*) linkLossService
{
    return [self serviceByUUID:UUID_SERVICE_LINKLOSS];
}

-(CBService*) immediateAlertService
{
    return [self serviceByUUID:UUID_SERVICE_IMMEDIATE_ALERT];
}

-(CBService*) txPowerService
{
    return [self serviceByUUID:UUID_SERVICE_TX_POWER];
}


- (CBService*) serviceByUUID:(NSString*)strUUID
{
    NSLog(@"self.services = %@",self.services);
    for (CBService *s in self.services) {
        if ([[s.UUID representativeString] isEqual:strUUID]) {
            return s;
        }
    }
    return nil;
}

@end
