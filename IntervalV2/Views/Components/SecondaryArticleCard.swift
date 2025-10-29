import SwiftUI

struct SecondaryArticleCard: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let firstMedia = article.carouselMedia.first {
                AsyncImage(url: URL(string: firstMedia.url)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(3)
                
                Spacer()
                
                HStack {
                    Text(article.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    CoverageIndicatorView(
                        coverage: article.coverageStatus,
                        percentage: article.coveragePercentage,
                        showLabel: false
                    )
                }
            }
        }
        .frame(height: 100)
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(12)
    }
}
