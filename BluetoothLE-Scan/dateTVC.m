//
//  DetailViewController.m
//
//
//  Created by  on 2014/5/10.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "NameTVC.h"
#import "AppDelegate.h"
#import "dateTVC.h"
#import "KCTools.h"

#define INDEX_SHOW_PIN_CODE     0
#define INDEX_CLEAR_DATA        1
#define INDEX_TIME_SYNC         2
#define INDEX_GET_INITIAL_TIME  3
#define INDEX_SHIPPMODE         4
#define INDEX_TODAY_STEP        5



@interface dateTVC () <BLEOberver, UITableViewDelegate, CBPeripheralDelegate,KCNameInputViewControllerDelegate>
{
    IBOutlet UILabel *_labelUUID;
    IBOutlet UILabel *_labelName;
    IBOutlet UILabel *_labelBattery;
    IBOutlet UIButton *_btnConnect;
    IBOutlet UIButton *_btnDisconnect;
    
    IBOutlet UITextView *_messageView;
    
    NSString *_messageText;
    
    AppDelegate *_appDelegate;
    
    NSDateFormatter *_dateFormatter;
    
    UIAlertView *_alert;
    
    CBService *_sv0xFF30;
    CBCharacteristic *_ch0xFF30, *_ch0xFF31, *_ch0xFF32;
}
@end

@implementation dateTVC


#pragma mark - Managing the detail item

