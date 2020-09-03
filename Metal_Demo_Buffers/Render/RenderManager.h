//
//  RenderManager.h
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalKit; //导入MetalKit工具包

//这是一个独立于平台的渲染类
//MTKViewDelegate协议:允许对象呈现在视图中并响应调整大小事件
@interface RenderManager : NSObject<MTKViewDelegate>

//初始化一个 MTKView
- (instancetype)initWithMetalKitView:(MTKView *)mtkView;

@end
