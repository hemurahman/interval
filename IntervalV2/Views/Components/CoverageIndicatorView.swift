import SwiftUI

struct CoverageIndicatorView: View {
    let coverage: CoverageStatus
    let percentage: Int
    let showLabel: Bool
    
    init(coverage: CoverageStatus, percentage: Int, showLabel: Bool = true) {
        self.coverage = coverage
        self.percentage = percentage
        self.showLabel = showLabel
    }
    
    var body: some View {
        HStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(coverageColor)
                        .frame(width: geometry.size.width * CGFloat(percentage) / 100)
                }
            }
            .frame(width: 40, height: 4)
            .clipShape(Capsule())
            
            if showLabel {
                Text(coverage.displayText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(coverageColor)
            }
        }
    }
    
    private var coverageColor: Color {
        switch coverage {
        case .suppressed: return .red
        case .medium: return .orange
        case .wellCovered: return .green
        case .unknown: return .gray
        }
    }
}
