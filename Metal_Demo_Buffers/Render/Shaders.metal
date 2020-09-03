//
//  Shaders.metal
//  Metal_Demo_Buffers
//
//  Created by tlab on 2020/9/2.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "ShaderTypes.h"

typedef struct {
    float4 clipSpacePosition [[position]];
    float4 color;
} RasterizerData;


vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant TlabVertex *vertices [[buffer(TlabVertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(TlabVertexInputIndexViewportSize)]]) {
    
    RasterizerData out;
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    vector_float2 viewportSize = vector_float2 (*viewportSizePointer);
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]]) {
    return in.color;
}
