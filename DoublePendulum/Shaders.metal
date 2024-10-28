//
//  Shaders.metal
//  DoublePendulum
//
//  Created by Tim Hau on 28.10.24.
//

#include <metal_stdlib>

using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertex_main(uint vertexId [[vertex_id]])
{
    VertexOut out;
    
    float2 positions[4] = {
        float2(-1.0,  1.0),
        float2(-1.0, -1.0),
        float2( 1.0,  1.0),
        float2( 1.0, -1.0),
    };

    float2 texCorrds[4] = {
        float2(0.0, 0.0),
        float2(0.0, 1.0),
        float2(1.0, 0.0),
        float2(1.0, 1.0),
    };
    
    out.position = float4(positions[vertexId], 0.0, 1.0);
    out.texCoord = texCorrds[vertexId];

    return out;
}

// https://en.wikipedia.org/wiki/Double_pendulum#Lagrangian
float4 derivative(float4 state)
{
    float2 theta = state.xy;
    float2 omega = state.zw;
 
    float gravity = 9.81;
    float m1 = 1.0;
    float m2 = 1.0;
    float L1 = 1.0;
    float L2 = 1.0;
    
    float cos_theta_xy = cos(theta.x - theta.y);
    float sin_theta_xy = sin(theta.x - theta.y);
    float2 a = float2((L2 / L1) * (m2 / (m1 + m2)) * cos_theta_xy,
                      (L1 / L2) * cos_theta_xy);
    float2 f = float2(-(L2 / L1) * (m2 / (m1 + m2)) * omega.y*omega.y * sin_theta_xy - (gravity / L1) * sin(theta.x),
                      (L1 / L2) * omega.x*omega.x * sin_theta_xy - (gravity / L2) * sin(theta.y));
    
    float2 g = float2(f.x - a.x * f.y, f.y - a.y * f.x) / (1 - a.x * a.y);
    
    return float4(omega.x, omega.y, g.x, g.y);
}

kernel void compute_main(texture2d<float, access::read_write> texture [[texture(0)]],
                         uint2 id [[thread_position_in_grid]])
{
    if (id.x >= texture.get_width() || id.y >= texture.get_height()) {
        return;
    }
    
    float4 color = texture.read(id);
    float4 y_n = color * (2.0 * M_PI_F) - M_PI_F; // [0, 1] --> [-π, π]
    
    // Runge Kutta 4
    float d_t = 0.01;
    float4 k_1 = d_t * derivative(y_n);
    float4 k_2 = d_t * derivative(y_n + 0.5 * k_1);
    float4 k_3 = d_t * derivative(y_n + 0.5 * k_2);
    float4 k_4 = d_t * derivative(y_n + k_3);
    y_n += (k_1 + k_4 + 2.0 * (k_2 + k_3)) / 6.0;
    
    y_n = (y_n + M_PI_F) / (2.0 * M_PI_F); // [-π, π] --> [0, 1]
    y_n.xy = fract(y_n.xy); // Loop angles if they exeed the range

    texture.write(y_n, id);
}

float3 colormap(float2 uv_norm)
{
    float2 uv = 2 * M_PI_F * uv_norm;
    return pow(0.5 + 0.5 * float3(sin(uv.x) * float2(-cos(uv.y), sin(uv.y)), -cos(uv.x)),
               float3(0.75));
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> texture [[texture(0)]])
{
    float4 v = texture.sample(sampler(coord::normalized), in.texCoord);
    return float4(colormap(v.xy), 1.0);
}
