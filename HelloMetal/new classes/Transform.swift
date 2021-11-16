import Foundation
import simd

struct Transform {
  var position = float4(0, 0, 0, 0)
  var rotation = float4(0, 0, 0, 0)
  var scale: Float = 1
  
  var matrix: float4x4  {
    let translateMatrix = float4x4(diagonal: position)
    let rotationMatrix = float4x4(diagonal: rotation)
    let scaleMatrix = float4x4(scale)
    return translateMatrix * scaleMatrix * rotationMatrix
  }
}
