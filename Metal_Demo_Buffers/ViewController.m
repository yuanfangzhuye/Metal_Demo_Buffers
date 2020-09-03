//
//  ViewController.m
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import "ViewController.h"
#import "RenderManager.h"

@import MetalKit;

@interface ViewController () {
    MTKView *_view;
    RenderManager *_manager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _view = [[MTKView alloc] initWithFrame:self.view.bounds];
    _view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_view];
    
    _view.device = MTLCreateSystemDefaultDevice();
    if (!_view.device) {
        NSLog(@"Metal is not supported on this device");
        return;
    }
    
    _manager = [[RenderManager alloc] initWithMetalKitView:_view];
    if (!_manager) {
        NSLog(@"Renderer failed initialization");
        return;
    }
    
    [_manager mtkView:_view drawableSizeWillChange:_view.drawableSize];
    _view.delegate = _manager;
}


@end
