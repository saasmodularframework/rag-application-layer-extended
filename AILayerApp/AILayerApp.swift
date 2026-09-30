import SwiftUI
import SceneKit

@main struct AILayerApp: App {
    var body: some Scene { WindowGroup { RootView().preferredColorScheme(.dark) } }
}

struct RootView: View {
    @State private var path: [Season] = []
    var body: some View {
        NavigationStack(path: $path) {
            MainScene(open: { path.append($0) })
                .navigationDestination(for: Season.self) { SeasonScene(season: $0) }
        }
    }
}
