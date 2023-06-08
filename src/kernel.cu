#include "kernel.h"
#include <stdio.h>

#define TX 32
#define TY 32
#define MAX_ITER 6

typedef double Float;
typedef float3 vec3;
typedef float2 vec2;

__device__ unsigned char clip(int n) { return n > 255 ? 255 : (n < 0 ? 0 : n); }

/*Shift range from (0, 1) to (c, d)*/
__device__ float shiftrange(float c, float d, float t)
{
   return c + (float)(d - c) * t;
}

__device__ float fract(float x){
   return x - floorf(x);
}

__device__ float2 fract2(float2 n) {
   return make_float2(fract(n.x), fract(n.y));
}

__device__ float3 cos3(float3 n) {
   return make_float3(cos(n.x), cos(n.y), cos(n.z));
}

__device__ float3 sin3(float3 n) {
   return make_float3(sin(n.x), sin(n.y), sin(n.z));
}

__device__ float3 palette( float t ) {
    float3 a = make_float3(0.5, 0.5, 0.5);
    float3 b = make_float3(0.5, 0.5, 0.5);
    float3 c = make_float3(1.0, 1.0, 1.0);
    float3 d = make_float3(0.263,0.416,0.557);

    return a + b * cos3( 6.28318 * (c*t + d) );
}

__device__ float length(float2 p) {
   return sqrt(p.x * p.x + p.y * p.y);
}

__global__ void cudaKernel(uchar4 *d_out, int w, int h, float iTime)
{
   const int c = blockIdx.x * blockDim.x + threadIdx.x;
   const int r = blockIdx.y * blockDim.y + threadIdx.y;

   if ((c >= w) || (r >= h))
      return;

   const int i = c + r * w;
   vec2 uv = make_float2((float)((c * 2.0) - w) / (float)h,
                  -1.0 * (float)((r * 2.0) - h) / (float)h);

   float L = length(uv);
   vec3 finalColor = make_float3(0.0f, 0.0f, 0.0f);

   for (int i = 0; i < 4; i++) {
      uv = fract2(uv * 1.5) - 0.5;

      double d = length(uv) * exp(-L);
      vec3 col = palette(L + (i + iTime) * 0.4);
      //col = make_float3(0.0, 1.0, 0.5);
      d = sin(d * 8.0 + iTime) / 8.0;
      d = abs(d);
      d = pow(0.01 / d, 1.2);
      finalColor += col * d;
   }
   
   d_out[i].x = clip(finalColor.x * 255.0);
   d_out[i].y = clip(finalColor.y * 255.0);
   d_out[i].z = clip(finalColor.z * 255.0);
   d_out[i].w = 255;

}

void kernelLauncher(uchar4 *d_out, int w, int h, float iTime)
{
   const dim3 gridSize = dim3((w + TX - 1) / TX, (h + TY - 1) / TY);
   const dim3 blockSize(TX, TY);
   cudaKernel<<<gridSize, blockSize>>>(d_out, w, h, iTime);
}