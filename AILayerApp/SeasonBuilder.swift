import SwiftUI
import SceneKit

enum SeasonBuilder {
    static func make(_ season: Season) -> SCNScene {
        let s = SCNScene(); light(s, sun: season == .spring ? 500 : 1400)
        s.background.contents = season.sky
        s.fogColor = season.sky; s.fogStartDistance = 15; s.fogEndDistance = 60
        s.rootNode.addChildNode(node(SCNPlane(width: 120, height: 120), season.ground, SCNVector3(0, 0, 0)).rotated())
        for i in 0..<40 { s.rootNode.addChildNode(tree(season, x: Float.random(in: -40...40), z: Float.random(in: -45 ... -10) + Float(i % 2))) }
        s.rootNode.addChildNode(particles(season))
        let robot = makeRobot(); robot.position = SCNVector3(0, 0, 0); s.rootNode.addChildNode(robot)
        switch season {
        case .autumn: fruits(s, robot)
        case .summer: lawn(s, robot)
        case .spring: flowers(s, robot)
        case .winter: plow(s, robot)
        }
        let cam = SCNNode(); cam.camera = SCNCamera(); cam.camera!.fieldOfView = 55; cam.camera!.wantsHDR = true
        cam.position = SCNVector3(0, 3.5, 11); cam.look(at: SCNVector3(0, 1.5, 0)); s.rootNode.addChildNode(cam)
        return s
    }
    static func tree(_ s: Season, x: Float, z: Float) -> SCNNode {
        let t = SCNNode()
        t.addChildNode(node(SCNCylinder(radius: 0.25, height: 3), UIColor.brown, SCNVector3(0, 1.5, 0)))
        let leaf: UIColor = s == .winter ? .white : s == .autumn ? [.orange, .red, .yellow].randomElement()! : .systemGreen
        t.addChildNode(node(SCNSphere(radius: 1.6), leaf, SCNVector3(0, 3.8, 0)))
        t.position = SCNVector3(x, 0, z); return t
    }
    static func particles(_ s: Season) -> SCNNode {
        let p = SCNParticleSystem(); p.emitterShape = SCNBox(width: 40, height: 0.1, length: 40, chamferRadius: 0)
        p.particleLifeSpan = 6; p.speedFactor = 1
        switch s {
        case .winter: p.birthRate = 800; p.particleSize = 0.08; p.particleColor = .white; p.acceleration = SCNVector3(0.3, -1.5, 0)
        case .spring: p.birthRate = 2500; p.particleSize = 0.03; p.particleColor = UIColor(red: 0.6, green: 0.75, blue: 1, alpha: 0.8)
                      p.acceleration = SCNVector3(0.5, -14, 0); p.stretchFactor = 0.25; p.particleLifeSpan = 1.5
        case .summer: p.birthRate = 150; p.particleSize = 0.06; p.particleColor = UIColor(white: 1, alpha: 0.6)
                      p.acceleration = SCNVector3(12, 0, 0); p.stretchFactor = 0.6; p.particleLifeSpan = 3
        case .autumn: p.birthRate = 120; p.particleSize = 0.18; p.particleColor = .orange; p.acceleration = SCNVector3(1.5, -1.0, 0.5)
                      p.particleColorVariation = SCNVector4(0.1, 0.4, 0.1, 0); p.angularVelocity = 4; p.particleAngleVariation = 180
        }
        let n = SCNNode(); n.position = SCNVector3(0, 14, -5); n.addParticleSystem(p); return n
    }
    static func makeRobot() -> SCNNode {
        let r = SCNNode()
        r.addChildNode(node(SCNBox(width: 1, height: 1.2, length: 0.7, chamferRadius: 0.1), .lightGray, SCNVector3(0, 1.4, 0), metal: true))
        r.addChildNode(node(SCNSphere(radius: 0.35), .white, SCNVector3(0, 2.3, 0), metal: true))
        r.addChildNode(node(SCNSphere(radius: 0.08), .cyan, SCNVector3(0.12, 2.35, 0.3), emissive: true))
        r.addChildNode(node(SCNSphere(radius: 0.08), .cyan, SCNVector3(-0.12, 2.35, 0.3), emissive: true))
        for x: Float in [-0.6, 0.6] {
            let arm = node(SCNCylinder(radius: 0.1, height: 1), .darkGray, SCNVector3(x, 0, 0), metal: true)
            let pivot = SCNNode(); pivot.name = x < 0 ? "armL" : "armR"; pivot.position = SCNVector3(x, 1.8, 0); arm.position = SCNVector3(0, -0.5, 0)
            pivot.addChildNode(arm); r.addChildNode(pivot)
            r.addChildNode(node(SCNCylinder(radius: 0.15, height: 0.9), .darkGray, SCNVector3(x * 0.5, 0.45, 0), metal: true))
        }
        return r
    }
    static func swing(_ r: SCNNode) {
        for n in ["armL", "armR"] { r.childNode(withName: n, recursively: false)?
            .runAction(.repeatForever(.sequence([.rotateBy(x: 1.0, y: 0, z: 0, duration: 0.8), .rotateBy(x: -1.0, y: 0, z: 0, duration: 0.8)]))) }
    }
    static func patrol(_ n: SCNNode, dx: Float, t: TimeInterval) {
        n.runAction(.repeatForever(.sequence([.move(by: SCNVector3(dx, 0, 0), duration: t), .rotateBy(x: 0, y: .pi, z: 0, duration: 0.5),
                                              .move(by: SCNVector3(-dx, 0, 0), duration: t), .rotateBy(x: 0, y: -.pi, z: 0, duration: 0.5)])))
    }

