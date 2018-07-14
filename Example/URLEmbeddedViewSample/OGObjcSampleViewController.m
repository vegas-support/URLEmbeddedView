//
//  OGObjcSampleViewController.m
//  URLEmbeddedViewSample
//
//  Created by 鈴木大貴 on 2016/03/31.
//  Copyright © 2016年 鈴木大貴. All rights reserved.
//

#import "OGObjcSampleViewController.h"
#import <URLEmbeddedView/URLEmbeddedView-Swift.h>
#import <MisterFusion/MisterFusion-Swift.h>

@interface OGObjcSampleViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) URLEmbeddedView *embeddedView;

@end

@implementation OGObjcSampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textView.text = @"https://github.com/";
    
    [OGDataProvider sharedInstance].updateInterval = [NSNumber days:10];
    
    self.embeddedView = [[URLEmbeddedView alloc] initWithUrl:@""];
    [self.containerView addLayoutSubview:self.embeddedView andConstraints:@[
        self.embeddedView.Top,
        self.embeddedView.Right,
        self.embeddedView.Left,
        self.embeddedView.Bottom
    ]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTapFetchButton:(id)sender {
    [self.embeddedView loadWithURLString:self.textView.text completion:nil];
        
    [[OGDataProvider sharedInstance] fetchOGDataWithURLString: self.textView.text
                                                   completion:^(OpenGraphData *data, NSError *error) {
        NSLog(@"OpenGraphData = %@", data);
        NSLog(@"siteName = %@", data.siteName);
    }];
}

@end
