import SwiftUI
import SceneKit

@main struct AILayerApp: App {
    init() {
        UserDefaults.standard.set(["en_US"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
        }
    var body: some Scene { WindowGroup { RootView().preferredColorScheme(.dark)
                  .environment(\.locale, Locale(identifier: "en_US"))
        }
    }
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

