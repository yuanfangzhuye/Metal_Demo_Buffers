//
//  RenderManager.m
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import "RenderManager.h"
#import "ShaderTypes.h" //头,在C代码之间共享

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
    
    //1.设置绘制纹理的像素格式
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    
    //2.从项目中加载所有的 .Metal 着色器文件
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    //从库中加载顶点函数
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    //从库中加载片元函数
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    //3.配置用于创建管道状态的管道
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    //管道名称
    pipelineDescriptor.label = @"123456";
    //可编程函数，用于处理渲染过程中的各个顶点
    pipelineDescriptor.vertexFunction = vertexFunction;
    //可编程函数，用于处理渲染过程中的各个片元
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    //设置管道中存储颜色数据的组建格式
    pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    
    //4.同步创建并返回渲染管线对象
    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    //判断是否创建成功
    if (!_pipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
    
    //5.获取顶点数据
    NSData *vertexData = [self generateVertexData];
    //创建一个 vertex buffer，可以由 GPU 来读取
    _vertexBuffer = [_device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    
    //复制 vertex data 到 vertex buffer 通过缓存区 的 contents 内容属性访问指针
    /**
     memcpy(void *dst, const void *src, size_t n);
     dst：目的地
     src：源内容
     n：长度
     */
    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
    
    //计算顶点个数 = 顶点数据长度 / 单个顶点大小
    _numVertices = vertexData.length / sizeof(TlabVertex);
    
    //6.创建命令队列
    _commandQueue = [_device newCommandQueue];
}

//顶点数据
- (NSData *)generateVertexData {
    
    //1.正方形 = 三角形+三角形
    const TlabVertex quadVertices[] = {
        
        // Pixel 位置, RGBA 颜色
        { { -20,   20 },    { 1, 0, 0, 1 } },
        { {  20,   20 },    { 1, 0, 0, 1 } },
        { { -20,  -20 },    { 1, 0, 0, 1 } },
        
        { {  20,  -20 },    { 0, 0, 1, 1 } },
        { { -20,  -20 },    { 0, 0, 1, 1 } },
        { {  20,   20 },    { 0, 0, 1, 1 } },
    };
    
    //行/列 数量
    const NSUInteger NUM_COLUMNS = 25;
    const NSUInteger NUM_ROWS = 15;
    
    //顶点个数
    const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices) / sizeof(TlabVertex);
    
    //四边形间距
    const float QUAD_SPACING = 50.0;
    
    //数据大小 = 单个四边形大小 * 行 * 列
    NSUInteger dataSize = sizeof(quadVertices) * NUM_ROWS * NUM_COLUMNS;
    
    //2.开辟空间
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
    
    //当前四边形
    TlabVertex *currentQuad = vertexData.mutableBytes;
    
    //3.获取顶点坐标（循环计算）
    
    for (NSUInteger row = 0; row < NUM_ROWS; row++) { //行
        for (NSUInteger column = 0; column < NUM_COLUMNS; column++) { //列
            //左上角的位置
            vector_float2 upperLeftPosition;
            
            //计算X，Y 位置，注意坐标系基于 2D 笛卡尔坐标系，中心点（0， 0），所以会出现负数位置
            upperLeftPosition.x = ((-((float)NUM_COLUMNS) / 2.0) + column) * QUAD_SPACING + QUAD_SPACING / 2.0;
            upperLeftPosition.y = ((-((float)NUM_ROWS) / 2.0) + row) * QUAD_SPACING + QUAD_SPACING/2.0;
            
            //将 quadVertices 数据复制到 currentQuad
            memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
            
            //遍历 currentQuad 中的数据
            for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; vertexInQuad++) {
                //修改 vertexInQuad 中的 position
                currentQuad[vertexInQuad].position += upperLeftPosition;
            }
            //更新索引
            currentQuad += 6;
        }
    }
    
    return vertexData;
}

//每当视图需要渲染帧时调用
- (void)drawInMTKView:(nonnull MTKView *)view {
    
    //为当前渲染的每个渲染传递创建一个新的命令缓存区
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    //指定缓存区名称
    commandBuffer.label = @"MyBuffer";
    
    //2.MTLRenderPassDescriptor：一组渲染目标，用作渲染通道生成的像素的输出目标
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    //判断渲染目标是否为空
    if (renderPassDescriptor != nil) {
        
        //创建渲染命令编码器，这样我们才可以渲染 something
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        //渲染器名称
        renderEncoder.label = @"MyRenderEncoder";
        
        //3.设置我们绘制的可绘制区域
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];
        
        //4.设置渲染管道
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        /**
         调用-[MTLRenderCommandEncoder setVertexBuffer:offset:atIndex:] 为了从我们的 OC 代码找发送数据预加载的 MTLBuffer 到我们的 Metal 顶点着色函数中
         @param buffer - 包含需要传递数据的缓冲对象
         @param offset - 它们从缓冲器的开头字节偏移，指示“顶点指针”指向什么。在这种情况下，我们通过0，所以数据一开始就被传递下来，偏移量
         @param index - 一个整数索引，对应于我们的“vertexShader”函数中的缓冲区属性限定符的索引。注意，此参数与 -[MTLRenderCommandEncoder setVertexBytes:length:atIndex:] “索引”参数相同
         */
        //5.将 _vertexBuffer 设置到顶点缓存区中
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:TlabVertexInputIndexVertices];
        //将 _viewportSize 设置到顶点缓存区绑定点设置数据
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:TlabVertexInputIndexViewportSize];
        
        //6.开始绘图
        /**
        @brief 在不使用索引列表的情况下，绘制图元
        @param 绘制图形组装的基元数据
        @param 从哪个位置数据开始绘制，一般为0
        @param 每个图元的顶点个数，绘制的图形顶点数量
         MTLPrimitiveTypePoint = 0, 点
         MTLPrimitiveTypeLine = 1, 线段
         MTLPrimitiveTypeLineStrip = 2, 线环
         MTLPrimitiveTypeTriangle = 3,  三角形
         MTLPrimitiveTypeTriangleStrip = 4, 三角型扇
         */
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_numVertices];
        
        //7.表示该编码器生成的命令都已完成，并且从MTLCommandBuffer 中分离
        [renderEncoder endEncoding];
        
        //8.一旦框架缓存区完成，使用当前可绘制的进度表
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    //9.最后，在这里完成渲染并将命令缓存区推送到 GPU
    [commandBuffer commit];
}

//每当视图改变方向或调整大小时调用
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
    //保存可绘制的大小，因为当我们绘制时，我们将把这些值传递给顶点着色器
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

@end
