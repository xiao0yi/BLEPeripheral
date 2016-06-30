//
//  ViewController.h
//  peripheralDemo
//
//  Created by Mac chen on 16/5/2.
//  Copyright © 2016年 Mac chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define TRANSFER_SERVICE_UUID @"43264C4E-CE41-4BBD-999F-1EA8015D81D0"
#define TRANSFER_CHARACTERITIC_UUID @"97238A93-084A-472D-89C9-862289E4407E"

#define NOTIEY_MTU 20

@interface ViewController : UIViewController<CBPeripheralManagerDelegate,UITextViewDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteritic;
@property (strong, nonatomic) NSData *dataToSend;
@property (nonatomic,readwrite) NSInteger sendDataIndex;

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)sender:(id)sender;
@end

