import SwiftUI
import SceneKit

struct MainScene: View {
    let open: (Season) -> Void
    @State private var index = 0
    @State private var zoom: CGFloat = 1
    var chart: Chart { charts[index] }

    var body: some View {
        ZStack {
            SceneContainer(scene: OfficeBuilder.make(), allowsControl: false).ignoresSafeArea()
            VStack(spacing: 8) {
                Text("AI Application Layer — Analytics").font(.title2.bold())
                ScrollView([.horizontal, .vertical]) {
                    chartImage.scaleEffect(zoom).frame(minWidth: 0, minHeight: 0)
                        .onTapGesture { open(chart.season) }   // tap chart -> seasonal scene
                }
                .frame(maxHeight: .infinity)
                Text("\(chart.title)  ·  tap chart → \(chart.season.rawValue) scene").font(.caption)
                HStack(spacing: 20) {
                    btn("chevron.left") { step(-1) }
                    btn("minus.magnifyingglass") { zoom = max(0.5, zoom - 0.25) }
                    btn("plus.magnifyingglass") { zoom = min(4, zoom + 0.25) }
                    btn("chevron.right") { step(1) }
                }
                HStack { ForEach(charts) { c in
                    Circle().fill(c.id == index ? .white : .white.opacity(0.3)).frame(width: 8, height: 8) } }
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 90).padding(.vertical, 16)
            .gesture(DragGesture().onEnded { $0.translation.width < -40 ? step(1) : ($0.translation.width > 40 ? step(-1) : ()) })
        }
    }
    func step(_ d: Int) { withAnimation(.easeInOut) { index = (index + d + charts.count) % charts.count; zoom = 1 } }
    func btn(_ icon: String, _ a: @escaping () -> Void) -> some View {
        Button(action: a) { Image(systemName: icon).font(.title3).frame(width: 44, height: 36) }
            .buttonStyle(.borderedProminent)
    }
    @ViewBuilder var chartImage: some View {
        if UIImage(named: chart.asset) != nil {
            Image(chart.asset).resizable().scaledToFit()
        } else {
            AsyncImage(url: URL(string: "https://ai-application-layer.vercel.app")) { $0.resizable().scaledToFit() }
                placeholder: { Text("Add \(chart.asset).png to assets").foregroundStyle(.secondary) }
        }
    }
}
