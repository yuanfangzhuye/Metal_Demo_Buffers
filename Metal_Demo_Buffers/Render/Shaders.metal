//
//  Shaders.metal
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#include <metal_stdlib>
//使用命名空间 Metal
using namespace metal;

//导入 Metal shader 代码和执行 Metal API 命令的 C 代码之间共享的头
#import "ShaderTypes.h"

//顶点着色器输出/片元着色器输入
typedef struct {
    //处理空间的顶点信息
    float4 clipSpacePosition [[position]];
    //颜色
    float4 color;
} RasterizerData;

//顶点着色函数
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant TlabVertex *vertices [[buffer(TlabVertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(TlabVertexInputIndexViewportSize)]]) {
    /**
     处理顶点数据：
     1）执行坐标系转换，将生成的顶点剪辑空间写入到返回值中
     2）将顶点颜色值传递给返回值
     */
    
    //定义 out
    RasterizerData out;
    
    //初始化输出剪辑空间位置
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);
    
    //索引到我们的数组位置以获得当前顶点，我们的位置是在像素维度中指定的
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    //将 viewportSizePointer 从 vector_uint2 转化为 vector_float2 类型
    vector_float2 viewportSize = vector_float2 (*viewportSizePointer);
    
    /**
     1）每个顶点着色器的输出位置在剪辑空间中（也称为归一化设备坐标空间， NDC），剪辑空间中的 (-1, -1) 表示视口的左下角，而 (1, 1) 表示视口的右上角
     2）计算和写入XY值到我们的剪辑空间的位置。为了从像素空间中的位置转换到剪辑空间的位置，我们将像素坐标除以视口大小的一半
     */
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    //把我们输入的颜色直接赋值给输出颜色。这个值将用于构成三角形的顶点的其他颜色值插值，从而为我们片元着色器中的每个片元生成颜色值
    out.color = vertices[vertexID].color;
    
    //完成! 将结构体传递到管道中下一个阶段
    return out;
}

//当顶点函数执行三次，三角形的每个顶点执行一次后，则执行管道中的下一个阶段：栅格化/光栅化


/**
 片元函数
 1）[[stage_in]]，片元着色函数使用的单个片元输入数据是由顶点着色函数输出，然后经过光栅化生成的。单个片元输入函数数据可以使用 “[[stage_in]]”属性修饰符
 2）一个顶点着色函数可以读取单个顶点的输入数据，这些输入数据存储于参数传递的缓存中，使用顶点和实例ID在这些缓存中寻址，读取到单个顶点的数据。另外，单个顶点输入数据也可以通过使用 “[[stage_in]]” 属性修饰符的产生传递给顶点着色函数
 3）被 stage_in 修饰的结构体的成员不能是以下这些：
    Pack vectors 紧密填充类型向量
    matrices 矩阵
    structs 结构体
    reference or pointers to type 某类型的引用或指针
    arrays, vectors, matrices 标量、向量、矩阵数组
 */
fragment float4 fragmentShader(RasterizerData in [[stage_in]]) {
    //返回输入的片元颜色
    return in.color;
}
