#import <simd/simd.h>

#ifndef Common_h
#define Common_h

typedef struct {
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
} Uniforms2;

#endif /* Common_h */
