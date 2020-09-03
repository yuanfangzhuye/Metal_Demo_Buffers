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
    
    //1.创建 MTKView
    _view = [[MTKView alloc] initWithFrame:self.view.bounds];
    _view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_view];
    
    //一个 MTLDevice 对象代表着一个 GPU，通常我们可以调用方法 MTLCreateSystemDefaultDevic() 来获取代表默认的 GPU 单个对象
    _view.device = MTLCreateSystemDefaultDevice();
    if (!_view.device) {
        NSLog(@"Metal is not supported on this device");
        return;
    }
    
    //2.创建 RenderManager
    _manager = [[RenderManager alloc] initWithMetalKitView:_view];
    if (!_manager) {
        NSLog(@"Renderer failed initialization");
        return;
    }
    
    //用视图大小初始化渲染器
    [_manager mtkView:_view drawableSizeWillChange:_view.drawableSize];
    
    //设置 MTKView 的代理
    _view.delegate = _manager;
}


@end
