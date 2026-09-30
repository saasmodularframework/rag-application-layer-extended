import SwiftUI
import SceneKit
import WebKit

struct ContentView: View {
    @State private var path: [Season] = []
    @State private var index = 0
    @State private var zoom: CGFloat = 1
    
    var chart: Chart { charts[index] }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                SceneContainer(scene: OfficeBuilder.make(), allowsControl: false)
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    Text("AI Application Layer — Analytics")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    ScrollView([.horizontal, .vertical]) {
                        chartImage
                            .scaleEffect(zoom)
                            .frame(minWidth: 0, minHeight: 0)
                            .onTapGesture {
                                path.append(chart.season)
                            }
                    }
                    .frame(maxHeight: .infinity)
                    
                    Text("\(chart.title)  ·  tap chart → \(chart.season.rawValue.capitalized) scene")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 20) {
                        btn("chevron.left") { step(-1) }
                        btn("minus.magnifyingglass") { zoom = max(0.5, zoom - 0.25) }
                        btn("plus.magnifyingglass") { zoom = min(4, zoom + 0.25) }
                        btn("chevron.right") { step(1) }
                    }
                    
                    HStack {
                        ForEach(charts) { c in
                            Circle()
                                .fill(c.id == index ? .white : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .gesture(
                    DragGesture().onEnded { gesture in
                        if gesture.translation.width < -40 { step(1) }
                        else if gesture.translation.width > 40 { step(-1) }
                    }
                )
            }
            .navigationDestination(for: Season.self) { season in
                if season == .vimeoBanner {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        VimeoPlayerView(videoID: "1231812069")
                            .ignoresSafeArea()
                    }
                } else {
                    SeasonScene(season: season)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func step(_ d: Int) {
        withAnimation(.easeInOut) {
            index = (index + d + charts.count) % charts.count
            zoom = 1
        }
    }
    
    func btn(_ icon: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 44, height: 36)
        }
        .buttonStyle(.borderedProminent)
    }
    
    @ViewBuilder var chartImage: some View {
        if let _ = UIImage(named: chart.asset) {
            Image(chart.asset)
                .resizable()
                .scaledToFit()
        } else {
            AsyncImage(url: URL(string: "https://ai-application-layer-extended.vercel.app")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Text("Add \(chart.asset).png to asset catalog")
                    .foregroundColor(.secondary)
            }
        }
    }
}
