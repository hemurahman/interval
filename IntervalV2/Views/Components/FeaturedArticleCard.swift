import SwiftUI

struct FeaturedArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let firstMedia = article.carouselMedia.first {
                AsyncImage(url: URL(string: firstMedia.url)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
                .frame(height: 240)
                .clipped()
                .cornerRadius(12)
            }
            
            Text(article.title)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .lineLimit(3)
            
            Text(article.subtitle)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                CoverageIndicatorView(
                    coverage: article.coverageStatus,
                    percentage: article.coveragePercentage
                )
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(16)
    }
}
