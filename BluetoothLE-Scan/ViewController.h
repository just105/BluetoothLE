//
//  ViewController.h
//  BluetoothLE-Scan
//
//  Created by danny on 2014/1/21.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate> {
    
}

@property (nonatomic,strong) CBCentralManager *CM;
@property(readonly, nonatomic) CFUUIDRef UUID;

@property (strong, nonatomic) CBPeripheral * VCconnectPeripheral;

- (IBAction)buttonScanAndConnect:(id)sender;
- (IBAction)buttonStop:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
