//
//  ViewController.m
//  BluetoothLE-Connect
//
//  Created by danny on 2014/04/1.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import "ViewController.h"
#import "KCTools.h"

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

@interface ViewController () {
    CBPeripheral *connectPeripheral;
}
@end



@implementation ViewController
@synthesize CM;
@synthesize UUID;
@synthesize textView;
@synthesize VCconnectPeripheral;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CM= [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
//    
//    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 120, kDeviceWidth, kDeviceHeight)];
//    scroll.contentSize = CGSizeMake(kDeviceWidth, kDeviceHeight);
//    [self.view addSubview:scroll];
    
//    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 150, 300, 400)];
//    _textView.editable = NO;
//    [self.view addSubview:_textView];
    
}

//textView更新
-(void)updateLog:(NSString *)s
{
    static unsigned int count = 0;
    [textView setText:[NSString stringWithFormat:@"[ %d ]  %@\r\n%@",count,s,textView.text]];
    count++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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



- (IBAction)buttonScanAndConnect:(id)sender {
    
    [CM stopScan];
    [CM scanForPeripheralsWithServices:nil options:nil];
//    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];
    [self updateLog:@"掃描服务"];
    
}

- (void) scanTimeout:(NSTimer*)timer
{
    if (CM!=NULL){
        [CM stopScan];
    }else{
        NSLog(@"CM is Null!");
    }
    
}

- (IBAction)buttonStop:(id)sender {
    
    [CM stopScan];
    [self updateLog:@"掃描停止"];
    [CM cancelPeripheralConnection:VCconnectPeripheral];
    if (connectPeripheral == NULL){
        NSLog(@"connectPeripheral == NULL");
        return;
    }
    
    if (connectPeripheral.state == CBPeripheralStateConnected) {
        [CM cancelPeripheralConnection:connectPeripheral];
        NSLog(@"disconnect-1");

    }
/*
    if ([connectPeripheral isConnected]) {
        [CM cancelPeripheralConnection:connectPeripheral];
        NSLog(@"disconnect-1");
    }
*/
}

- (IBAction)buttonlllll:(id)sender {
    NSLog(@"VCconnectPeripheral = %@",VCconnectPeripheral);
    [CM scanForPeripheralsWithServices:nil options:nil];
    
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    int rssi = abs([peripheral.RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"距离:%.1fm",pow(10,ci)];
    
    [self updateLog:[NSString stringWithFormat:@"!!成功连接!!  \n peripheral: %@ \n advertisementData \n %@ \n with UUID: %@  \n RSSI: %@  \n 換算距離: %@",peripheral,advertisementData,peripheral.UUID,RSSI,length]];

    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
//
    NSLog(@"進行連接中");
    //if ([peripheral.name length] && [peripheral.name rangeOfString:@"DannySimpleBLE"].location != NSNotFound) {
    if ([localName length] && [localName rangeOfString:VCconnectPeripheral.name].location != NSNotFound) {
        //抓到週邊後就立即停子Scan
        [CM stopScan];
        [self updateLog:[NSString stringWithFormat:@"connectPeripheral.name = %@",VCconnectPeripheral.name]];
        connectPeripheral = VCconnectPeripheral;
        [CM connectPeripheral:VCconnectPeripheral options:nil];
        NSLog(@"connect to %@",peripheral.name);
    }
}

//這是在連線成功後就會引發的Delegate，但一定要在這裡執行一些Method才可以順利的引發另一個CBPeripheral的Delegate去查看有什麼樣的Services
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self updateLog:@"連線成功呼叫delegate"];
    peripheral.delegate=self;
    [peripheral discoverServices:nil];//一定要執行"discoverService"功能去尋找可用的Service
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self updateLog:@"斷線"];
    NSLog(@"斷線 disconnect-2 = %@",peripheral);
}


//接下來進行peripheral的任何動做引發的Delegate都在這個Object中，執行discoverServicesMethod，讓它去尋找Services，一找到Services就又會引發didDiscoverServicesDelegate，這樣我們就可以了解有什麼Services。
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices:\n");
    if( peripheral.UUID == NULL  ) return; // zach ios6 added
    if (!error) {
        [self updateLog:[NSString stringWithFormat:@"====名稱 %@\n",peripheral.name]];
        NSLog(@"====名稱 %@\n",peripheral.name);
        [self updateLog:[NSString stringWithFormat:@"=========== %lu of service for UUID %@ ===========\n",(unsigned long)peripheral.services.count,CFUUIDCreateString(NULL,peripheral.UUID)]];
        NSLog(@"=========== %lu of service for UUID %@ ===========\n",(unsigned long)peripheral.services.count,CFUUIDCreateString(NULL,peripheral.UUID));
        
        for (CBService *p in peripheral.services){
            [self updateLog:[NSString stringWithFormat:@"Service found with UUID: %@\n", p.UUID]];
            NSLog(@"Service found with UUID: %@\n", p.UUID);
            [peripheral discoverCharacteristics:nil forService:p];
        }
        [self updateLog:@"==================================================="];
        NSLog(@"===================================================");
    }
    else {
        [self updateLog:@"Service discovery was unsuccessfull !\n"];
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
        [self updateLog:[NSString stringWithFormat:@"信号%@",value]];
        NSLog(@"信号%@",value);
    }
    
}

@end
