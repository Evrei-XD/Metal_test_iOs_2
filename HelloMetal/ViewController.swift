/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Metal

@available(iOS 13.0, *)
class ViewController: UIViewController {

    var objectToDraw: Cube!
    var objectToDraw2: Triangle!

    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    var projectionMatrix: Matrix4!
    var lastFrameTimestamp: CFTimeInterval = 0.0

    let recognizer = UILongPressGestureRecognizer()
    var coordX: Int = 0
    var coordY: Int = 0
            
      
    override func viewDidLoad() {
    super.viewDidLoad()

    let myRotate = UIPanGestureRecognizer(target: self, action: #selector(rotateObject))
    view.addGestureRecognizer(myRotate)
    
    
    // Do any additional setup after loading the view, typically from a nib.
    device = MTLCreateSystemDefaultDevice()
    projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
    
    metalLayer = CAMetalLayer()          // 1
    metalLayer.device = device           // 2
    metalLayer.pixelFormat = .bgra8Unorm // 3
    metalLayer.framebufferOnly = true    // 4
    metalLayer.frame = view.layer.frame  // 5
    view.layer.addSublayer(metalLayer)   // 6
    
    
    objectToDraw = Cube(device: device)
    objectToDraw2 = Triangle(device: device)
    
    // 1
    let defaultLibrary = device.makeDefaultLibrary()!
    let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
    let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
    
    // 2
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    // 3
    pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    
    commandQueue = device.makeCommandQueue()
    
    timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
    timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
  

    func render() {
    guard let drawable = metalLayer?.nextDrawable() else { return }
    let worldModelMatrix = Matrix4()
    worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
    worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
     
    objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
  }
  
    // 1
    @objc func newFrame(displayLink: CADisplayLink){
    
    if lastFrameTimestamp == 0.0
    {
        lastFrameTimestamp = displayLink.timestamp
    }
    
    // 2
    let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
    lastFrameTimestamp = displayLink.timestamp
    
    // 3
    gameloop(timeSinceLastUpdate: elapsed)
    }
  
    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
    
    // 4
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate, coordX: self.coordX, coordY: self.coordY)
    
    // 5
    autoreleasepool {
      self.render()
    }
  }
    
    
    @objc func rotateObject(recognaizer: UIPanGestureRecognizer) {
        if recognaizer.state == .changed {
            let translation = recognaizer.translation(in: self.view)
            coordX = Int(translation.x)
            coordY = Int(translation.y)
            print("rotateObject x: ", Float(translation.x), "  rotateObject y: ", Float(translation.y))
        }
    }
}



