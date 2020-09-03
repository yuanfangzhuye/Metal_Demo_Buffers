//
//  RenderManager.m
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import "RenderManager.h"
#import "ShaderTypes.h"

@implementation RenderManager
{
    //渲染的设备(GPU)
    id<MTLDevice> _device;
    
    //渲染管道:顶点着色器/片元着色器,存储于.metal shader文件中
    id<MTLRenderPipelineState> _pipelineState;
    
    //命令队列,从命令缓存区获取
    id<MTLCommandQueue> _commandQueue;
    
    //顶点缓存区
    id<MTLBuffer> _vertexBuffer;
    
    //当前视图大小,这样我们才能在渲染通道中使用此视图
    vector_uint2 _viewportSize;
    
    //顶点个数
    NSInteger _numVertices;
}

- (instancetype)initWithMetalKitView:(MTKView *)mtkView {
    self = [super init];
    if (self) {
        //初始化 GPU 设备
        _device = mtkView.device;
        
        //2.加载Metal文件
        [self loadMetal:mtkView];
    }
    
    return self;
}


- (void)loadMetal:(MTKView *)mtkView {
    
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.label = @"123456";
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    
    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (!_pipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
    
    NSData *vertexData = [self generateVertexData];
    _vertexBuffer = [_device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
    
    _numVertices = vertexData.length / sizeof(TlabVertex);
    
    _commandQueue = [_device newCommandQueue];
}

- (NSData *)generateVertexData {
    const TlabVertex quadVertices[] = {
        { { -20,   20 },    { 1, 0, 0, 1 } },
        { {  20,   20 },    { 1, 0, 0, 1 } },
        { { -20,  -20 },    { 1, 0, 0, 1 } },
        
        { {  20,  -20 },    { 0, 0, 1, 1 } },
        { { -20,  -20 },    { 0, 0, 1, 1 } },
        { {  20,   20 },    { 0, 0, 1, 1 } },
    };
    
    const NSUInteger NUM_COLUMNS = 25;
    const NSUInteger NUM_ROWS = 15;
    
    const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices) / sizeof(TlabVertex);
    
    const float QUAD_SPACING = 50.0;
    
    NSUInteger dataSize = sizeof(quadVertices) * NUM_ROWS * NUM_COLUMNS;
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
    TlabVertex *currentQuad = vertexData.mutableBytes;
    
    for (NSUInteger row = 0; row < NUM_ROWS; row++) {
        for (NSUInteger column = 0; column < NUM_COLUMNS; column++) {
            //左上角的位置
            vector_float2 upperLeftPosition;
            
            //计算X，Y 位置，注意坐标系基于 2D 笛卡尔坐标系，中心点（0， 0），所以会出现负数位置
            upperLeftPosition.x = ((-((float)NUM_COLUMNS) / 2.0) + column) * QUAD_SPACING + QUAD_SPACING / 2.0;
            upperLeftPosition.y = ((-((float)NUM_ROWS) / 2.0) + row) * QUAD_SPACING + QUAD_SPACING/2.0;
            
            memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
            
            for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; vertexInQuad++) {
                currentQuad[vertexInQuad].position += upperLeftPosition;
            }
            
            currentQuad += 6;
        }
    }
    
    return vertexData;
}

//每当视图需要渲染帧时调用
- (void)drawInMTKView:(nonnull MTKView *)view {
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyBuffer";
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:TlabVertexInputIndexVertices];
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:TlabVertexInputIndexViewportSize];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_numVertices];
        
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

//每当视图改变方向或调整大小时调用
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
