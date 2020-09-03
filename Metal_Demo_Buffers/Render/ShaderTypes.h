//
//  ShaderTypes.h
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

typedef enum TlabVertexInputIndex {
    TlabVertexInputIndexVertices     = 0,
    TlabVertexInputIndexViewportSize = 1,
} TlabVertexInputIndex;

typedef struct {
    vector_float2 position;
    vector_float4 color;
} TlabVertex;


#endif /* ShaderTypes_h */
