import SwiftUI

enum Season: String, CaseIterable, Identifiable, Hashable {
    case winter, spring, summer, autumn, vimeoBanner
    var id: String { rawValue }
    var task: String {
        switch self {
        case .winter: return "Robotic street snow remover"
        case .spring: return "Robotic pouring of plants"
        case .summer: return "Robotic gardener designing a lawn"
        case .autumn: return "Robotic sorting of fruits"
        case .vimeoBanner: return "Video showcase presentation"
        }
    }
    var sky: UIColor {
        switch self {
        case .winter: return UIColor(red: 0.75, green: 0.82, blue: 0.9, alpha: 1)
        case .spring: return UIColor(red: 0.45, green: 0.55, blue: 0.62, alpha: 1)
        case .summer: return UIColor(red: 0.35, green: 0.65, blue: 0.95, alpha: 1)
        case .autumn: return UIColor(red: 0.85, green: 0.62, blue: 0.38, alpha: 1)
        case .vimeoBanner: return UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1)
        }
    }
    var ground: UIColor {
        switch self {
        case .winter: return .white
        case .spring: return UIColor(red: 0.2, green: 0.5, blue: 0.25, alpha: 1)
        case .summer: return UIColor(red: 0.3, green: 0.65, blue: 0.2, alpha: 1)
        case .autumn: return UIColor(red: 0.5, green: 0.32, blue: 0.15, alpha: 1)
        case .vimeoBanner: return UIColor.darkGray
        }
    }
}

struct Chart: Identifiable {
    let id: Int, title: String, asset: String, season: Season
}
let charts = [
    Chart(id: 0, title: "1. Marimekko: true vs predicted subtopic", asset: "1_marimekko", season: .winter),
    Chart(id: 1, title: "2. Dendrogram: semantic proximity", asset: "2_dendrogram", season: .spring),
    Chart(id: 2, title: "3. Stream graph: mix vs post length", asset: "3_streamgraph", season: .summer),
    Chart(id: 3, title: "4. Radial bars: precision@K and F1", asset: "4_radial_bars", season: .autumn),
    Chart(id: 4, title: "Video Showcase", asset: "video", season: .vimeoBanner)
]
