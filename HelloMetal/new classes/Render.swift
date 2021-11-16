import Foundation
import MetalKit

struct Vertexs {
  let position: float3
  let color: float3
}

class Renderer: NSObject {
  
  static var device: MTLDevice!
  let commandQueue: MTLCommandQueue
  
  static var library: MTLLibrary!
  let pipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState
  
  let train: Model
  let tree: Model
    
//  var uniforms = Uniforms2()

//  var timer: Float = 0
  
  init(view: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("Unable to connect to GPU")
    }
    Renderer.device = device
    self.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    pipelineState = Renderer.createPipelineState()
    depthStencilState = Renderer.createDepthState()

    train = Model(name: "train")
    train.transform.position = [0, 0, 0]
    train.transform.scale = -0.1
    train.transform.rotation.x = radians(fromDegrees: -90)
    train.transform.rotation.y = radians(fromDegrees: 90)
    
    tree = Model(name: "train")//"treefir")
    tree.transform.position = [-6, 0, 0]
    tree.transform.scale = 0.1
    tree.transform.rotation.x = radians(fromDegrees: 90)
    tree.transform.rotation.y = radians(fromDegrees: 90)
    
    view.depthStencilPixelFormat = .depth32Float
    
    super.init()
  }
  
  static func createPipelineState() -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
//    pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    
    return try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
  }
  
  static func createDepthState() -> MTLDepthStencilState {
    let depthDescriptor = MTLDepthStencilDescriptor()
    depthDescriptor.depthCompareFunction = .less
    depthDescriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
  }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
  
  func draw(in view: MTKView) {
    guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let drawable = view.currentDrawable,
      let descriptor = view.currentRenderPassDescriptor else {
        return
    }
    
//    timer += 0.05
    
//    var viewTransform = Transform()
//    viewTransform.position.y = 1.0
//    viewTransform.position.z = -2.0
    
    let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
    commandEncoder.setRenderPipelineState(pipelineState)
    
//    uniforms.viewMatrix = camera.viewMatrix
//    uniforms.projectionMatrix = camera.projectionMatrix
    
    commandEncoder.setDepthStencilState(depthStencilState)
    
    let models = [tree, train]
    for model in models {
      
//      uniforms.modelMatrix = model.transform.matrix
//      commandEncoder.setVertexBytes(&uniforms,
//                                    length: MemoryLayout<Uniforms>.stride,
//                                    index: 21)
      
      for mtkMesh in model.mtkMeshes {
        for vertexBuffer in mtkMesh.vertexBuffers {
          
          commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
          
          var colorIndex: Int = 0
          
          for submesh in mtkMesh.submeshes {
            commandEncoder.setVertexBytes(&colorIndex, length: MemoryLayout<Int>.stride, index: 11)
            commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                 indexCount: submesh.indexCount,
                                                 indexType: submesh.indexType,
                                                 indexBuffer: submesh.indexBuffer.buffer,
                                                 indexBufferOffset: submesh.indexBuffer.offset)
            colorIndex += 1
          }
        }
      }
    }
    
    commandEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}

