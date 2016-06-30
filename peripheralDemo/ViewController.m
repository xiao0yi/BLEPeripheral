//
//  ViewController.m
//  peripheralDemo
//
//  Created by Mac chen on 16/5/2.
//  Copyright © 2016年 Mac chen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{

    if(peripheral.state != CBPeripheralManagerStatePoweredOn){
    
        return;
    }
    
    NSLog(@"蓝牙已打开");
    
    //初始化特征
    self.transferCharacteritic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERITIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    //初始化服务
    CBMutableService *transferservice = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
    
    //添加特征到服务
    transferservice.characteristics = @[self.transferCharacteritic];
    
    //发布服务和特征
    [self.peripheralManager addService:transferservice];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{

    NSLog(@"添加服务");
    
    if(error){
    
        NSLog(@"添加服务失败");
    }
}

//发送数据

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{

    NSLog(@"中心已经预定了特征");
    
    self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    self.sendDataIndex = 0;
    
    [self sendData];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{

    NSLog(@"中心没有从特征预定");
    [self.peripheralManager stopAdvertising];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{

    [self sendData];
}

- (void)sendData{

    //发送数据结束标识
    
    static BOOL sendingEOM = NO;
    
    if(sendingEOM){
    
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteritic onSubscribedCentrals:nil];
        if(didSend){
        
            sendingEOM = NO;
            NSLog(@"Sent EOM");
        }
        
        return;
    }
    
    if(self.sendDataIndex >= self.dataToSend.length){
    
        return;
    }
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        if(amountToSend > NOTIEY_MTU){
        
            amountToSend = NOTIEY_MTU;
        }
        
        NSData * chunk = [NSData dataWithBytes:self.dataToSend.bytes + self.sendDataIndex length:amountToSend];
        
        //发送数据
        
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteritic onSubscribedCentrals:nil];
        
        if(!didSend){
        
            return;
        }
        
        NSString *stringFromData = [[NSString alloc]initWithData:chunk encoding:NSUTF8StringEncoding];
        
        NSLog(@"Sent : %@",stringFromData);
        
        self.sendDataIndex += amountToSend;
        
        if(self.sendDataIndex >= self.dataToSend.length){
        
            sendingEOM = YES;
            
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteritic onSubscribedCentrals:nil];
            
            if(eomSent){
            
                sendingEOM = NO;
                NSLog(@"Sent : EOM");
            }
            
            return;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sender:(id)sender {
    
    UISwitch *advertisingSwitch = (UISwitch *)sender;
    
    if(advertisingSwitch.on){
    
        //开始广播
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
    }
    else{
    
        [self.peripheralManager stopAdvertising];
    }
}
@end
