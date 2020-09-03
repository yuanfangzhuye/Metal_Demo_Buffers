//
//  ShaderTypes.h
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//
/**
 头文件中包含了 Metal shaders 与 C/OBJC 源之间共享类型和枚举常数
 */
#ifndef ShaderTypes_h
#define ShaderTypes_h

/**
 缓存区索引值 共享与 shader 和 C 代码，为了确保 Metal shader 缓存区索引能够匹配 Metal API Buffer 设置的集合调用
 */
typedef enum TlabVertexInputIndex {
    
    //顶点
    TlabVertexInputIndexVertices     = 0,
    //视图大小
    TlabVertexInputIndexViewportSize = 1,
} TlabVertexInputIndex;

//结构体：顶点&颜色值
typedef struct {
    //像素空间位置
    vector_float2 position;
    //RGBA 颜色
    vector_float4 color;
} TlabVertex;


#endif /* ShaderTypes_h */
