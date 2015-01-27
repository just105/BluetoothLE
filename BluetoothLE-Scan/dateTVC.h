//
//  dateTVC.h
//  BluetoothLE-Connect
//
//  Created by CHANGHUNG-WEI on 2014/12/25.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;

@interface dateTVC : UITableViewController

@property (strong, nonatomic) CBPeripheral *cbPeripheral;

@end
