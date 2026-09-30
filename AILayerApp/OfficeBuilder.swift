import SwiftUI
import SceneKit

enum OfficeBuilder {
    static func make() -> SCNScene {
        let s = SCNScene(); light(s, sun: 900)
        s.background.contents = UIColor(white: 0.08, alpha: 1)
        let W: CGFloat = 16, D: CGFloat = 10, H: CGFloat = 8   // H = two storeys
        s.rootNode.addChildNode(node(SCNBox(width: W, height: 0.1, length: D, chamferRadius: 0), UIColor(red: 0.45, green: 0.32, blue: 0.2, alpha: 1), SCNVector3(0, 0, 0)))
        s.rootNode.addChildNode(node(SCNBox(width: W, height: 0.1, length: D, chamferRadius: 0), UIColor(white: 0.9, alpha: 1), SCNVector3(0, Float(H), 0)))
        s.rootNode.addChildNode(node(SCNBox(width: W, height: H, length: 0.1, chamferRadius: 0), UIColor(white: 0.85, alpha: 1), SCNVector3(0, Float(H/2), Float(-D/2))))
        // big stained-glass windows on the back wall
        let glass: [UIColor] = [.systemRed, .systemBlue, .systemYellow, .systemGreen, .systemPurple, .systemOrange]
        for i in 0..<6 {
            let w = node(SCNBox(width: 2, height: 6, length: 0.05, chamferRadius: 0.05), glass[i].withAlphaComponent(0.85),
                         SCNVector3(Float(-6.5 + Double(i) * 2.6), 4.2, Float(-D/2 + 0.1)), emissive: true)
            s.rootNode.addChildNode(w)
            let arch = node(SCNCylinder(radius: 1, height: 0.05), glass[(i + 2) % 6].withAlphaComponent(0.85),
                            SCNVector3(Float(-6.5 + Double(i) * 2.6), 7.2, Float(-D/2 + 0.1)), emissive: true)
            arch.eulerAngles.x = .pi / 2; s.rootNode.addChildNode(arch)
        }
        // long tables + 12 computers: cols of 4 = two rows x two items
        let os: [(String, UIColor)] = [("mac", UIColor(red: 0.6, green: 0.75, blue: 1, alpha: 1)),
                                       ("linux", UIColor(red: 0.95, green: 0.45, blue: 0.15, alpha: 1)),
                                       ("windows", UIColor(red: 0.1, green: 0.5, blue: 0.95, alpha: 1))]
        for (g, o) in os.enumerated() {
            let gx = Float(-5 + g * 5)
            s.rootNode.addChildNode(node(SCNBox(width: 4, height: 0.12, length: 3.6, chamferRadius: 0.02), UIColor(red: 0.3, green: 0.2, blue: 0.12, alpha: 1), SCNVector3(gx, 0.8, 0)))
            for r in 0..<2 { for c in 0..<2 {
                let px = gx + Float(c) * 1.8 - 0.9, pz = Float(r) * 1.7 - 0.85
                let mon = node(SCNBox(width: 1.3, height: 0.8, length: 0.05, chamferRadius: 0.03), o.1, SCNVector3(px, 1.4, pz), emissive: true)
                mon.eulerAngles.y = r == 0 ? 0 : .pi
                if o.0 == "linux" { mon.addChildNode(node(SCNBox(width: 1.3, height: 0.08, length: 0.06, chamferRadius: 0), .black, SCNVector3(0, 0.36, 0.03))) }
                if o.0 == "windows" { mon.addChildNode(node(SCNBox(width: 1.3, height: 0.07, length: 0.06, chamferRadius: 0), .darkGray, SCNVector3(0, -0.36, 0.03))) }
                s.rootNode.addChildNode(mon)
                s.rootNode.addChildNode(node(SCNBox(width: 0.5, height: 0.04, length: 0.25, chamferRadius: 0), .darkGray, SCNVector3(px, 0.88, pz + (r == 0 ? 0.4 : -0.4))))
            } }
        }
        let cam = SCNNode(); cam.camera = SCNCamera(); cam.camera!.fieldOfView = 60
        cam.position = SCNVector3(0, 3, 9); cam.look(at: SCNVector3(0, 3, 0)); s.rootNode.addChildNode(cam)
        cam.runAction(.repeatForever(.sequence([.move(by: SCNVector3(2, 0, 0), duration: 8), .move(by: SCNVector3(-2, 0, 0), duration: 8)])))
        return s
    }
}
