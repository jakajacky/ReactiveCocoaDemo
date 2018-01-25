//
//  ViewController.m
//  DRMVVMDemo
//
//  Created by XiaoQiang on 2018/1/15.
//  Copyright © 2018年 XiaoQiang. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *reactiveBtn;
@property (weak, nonatomic) IBOutlet UITextField *reactiveField;
@property (nonatomic, strong) NSString *content;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    __block int aNumber = 0;
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        aNumber++;
        [subscriber sendNext:@(aNumber)];
        [subscriber sendCompleted];
        return nil;
    }];
    [signal1 subscribeNext:^(id x) {
        NSLog(@"subscribe one:%@", x);
    }];
    [signal1 subscribeNext:^(id x) {
        NSLog(@"subscribe two:%@", x);
    }];
    
    /*
    RACSignal *signal2 = [RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
    [signal2 subscribeNext:^(id x) {
        NSLog(@"-%@", x);
    }];
     */
    
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id x) {
        NSLog(@"subject1:%@", x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"subject2:%@", x);
    }];
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    
    self.reactiveBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *input) {
        NSLog(@"%@",input.currentTitle);
//        self.content = self.reactiveField.text;
        self.content = input.currentTitle;
        return [RACSignal empty];
    }];

    [self.reactiveField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"field change:%@", x);
    }];
    
    [RACObserve(self.reactiveField, text) subscribeNext:^(id x) {
        NSLog(@"field changed:%@", x);
    }];
    
    [RACObserve(self, content)
     subscribeNext:^(id x) {
        NSLog(@"content changed:%@", x);
    }];
    
    // 单向绑定
    RAC(self.reactiveBtn.titleLabel,font) = [self.reactiveField.rac_textSignal map:^id(NSString *value) {
        return [UIFont systemFontOfSize:[value floatValue]];
    }];
    
    // 聚合
    RACSignal *signal0 = [RACSignal combineLatest:@[signal1, self.reactiveField.rac_textSignal] reduce:^id(NSNumber *aNumber, NSString *text){
        return [NSString stringWithFormat:@"%@--%@",aNumber, text];
    }];
    [signal0 subscribeNext:^(id x) {
        NSLog(@"combine %@", x);
    }];
    
    // 双向绑定
    RACChannelTo(self, content) = RACChannelTo(self.reactiveField, text);
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
