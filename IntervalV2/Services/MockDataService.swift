import Foundation

class MockDataService {
    static func getMockArticles() -> [Article] {
        let topic1 = UUID()
        let topic2 = UUID()
        
        return [
            Article(
                id: UUID(),
                title: "Major Climate Summit Concludes with Historic Agreement",
                subtitle: "World leaders commit to ambitious carbon reduction targets by 2030",
                summaryCards: [
                    SummaryCard(emoji: "🌍", title: "Global Commitment", body: "195 countries signed the landmark agreement."),
                    SummaryCard(emoji: "📉", title: "Emission Targets", body: "45% reduction by 2030."),
                    SummaryCard(emoji: "💰", title: "Financial Support", body: "$100 billion annually for clean energy.")
                ],
                deepDive: "The two-week climate summit brought together world leaders in what many are calling the most significant international climate agreement since the Paris Accord.",
                evidenceCards: [
                    EvidenceCard(icon: "newspaper", headline: "UN Calls It Historic", body: "The UN chief praised the agreement as a turning point.", sourceUrl: "https://example.com")
                ],
                carouselMedia: [
                    MediaItem(type: .image, url: "https://picsum.photos/800/600?random=1"),
                    MediaItem(type: .image, url: "https://picsum.photos/800/600?random=2")
                ],
                coverageOutletIds: [UUID(), UUID(), UUID()],
                totalOutlets: 8,
                coveragePercentage: 62,
                coverageStatus: .wellCovered,
                isFeatured: true,
                priority: 100,
                trendingTopicIds: [topic1, topic2],
                publishedAt: Date().addingTimeInterval(-7200),
                createdAt: Date(),
                updatedAt: Date()
            ),
            Article(
                id: UUID(),
                title: "Tech Giants Announce AI Safety Initiative",
                subtitle: "Leading companies pledge to develop artificial intelligence responsibly",
                summaryCards: [
                    SummaryCard(emoji: "🤖", title: "Industry Coalition", body: "Major tech companies form consortium."),
                    SummaryCard(emoji: "🛡️", title: "Safety Protocols", body: "Mandatory testing and audits.")
                ],
                deepDive: "In an unprecedented show of cooperation, leading AI companies announced a joint initiative to address safety concerns.",
                evidenceCards: [],
                carouselMedia: [
                    MediaItem(type: .image, url: "https://picsum.photos/800/600?random=3")
                ],
                coverageOutletIds: [UUID(), UUID()],
                totalOutlets: 8,
                coveragePercentage: 37,
                coverageStatus: .medium,
                isFeatured: false,
                priority: 90,
                trendingTopicIds: [topic2],
                publishedAt: Date().addingTimeInterval(-18000),
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
    
    static func getMockTopics() -> [TrendingTopic] {
        return [
            TrendingTopic(id: UUID(), name: "Politics", displayOrder: 1, isActive: true, createdAt: Date()),
            TrendingTopic(id: UUID(), name: "Technology", displayOrder: 2, isActive: true, createdAt: Date()),
            TrendingTopic(id: UUID(), name: "Climate", displayOrder: 3, isActive: true, createdAt: Date()),
            TrendingTopic(id: UUID(), name: "Economy", displayOrder: 4, isActive: true, createdAt: Date()),
            TrendingTopic(id: UUID(), name: "Health", displayOrder: 5, isActive: true, createdAt: Date()),
            TrendingTopic(id: UUID(), name: "Sports", displayOrder: 6, isActive: true, createdAt: Date())
        ]
    }
}
