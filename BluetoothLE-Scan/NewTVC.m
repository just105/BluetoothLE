//
//  NewTVC.m
//  BluetoothLE-Connect
//
//  Created by CHANGHUNG-WEI on 2014/12/25.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import "NewTVC.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "AppDelegate.h"
#import "dateTVC.h"

@interface NewTVC ()
<BLEOberver>
{
    AppDelegate *_appDelegate;
}

@end

@implementation NewTVC

#pragma mark - UIViewController's life cycle
- (void)awakeFromNib
{
    [super awakeFromNib];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_appDelegate.BLEObservers addObject:self];
}

- (IBAction)scan:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Scanning.." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alertView show];
    
    // stop scan.
    [_appDelegate.cbCentralManager stopScan];
    
    // clear old peripherals and remove all cells on tableview.
    [_appDelegate.discoveredPeripherals removeAllObjects];
    [self.tableView reloadData];
    
    // hide alertview after 1 sec.
    [self performSelector:@selector(hideAlertView:) withObject:alertView afterDelay:1.0];
    
    // re-scan for peripherals
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [_appDelegate.cbCentralManager scanForPeripheralsWithServices:nil options:dic];
}

- (IBAction)stop:(id)sender
{
    NSLog(@"按停止沒事情。");
}

#pragma mark - UIAlertView

- (void) hideAlertView:(UIAlertView*)alertView
{
    if (alertView.isVisible) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _appDelegate.discoveredPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    CBPeripheral *peripheral = _appDelegate.discoveredPeripherals[indexPath.row];
    
    // Device Name
    cell.textLabel.text = peripheral.name;
    
    // UUID
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", peripheral.identifier.UUIDString];
    
    
    return cell;
}

#pragma UIStoryboardSegue 傳值到下一頁

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CBPeripheral *peripheral = [_appDelegate.discoveredPeripherals objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] setCbPeripheral:peripheral];
    }
}

#pragma BLEObserver
- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