- (void)setCbPeripheral:(CBPeripheral *)newCbPeripheral
{
    if (_cbPeripheral != newCbPeripheral) {
        _cbPeripheral = newCbPeripheral;
        
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    [_btnDisconnect setEnabled:NO];
    
    _labelName.text = self.cbPeripheral.name ? self.cbPeripheral.name : @"(NULL)";
    _labelUUID.text = self.cbPeripheral.identifier.UUIDString;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _messageText = [[NSString alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = [UIApplication sharedApplication].delegate;
    [_appDelegate.BLEObservers addObject:self];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    _dateFormatter.dateFormat = @"HH:mm:ss";
    
    _messageView.editable = NO;
    
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"[DetailViewController] Peripheral's delegate = %p, self = %p", self.cbPeripheral.delegate, self);
    
    if (self.cbPeripheral) {
        if (self.cbPeripheral.delegate != self) {
            self.cbPeripheral.delegate = self;
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        self.cbPeripheral.delegate = nil;
        [self disconnect:nil];
        self.cbPeripheral = nil;
        [_appDelegate.BLEObservers removeObject:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
#if 0
    if ([identifier isEqualToString:@"customCmd"]) {
        
        if (self.cbPeripheral==nil | self.cbPeripheral.state != CBPeripheralStateConnected) {
            return NO;
        }
    }
#else
    if (self.cbPeripheral==nil | self.cbPeripheral.state != CBPeripheralStateConnected) {
        return NO;
    }
#endif
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
//    if ([[segue identifier] isEqualToString:@"customCmd"] ||
//        [[segue identifier] isEqualToString:@"getStepLog"]) {
//        
//        [[segue destinationViewController] setCbPeripheral:self.cbPeripheral];
//        
//        //        [[segue destinationViewController] setCbServiceFF30:_sv0xFF30];
//        //
//        //        [[segue destinationViewController] setCbCharactFF30:_ch0xFF30];
//        //        [[segue destinationViewController] setCbCharactFF31:_ch0xFF31];
//        //        [[segue destinationViewController] setCbCharactFF32:_ch0xFF32];
//    }
    id destination = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"pushName"]) {
        
        NSLog(@"pushName");
        [destination setName:_labelName.text delegate:self];
//                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//                CBPeripheral *peripheral = [_appDelegate.discoveredPeripherals objectAtIndex:indexPath.row];
//        
//                [[segue destinationViewController] setCbPeripheral:peripheral];
    }
}

#pragma mark - KCNameInputViewControllerDelegate

- (void)KCNameInputViewController:(NameTVC *)nameInputViewController finishWithName:(NSString *)newName
{
    if(![_labelName.text isEqualToString:newName]){
        _labelName.text = newName;
    }
}


#pragma mark - Actions
- (IBAction)connect:(id)sender
{
    NSLog(@"[DetailViewController] try to connect");
    
    if (self.cbPeripheral) {
        
        _btnConnect.enabled = NO;
        
        _alert = [[UIAlertView alloc]initWithTitle:nil message:@"Connecting..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        
        [_alert show];
        
        [_appDelegate.cbCentralManager connectPeripheral:self.cbPeripheral options:nil];
        
        [self performSelector:@selector(requestTimeout) withObject:nil afterDelay:6.0];
    }
}

- (IBAction)disconnect:(id)sender
{
    NSLog(@"[DetailViewController] disconnect");
    
    if (self.cbPeripheral && self.cbPeripheral.state == CBPeripheralStateConnected) {
        
        _btnDisconnect.enabled = NO;
        [_appDelegate.cbCentralManager cancelPeripheralConnection:self.cbPeripheral];
    }
}
- (IBAction)helpBtn:(id)sender
{
    Byte val = 0;
    
    NSData *d = [[NSData alloc] initWithBytes:&val length:1];
    
    CBCharacteristic *charact = [self.cbPeripheral.immediateAlertService.characteristics objectAtIndex:0];
    if (charact) {
        [self.cbPeripheral writeValue:d forCharacteristic:charact type:CBCharacteristicWriteWithoutResponse];
    }
}

#pragma mark - CBCentralManagerObserver
- (void) didConnectPeripheral:(CBPeripheral*)peripheral
{
    NSLog(@"[DetailViewController] didConnectPeripheral");
    
    [self postMessage:@"Connected."];
    
    if (_alert.isVisible) {
        [_alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    _btnDisconnect.enabled = YES;
    
    peripheral.delegate = self;
    
    // Discover service for 0xFF30, Battery
    CBUUID *uuid0xFF30  = [CBUUID UUIDWithString:@"FF30"];
    CBUUID *uuidBatteryService = [CBUUID UUIDWithString:@"180F"];
    [peripheral discoverServices:@[uuid0xFF30, uuidBatteryService]];
    
    
}

- (void) didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSString*)errorMessage
{
    NSLog(@"[DetailViewController] didDisconnectPeripheral");
    
    if (errorMessage){
        [self postMessage:errorMessage];
        _btnDisconnect.enabled = NO;
    }
    
    _btnConnect.enabled = YES;
    
    [self postMessage:[NSString stringWithFormat:@"Disconnected. (%@)", errorMessage == nil? @"No Error" : errorMessage]];
    
}

- (void) didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSString *)errorMessage
{
    NSLog(@"[DerailViewController] didFailToConnectPeripheral");
    
    [self postMessage:errorMessage];
    
    if (_alert.isVisible) {
        [_alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    _btnConnect.enabled = YES;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        switch (indexPath.row) {
                
            case INDEX_SHOW_PIN_CODE:
                
                [self showPinCode];
                
                break;
                
            case INDEX_CLEAR_DATA:
                
                [self clearData];
                
                break;
                
            case INDEX_TIME_SYNC:
                
                [self timeSync];
                
                break;
                
            case INDEX_SHIPPMODE:
                
                [self shippingMode];
                
                break;
                
            case INDEX_TODAY_STEP:
                
                [self todayStep];
                
                break;
                
            case INDEX_GET_INITIAL_TIME:
                
                [self getInitTime];
                
                break;
                
                
            default:
                break;
        }
        
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    for (CBService *service in peripheral.services) {
        
        if ([service.UUID.UUIDString isEqualToString:@"FF30"]) {
            
            // discover characteristices 0xFF30, 0xFF31, 0xFF32 for service 0xFF30
            
            CBUUID *uuid0xFF30  = [CBUUID UUIDWithString:@"FF30"];
            CBUUID *uuid0xFF31  = [CBUUID UUIDWithString:@"FF31"];
            CBUUID *uuid0xFF32  = [CBUUID UUIDWithString:@"FF32"];
            
            [peripheral discoverCharacteristics:@[uuid0xFF30, uuid0xFF31, uuid0xFF32] forService:service];
            
        }
        else if([service.UUID.UUIDString isEqualToString:@"180F"]) {
            
            // Battery Service
            
            CBUUID *uuid0x2A19 = [CBUUID UUIDWithString:@"2A19"];
            
            [peripheral discoverCharacteristics:@[uuid0x2A19] forService:service];
        }
    }
    
    @try {
        
        if (peripheral.isConnected) {
            [peripheral discoverCharacteristics:@[CBUUID_CHARACT_BATTERY] forService:peripheral.batteryService];
            [peripheral discoverCharacteristics:@[CBUUID_CHARACT_IMMEDIATE_ALERT] forService:peripheral.immediateAlertService];
            [peripheral discoverCharacteristics:@[CBUUID_CHARACT_SIMPLEKEY] forService:peripheral.simpleKeyService];
            [peripheral discoverCharacteristics:@[CBUUID_CHARACT_TX_POWER] forService:peripheral.txPowerService];
            
        }
        else{
            NSLog(@"[KCKeychain] didDiscoverServices, but peripheral was disconnected.");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"[KCKeychain] exception occur!");
    }
    @finally {
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID.UUIDString isEqualToString:@"FF30"]) {
        
        for (CBCharacteristic *ch in service.characteristics) {
            
            if([ch.UUID.UUIDString isEqualToString:@"FF30"]){
                _ch0xFF30 = ch;
            }
            else if ([ch.UUID.UUIDString isEqualToString:@"FF31"]){
                _ch0xFF31 = ch;
            }
            else if ([ch.UUID.UUIDString isEqualToString:@"FF32"]){
                _ch0xFF32 = ch;
            }
        }
    }
    else if([service.UUID.UUIDString isEqualToString:@"180F"]) {
        
        for (CBCharacteristic *ch in service.characteristics) {
            
            if([ch.UUID.UUIDString isEqualToString:@"2A19"]){
                
                // set Notify for battery value update.
                
                [self.cbPeripheral setNotifyValue:YES forCharacteristic:ch];
                
                // read battery value.
                
                [self.cbPeripheral readValueForCharacteristic:ch];
            }
        }
    }
    
    @try {
        if ([[service.UUID representativeString] isEqual:UUID_SERVICE_BATTERY]) {
            // set notify .
            [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics objectAtIndex:0]];
            
            // read battery value.
            [peripheral readValueForCharacteristic:[service.characteristics objectAtIndex:0]];
            NSLog(@"[KCKeychain] UUID_SERVICE_BATTERY:%@ is discovered.", [service.UUID representativeString]);
            
        }
        else if([[service.UUID representativeString] isEqual:UUID_SERVICE_SIMPLE_KEY]){
            
            // set notify if any key state changed.
            [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics objectAtIndex:0]];
            NSLog(@"[KCKeychain] UUID_CHARACT_SIMPLEKEY:%@ is discovered.", [service.UUID representativeString]);
            
        }
        else if([[service.UUID representativeString] isEqual:UUID_SERVICE_IMMEDIATE_ALERT]){
            
            NSLog(@"[KCKeychain] UUID_CHARACT_IMMEDIATE_ALERT:%@ is discovered.", [service.UUID representativeString]);
        }
        else if([[service.UUID representativeString] isEqual:UUID_SERVICE_TX_POWER]){
            [peripheral readValueForCharacteristic:[service.characteristics objectAtIndex:0]];
            NSLog(@"[KCKeychain] UUID_CHARACT_TX_POWER:%@ is discovered.", [service.UUID representativeString]);
        }
        
        else{
            NSLog(@"[KCKeychain] unknow charact:%@ is discovered.", [service.UUID representativeString]);
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"[KCKeychain] exception occur!");
    }
    @finally {
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *message = nil;
    if (error) {
        NSLog(@"[didUpdateNotificationStateForCharacteristic] error:%@", error);
        
        message = [NSString stringWithFormat:@"%@ setNotify error:%@", characteristic.UUID.UUIDString, error];
    }
    else{
        
        message = [NSString stringWithFormat:@"%@ setNotify successful.", characteristic.UUID.UUIDString];
    }
    
    [self postMessage:message];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [peripheral readValueForCharacteristic:_ch0xFF31];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    Byte *data = alloca(characteristic.value.length);
    memset(data, 0x00, characteristic.value.length);
    
    [characteristic.value getBytes:data length:characteristic.value.length];
    if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
        
        NSString *msgBettery = [NSString stringWithFormat:@"Battery Value is Updated:%d%%", data[0]];
        [self postMessage:msgBettery];
        
        _labelBattery.text = [NSString stringWithFormat:@"%d%%", data[0]];
    }
    else{
        
        NSString *message = [NSString stringWithFormat:@"Response %lu bytes:\n       ", (unsigned long)characteristic.value.length];
        
        for (int i=0; i<characteristic.value.length; i++) {
            
            NSString *byte = [NSString stringWithFormat:@"%02X ", data[i]];
            message = [message stringByAppendingString:byte];
        }
        
        [self postMessage:message];
        
        switch (data[1]) {
            case 0x05:
                
                if (data[2] == 0x01)
                    [self postMessage:@"Time Sync is OK!!"];
                else
                    [self postMessage:@"Time Sync is fail!!"];
                
                break;
            case 0x22:
                
                [self postMessage:@"Clear Data is OK!!"];
                
                break;
                
            case 0xa0:
                
                if (data[2]==0x02) {
                    [self postMessage:@"Shipping Mode is fail!!"];
                }
                
                break;
                
            case 0x14:
                
                if (data[2] == 0x01) {
                    [self postMessage:@"Show Pin Code is ok!"];
                }
                else{
                    [self postMessage:@"Show Pin Code is fail!"];
                }
                
                break;
                
            case 0x20:
                
                if (data[2] == 0x01) {
                    
                    NSString *message = [NSString stringWithFormat:@"Initial Time: 20%02d-%02d-%02d %02d:%02d", data[3], data[4], data[5], data[6], data[7]];
                    
                    [self postMessage:message];
                }
                else{
                    [self postMessage:@"Initial Time: format mismatch!"];
                }
                
                
                
                break;
            default:
                break;
        }
        
    }
    
}

#pragma mark - Others

- (void) requestTimeout
{
    if (self.cbPeripheral.state != CBPeripheralStateConnected && _alert.isVisible) {
        [_alert dismissWithClickedButtonIndex:0 animated:YES];
        [_appDelegate.cbCentralManager cancelPeripheralConnection:self.cbPeripheral];
        
        [self postMessage:@"Request is timeout."];
    }
}

- (void) postMessage:(NSString*)message
{
    if(!_messageText)
        _messageText = [[NSString alloc]init];
    
    _messageText = [_messageText stringByAppendingString:[self messageWithTime:message]];
    
    _messageView.text = _messageText;
    
    if (_messageView.text.length) {
        NSRange bottom = NSMakeRange(_messageView.text.length -1, 1);
        [_messageView scrollRangeToVisible:bottom];
    }
}

- (NSString*) messageWithTime:(NSString*)message
{
    NSString *now = [_dateFormatter stringFromDate:[NSDate date]];
    NSString *newMessage = [NSString stringWithFormat:@"[%@] %@\n",now, message];
    
    return newMessage;
}

- (void) timeSync
{
    
    if( !self.cbPeripheral || self.cbPeripheral.state != CBPeripheralStateConnected){
        return;
    }
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    dateFormatter.dateFormat = @"y/MM/d - HH:mm:ss";
    NSString *message = [NSString stringWithFormat:@"Set time to %@",[dateFormatter stringFromDate:now]];
    [self postMessage:message];
    
    
    dateFormatter.dateFormat = @"y:MM:d:HH:mm:ss";
    NSArray *aryString = [[dateFormatter stringFromDate:now] componentsSeparatedByString:@":"];
    
    const int LENGTH = 8;
    Byte data[LENGTH];
    
    data[0] = 0xc5;
    data[1] = 0x05;
    
    int i=2;
    
    NSString *messageWritenBytes = [NSString stringWithFormat:@"Write %d bytes:\n       %02X %02X ", LENGTH, data[0], data[1]];
    
    for (NSString *str in aryString) {
        
        Byte byt;
        
        if (i==2) {
            byt =[str intValue]%100;   // 2014 -> 14
            
            NSLog(@"year : %@, %d, %x", str, [str intValue]%100, [str intValue]%100);
        }
        else{
            byt =[str intValue];
        }
        
        data[i++] = byt;
        
        NSString *strByte =[NSString stringWithFormat:@"%02X ", byt];
        messageWritenBytes = [messageWritenBytes stringByAppendingString:strByte];
    }
    
    NSData *cmd = [NSData dataWithBytes:&data length:LENGTH];
    [_cbPeripheral writeValue:cmd forCharacteristic:_ch0xFF30 type:CBCharacteristicWriteWithResponse];
    
    [self postMessage:messageWritenBytes];
    
}

- (void) todayStep
{
    if( !self.cbPeripheral || self.cbPeripheral.state != CBPeripheralStateConnected){
        return;
    }
    
    const int LENGTH = 2;
    Byte data[LENGTH];
    
    data[0] = 0xc5;
    data[1] = 0x30;
    
    NSData *cmd = [NSData dataWithBytes:&data length:LENGTH];
    [_cbPeripheral writeValue:cmd forCharacteristic:_ch0xFF30 type:CBCharacteristicWriteWithResponse];
    
    NSString *messageWritenBytes = [NSString stringWithFormat:@"Write %d bytes:\n       %02X %02X", LENGTH, data[0], data[1]];
    
    [self postMessage:messageWritenBytes];
    
}

- (void) clearData
{
    if( !self.cbPeripheral || self.cbPeripheral.state != CBPeripheralStateConnected){
        return;
    }
    
    const int LENGTH = 3;
    Byte data[LENGTH];
    
    data[0] = 0xc5;
    data[1] = 0x22;
    data[2] = 0x69;
    
    NSData *cmd = [NSData dataWithBytes:&data length:LENGTH];
    [_cbPeripheral writeValue:cmd forCharacteristic:_ch0xFF30 type:CBCharacteristicWriteWithResponse];
    
    NSString *messageWritenBytes = [NSString stringWithFormat:@"Write %d bytes:\n       %02X %02X %02X", LENGTH, data[0], data[1], data[2]];
    
    [self postMessage:messageWritenBytes];
    
}


- (void) shippingMode
{
    if( !self.cbPeripheral || self.cbPeripheral.state != CBPeripheralStateConnected){
        return;
    }
    
    const int LENGTH = 7;
    Byte data[LENGTH];
    
    data[0] = 0xc5;
    data[1] = 0xa0;
    data[2] = 0x47;
    data[3] = 0x2d;
    data[4] = 0x73;
    data[5] = 0x61;
    data[6] = 0x74;
    
    NSData *cmd = [NSData dataWithBytes:&data length:LENGTH];
    [_cbPeripheral writeValue:cmd forCharacteristic:_ch0xFF30 type:CBCharacteristicWriteWithResponse];
    
    NSString *messageWritenBytes = [NSString stringWithFormat:@"Write %d bytes:\n       %02X %02X %02X %02X %02X %02X %02X", LENGTH, data[0], data[1], data[2], data[3], data[4], data[5], data[6] ];
    
    [self postMessage:messageWritenBytes];
}


- (void) showPinCode
{
    if( !self.cbPeripheral || self.cbPeripheral.state != CBPeripheralStateConnected){
        return;
    }
    
    const int LENGTH = 6;
    Byte data[LENGTH];
    
    data[0] = 0xc5;
    data[1] = 0x14;
    data[2] = 0x38;
    data[3] = 0x38;
    data[4] = 0x38;
    data[5] = 0x38;
    
    NSData *cmd = [NSData dataWithBytes:&data length:LENGTH];
    [_cbPeripheral writeValue:cmd forCharacteristic:_ch0xFF30 type:CBCharacteristicWriteWithResponse];
    
    NSString *messageWritenBytes = [NSString stringWithFormat:@"Write %d bytes:\n       %02X %02X %02X %02X %02X %02X", LENGTH, data[0], data[1], data[2], data[3], data[4], data[5]];
    
    [self postMessage:messageWritenBytes];
}

- (void) getInitTime
{
    if( !self.cbPeripheral || self.cbPeripheral.state != CBPeripheralStateConnected){
        return;
    }
    
    const int LENGTH = 2;
    Byte data[LENGTH];
    
    data[0] = 0xc5;
    data[1] = 0x20;
    
    NSData *cmd = [NSData dataWithBytes:&data length:LENGTH];
    [_cbPeripheral writeValue:cmd forCharacteristic:_ch0xFF30 type:CBCharacteristicWriteWithResponse];
    
    NSString *messageWritenBytes = [NSString stringWithFormat:@"Write %d bytes:\n       %02X %02X", LENGTH, data[0], data[1]];
    
    [self postMessage:messageWritenBytes];
    
}
@end