    static func fruits(_ s: SCNScene, _ r: SCNNode) {
        r.position = SCNVector3(0, 0, 0); swing(r)
        s.rootNode.addChildNode(node(SCNBox(width: 12, height: 0.3, length: 1.4, chamferRadius: 0.05), .darkGray, SCNVector3(0, 0.9, 1.2)))
        let cols: [UIColor] = [.red, .orange, .yellow, .green, .purple]
        for i in 0..<12 {
            let size = CGFloat.random(in: 0.12...0.3)
            let g: SCNGeometry = i % 3 == 0 ? SCNSphere(radius: size) : i % 3 == 1 ? SCNCapsule(capRadius: size * 0.8, height: size * 3) : SCNBox(width: size * 2, height: size * 1.6, length: size * 2, chamferRadius: size * 0.4)
            let f = node(g, cols[i % 5], SCNVector3(-5.5 + Float(i) * 0.1, 1.25 + Float(size), 1.2)); s.rootNode.addChildNode(f)
            f.runAction(.sequence([.wait(duration: Double(i) * 0.7), .repeatForever(.sequence([.move(to: SCNVector3(5.5, Float(1.25 + size), 1.2), duration: 9),
                        .move(to: SCNVector3(-5.5, Float(1.25 + size), 1.2), duration: 0)]))]))
        }
        for (i, c) in cols.enumerated() { s.rootNode.addChildNode(node(SCNBox(width: 1, height: 0.6, length: 1, chamferRadius: 0.05), c, SCNVector3(-4 + Float(i) * 2, 0.3, 2.6))) }
    }

    static func lawn(_ s: SCNScene, _ r: SCNNode) {
        r.position = SCNVector3(-4, 0, 2)
        for i in 0..<8 {
            let stripe = node(SCNBox(width: 12, height: 0.02, length: 0.5, chamferRadius: 0),
                              i % 2 == 0 ? UIColor(red: 0.2, green: 0.75, blue: 0.2, alpha: 1) : UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1), SCNVector3(0, 0.02, -1 + Float(i) * 0.5))
            s.rootNode.addChildNode(stripe)
        }
        r.addChildNode(node(SCNBox(width: 1.4, height: 0.2, length: 0.8, chamferRadius: 0.05), .systemGreen, SCNVector3(0, 0.15, 0.9), metal: true))
        swing(r); patrol(r, dx: 8, t: 5)
    }

    static func flowers(_ s: SCNScene, _ r: SCNNode) {
        let pal: [UIColor] = [.systemPink, .magenta, .systemOrange, .purple, .systemYellow]
        for i in 0..<10 {
            let x = Float(-5 + i), z = Float(1 + (i % 3))
            s.rootNode.addChildNode(node(SCNCylinder(radius: 0.03, height: 1), .systemGreen, SCNVector3(x, 0.5, z)))
            for k in 0..<8 { let a = Float(k) * .pi / 4
                s.rootNode.addChildNode(node(SCNSphere(radius: 0.22), pal[i % 5], SCNVector3(x + cos(a) * 0.3, 1.05, z + sin(a) * 0.3))) }
            s.rootNode.addChildNode(node(SCNSphere(radius: 0.15), .yellow, SCNVector3(x, 1.08, z)))
        }
        let can = node(SCNCone(topRadius: 0.35, bottomRadius: 0.25, height: 0.5), .systemTeal, SCNVector3(0, -0.5, 0.3), metal: true)
        r.childNode(withName: "armR", recursively: false)?.addChildNode(can)
        r.childNode(withName: "armR", recursively: false)?.runAction(.repeatForever(.sequence([.rotateBy(x: 1.3, y: 0, z: 0, duration: 1), .rotateBy(x: -1.3, y: 0, z: 0, duration: 1)])))
        patrol(r, dx: 8, t: 6); r.position = SCNVector3(-4, 0, 3.5)
    }

    static func plow(_ s: SCNScene, _ r: SCNNode) {
        s.rootNode.addChildNode(node(SCNBox(width: 40, height: 0.03, length: 4, chamferRadius: 0), UIColor(white: 0.25, alpha: 1), SCNVector3(0, 0.03, 2)))
        r.position = SCNVector3(-6, 0, 2)
        r.addChildNode(node(SCNBox(width: 0.2, height: 0.8, length: 3, chamferRadius: 0.05), .systemOrange, SCNVector3(0.9, 0.5, 0), metal: true))
        swing(r); patrol(r, dx: 12, t: 8)
    }
}
extension SCNNode { func rotated() -> SCNNode { eulerAngles.x = -.pi / 2; return self } }

