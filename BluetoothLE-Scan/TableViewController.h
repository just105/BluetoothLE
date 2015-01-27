//
//  TableViewController.h
//  BluetoothLE-Connect
//
//  Created by CHANGHUNG-WEI on 2014/12/25.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCTools.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TableViewController : UITableViewController <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (nonatomic,strong) CBCentralManager *CM;
@property(readonly, nonatomic) CFUUIDRef UUID;

@end
