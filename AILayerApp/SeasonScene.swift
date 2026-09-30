import SwiftUI
import SceneKit

struct SeasonScene: View {
    let season: Season
    
    var body: some View {
        ZStack {
            if season == .vimeoBanner {
                Color.black.ignoresSafeArea()
                VimeoPlayerView(videoID: "1231812069")
                    .ignoresSafeArea()
            } else {
                SceneContainer(scene: SeasonBuilder.make(season), allowsControl: true).ignoresSafeArea()
                    .overlay(alignment: .topLeading) {
                        Text("\(season.rawValue.capitalized): \(season.task)").font(.headline)
                            .padding(10).background(.ultraThinMaterial, in: Capsule()).padding(.leading, 60).padding(.top, 8)
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SceneContainer: UIViewRepresentable {
    let scene: SCNScene; let allowsControl: Bool
    func makeUIView(context: Context) -> SCNView {
        let v = SCNView(); v.scene = scene; v.antialiasingMode = .multisampling4X
        v.allowsCameraControl = allowsControl; v.autoenablesDefaultLighting = false
        v.isPlaying = true; v.backgroundColor = .black; return v
    }
    func updateUIView(_ v: SCNView, context: Context) {}
}
