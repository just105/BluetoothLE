//
//  TableViewController.m
//  BluetoothLE-Connect
//
//  Created by CHANGHUNG-WEI on 2014/12/25.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"
@interface TableViewController (){
    CBPeripheral * connectPeripheral;
    NSMutableArray *_aryDiscoveredPeripheral;
}

@end

@implementation TableViewController
@synthesize CM;
@synthesize UUID;

- (id) initWithKeychains:(NSMutableArray *)keychains
{
    self = [super init];
    if (self) {
        
        // configure the CBCentralManager
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _aryDiscoveredPeripheral = [[NSMutableArray alloc]init];
    
    CM= [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - itemBtn按鈕

- (IBAction)scan:(id)sender {
    [CM stopScan];
    [CM scanForPeripheralsWithServices:nil options:nil];
    NSLog(@"搜尋週邊配備");
}

- (IBAction)stop:(id)sender {
    NSLog(@"停止搜尋");
    [CM stopScan];
    
    if (connectPeripheral == NULL){
        NSLog(@"connectPeripheral == NULL");
        return;
    }
    
    if (connectPeripheral.state == CBPeripheralStateConnected) {
        [CM cancelPeripheralConnection:connectPeripheral];
        NSLog(@"disconnect-1");
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"[_aryDiscoveredPeripheral count] = %lu",(unsigned long)[_aryDiscoveredPeripheral count]);
    return [_aryDiscoveredPeripheral count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];    }
    // Configure the cell...
    CBPeripheral *dictionary = [_aryDiscoveredPeripheral objectAtIndex:indexPath.row];
    if (dictionary) {
        NSLog(@"dictionary = %@",dictionary.name);
        CGFloat Y = (100-22)/2;
        UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(10, Y, 200, 22)];
        [title setText:dictionary.name];
        [cell addSubview:title];
        
        int rssi = abs([dictionary.RSSI intValue]);
        CGFloat ci = (rssi - 49) / (10 * 4.);
        NSString * length = [NSString stringWithFormat:@"距離:%.1fm",pow(10,ci)];
        
        UILabel * lengthla = [[UILabel alloc]initWithFrame:CGRectMake(220, Y, 80, 22)];
        [lengthla setText:length];
        [cell addSubview:lengthla];
        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showAbout" sender:self];
    //    CBPeripheral * dictionary = [_aryDiscoveredPeripheral objectAtIndex:indexPath.row];
    //    connectPeripheral = dictionary;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    CBPeripheral * dictionary = [_aryDiscoveredPeripheral objectAtIndex:indexPath.row];
    ViewController *detailViewController = (ViewController*) segue.destinationViewController;
    NSLog(@"dictionary = %@",dictionary);
    detailViewController.VCconnectPeripheral = dictionary;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Ble用

-(void)centralManagerDidUpdateState:(CBCentralManager*)cManager
{
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"UpdateState:"];
    BOOL isWork=FALSE;
    switch (cManager.state) {
        case CBCentralManagerStateUnknown:
            [nsmstring appendString:@"Unknown\n"];
            break;
        case CBCentralManagerStateUnsupported:
            [nsmstring appendString:@"Unsupported\n"];
            break;
        case CBCentralManagerStateUnauthorized:
            [nsmstring appendString:@"Unauthorized\n"];
            break;
        case CBCentralManagerStateResetting:
            [nsmstring appendString:@"Resetting\n"];
            break;
        case CBCentralManagerStatePoweredOff:
            [nsmstring appendString:@"PoweredOff\n"];
            break;
        case CBCentralManagerStatePoweredOn:
            [nsmstring appendString:@"PoweredOn\n"];
            isWork=TRUE;
            break;
        default:
            [nsmstring appendString:@"none\n"];
            break;
    }
    NSLog(@"%@",nsmstring);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    int rssi = abs([peripheral.RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"距离:%.1fm",pow(10,ci)];
    
    if([_aryDiscoveredPeripheral containsObject:peripheral]){
        return;
    }
    else{
        [_aryDiscoveredPeripheral addObject:peripheral];
        [self.tableView reloadData];
    }
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    NSLog(@"peripheral \n %@ \n localName = %@  length = %@",peripheral,peripheral.name,length);
    //if ([peripheral.name length] && [peripheral.name rangeOfString:@"DannySimpleBLE"].location != NSNotFound) {
    //    if ([localName length] && [localName rangeOfString:@"GlobalSat Key Chain"].location != NSNotFound) {
    //        //抓到週邊後就立即停子Scan
    //        [CM stopScan];
    //        connectPeripheral = peripheral;
    //        [CM connectPeripheral:peripheral options:nil];
    //        NSLog(@"connect to %@",peripheral.name);
    //    }
}

//這是在連線成功後就會引發的Delegate，但一定要在這裡執行一些Method才可以順利的引發另一個CBPeripheral的Delegate去查看有什麼樣的Services
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    peripheral.delegate=self;
    [peripheral discoverServices:nil];//一定要執行"discoverService"功能去尋找可用的Service
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([_aryDiscoveredPeripheral containsObject:peripheral]) {
        [_aryDiscoveredPeripheral removeObject:peripheral];
    }
    NSLog(@"斷線 disconnect-2 = %@",peripheral);
}


//接下來進行peripheral的任何動做引發的Delegate都在這個Object中，執行discoverServicesMethod，讓它去尋找Services，一找到Services就又會引發didDiscoverServicesDelegate，這樣我們就可以了解有什麼Services。
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices:\n");
    if( peripheral.UUID == NULL  ) return; // zach ios6 added
    if (!error) {
        NSLog(@"====名稱 %@\n",peripheral.name);
        NSLog(@"=========== %lu of service for UUID %@ ===========\n",(unsigned long)peripheral.services.count,CFUUIDCreateString(NULL,peripheral.UUID));
        
        for (CBService *p in peripheral.services){
            NSLog(@"Service found with UUID: %@\n", p.UUID);
            [peripheral discoverCharacteristics:nil forService:p];
        }
        NSLog(@"===================================================");
    }
    else {
        
        NSLog(@"Service discovery was unsuccessfull !\n");
    }
    
}


//每個Servic下都會有很多的Characteristics，Characteristics是提供資料傳遞的重點，它會有個UUID編號，再由這個編號去Bluetooth 官方查表得到是哪種資料格式，知道格式後就能去將資料解開並加以使用。
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
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

//didUpdateValueForCharacteristic在連線完成後對於數據資得的取得顯的非常重要
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"[KCKEychain] didUpdateValueForCharacteristic UUID=%@", [characteristic.UUID representativeString]);
    
    // get the date bytes of updated value.
    const int length= characteristic.value.length;
    char *data = alloca(length);
    memset(data, 0x00, length);
    [characteristic.value getBytes:data length:characteristic.value.length];
    
    const int value = data[0];
    
    if ([[characteristic.UUID representativeString] isEqual:UUID_CHARACT_BATTERY]) {
        //        self.battery = value;
        NSLog(@"UUID_CHARACT_BATTERY = %d",value);
        
        // Battery Service
        //        for ( id<KCKeychainObserver> observer in self.observers) {
        //            [observer battery:value keychain:self];
        //        }
    }
    else if([[characteristic.UUID representativeString] isEqual:UUID_CHARACT_SIMPLEKEY]){
        NSLog(@"UUID_CHARACT_SIMPLEKEY = %d",value);
        // Simple Keys Service
        //        for ( id<KCKeychainObserver> observer in self.observers) {
        //            [observer simpleKey:value keychain:self];
        //        }
    }
    else if([[characteristic.UUID representativeString] isEqual:UUID_CHARACT_TX_POWER]){
        if( 0 == value)
            //            self.alertDistance = AlertDistanceLarge;
            NSLog(@"0");
        else
            NSLog(@"1");
        //            self.alertDistance = AlertDistanceMiddle;
        
        // TX Power Service
        //        for ( id<KCKeychainObserver> observer in self.observers) {
        //            [observer txPower:value keychain:self];
        //        }
    }
    if ([[characteristic.UUID representativeString] isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        //_batteryValue = [value floatValue];
        NSLog(@"信号%@",value);
    }
    
}

@end
