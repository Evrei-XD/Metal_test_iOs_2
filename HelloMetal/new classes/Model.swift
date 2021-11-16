//
//  Model.swift
//  HelloMetal
//
//  Created by Motorica LLC on 14.11.2021.
//  Copyright © 2021 razeware. All rights reserved.
//
import Foundation
import MetalKit

class Model {
  
  let mdlMeshes: [MDLMesh]
  let mtkMeshes: [MTKMesh]
  var transform = Transform()
  
  init(name: String) {
    let assetUrl = Bundle.main.url(forResource: name, withExtension: "obj")
    let allocator = MTKMeshBufferAllocator(device: Renderer.device)
    
//    let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor()
    let vertexDescriptor = MDLVertexDescriptor()
//    vertexDescriptor.attributes[0].self
    let asset = MDLAsset(url: assetUrl, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)
    
    let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
    self.mdlMeshes = mdlMeshes
    self.mtkMeshes = mtkMeshes
  }
}
