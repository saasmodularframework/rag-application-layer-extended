import SwiftUI
import SceneKit

func node(_ g: SCNGeometry, _ c: UIColor, _ p: SCNVector3, emissive: Bool = false, metal: Bool = false) -> SCNNode {
    let m = SCNMaterial(); m.lightingModel = .physicallyBased; m.diffuse.contents = c
    m.roughness.contents = metal ? 0.25 : 0.7; m.metalness.contents = metal ? 0.9 : 0.0
    if emissive { m.emission.contents = c }
    g.materials = [m]; let n = SCNNode(geometry: g); n.position = p; return n
}
func light(_ s: SCNScene, sun: Float = 1200) {
    let l = SCNNode(); l.light = SCNLight(); l.light!.type = .directional
    l.light!.intensity = CGFloat(sun); l.light!.castsShadow = true
    l.eulerAngles = SCNVector3(-1, 0.6, 0); s.rootNode.addChildNode(l)
    let a = SCNNode(); a.light = SCNLight(); a.light!.type = .ambient; a.light!.intensity = 400
    s.rootNode.addChildNode(a)
}
