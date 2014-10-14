//
//  CameraViewController.m
//  SimpleTableView
//
//  Created by Ratheesh Reddy on 10/8/14.
//  Copyright (c) 2014 Ventois. All rights reserved.
//

#import "CameraViewController.h"
#import "APLViewController.h"

@interface CameraViewController ()

@property(nonatomic, assign)id<CameraViewControllerDelegate>delegate;

-(void)exit;

@end


@implementation CameraViewController

-(id) initWithDelegate:(id<CameraViewControllerDelegate>)delegate
{
    self = [super initWithNibName:@"CameraViewController" bundle:nil];
    
    if (nil != self)
    {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(exit)];
    [self init_camera];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

*/

- (void) readerView:(ZBarReaderView *)readerView didReadSymbols: (ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    ZBarSymbol * s = nil;
    
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:[symbols count]];
    
    for (s in symbols)
    {
        //NSLog(@"The value read is:%@", s.data);
        [array addObject:s.data];
    }
    
    [self.delegate scanCompletedWithString:array];
    
}

// initialize device camera 
- (void) init_camera
{
    ZBarReaderView * reader = [ZBarReaderView new];
    
    ZBarImageScanner * scanner = [ZBarImageScanner new];
    
    [scanner setSymbology:ZBAR_PARTIAL config:0 to:0];
    
    [reader initWithImageScanner:scanner];
    
    reader.readerDelegate = self;
    
    const float h = self.view.bounds.size.height;
    
    const float w = self.view.bounds.size.width;
    
    const float h_padding = w / 10.0;
    
    const float v_padding = h / 10.0;
    
    CGRect reader_rect = CGRectMake(h_padding, v_padding,
                                    w - h_padding * 2.0, h / 3.0);
    reader.frame = self.view.frame;
    
    reader.backgroundColor = [UIColor redColor];
    
    [reader start];
    
    [self.view addSubview: reader];
}

-(void)exit
{
    [self dismissViewControllerAnimated:YES completion:NO];
}

@end
