import Foundation

// MARK: - Coverage Status
enum CoverageStatus: String, Codable {
    case suppressed = "suppressed"
    case medium = "medium"
    case wellCovered = "well_covered"
    case unknown = "unknown"
    
    var displayText: String {
        switch self {
        case .suppressed: return "Suppressed"
        case .medium: return "Medium Coverage"
        case .wellCovered: return "Well Covered"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Summary Card
struct SummaryCard: Codable, Identifiable {
    let id: UUID
    let emoji: String
    let title: String
    let body: String
    
    init(id: UUID = UUID(), emoji: String, title: String, body: String) {
        self.id = id
        self.emoji = emoji
        self.title = title
        self.body = body
    }
}

// MARK: - Evidence Card
struct EvidenceCard: Codable, Identifiable {
    let id: UUID
    let icon: String
    let headline: String
    let body: String
    let sourceUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, icon, headline, body
        case sourceUrl = "source_url"
    }
    
    init(id: UUID = UUID(), icon: String, headline: String, body: String, sourceUrl: String) {
        self.id = id
        self.icon = icon
        self.headline = headline
        self.body = body
        self.sourceUrl = sourceUrl
    }
}

// MARK: - Media Item
struct MediaItem: Codable, Identifiable {
    let id: UUID
    let type: MediaType
    let url: String
    
    enum MediaType: String, Codable {
        case image
        case video
    }
    
    init(id: UUID = UUID(), type: MediaType, url: String) {
        self.id = id
        self.type = type
        self.url = url
    }
}

// MARK: - Article
struct Article: Codable, Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let summaryCards: [SummaryCard]
    let deepDive: String
    let evidenceCards: [EvidenceCard]
    let carouselMedia: [MediaItem]
    let coverageOutletIds: [UUID]
    let totalOutlets: Int
    let coveragePercentage: Int
    let coverageStatus: CoverageStatus
    let isFeatured: Bool
    let priority: Int
    let trendingTopicIds: [UUID]
    let publishedAt: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle
        case summaryCards = "summary_cards"
        case deepDive = "deep_dive"
        case evidenceCards = "evidence_cards"
        case carouselMedia = "carousel_media"
        case coverageOutletIds = "coverage_outlet_ids"
        case totalOutlets = "total_outlets"
        case coveragePercentage = "coverage_percentage"
        case coverageStatus = "coverage_status"
        case isFeatured = "is_featured"
        case priority
        case trendingTopicIds = "trending_topic_ids"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Memberwise initializer
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        summaryCards: [SummaryCard],
        deepDive: String,
        evidenceCards: [EvidenceCard],
        carouselMedia: [MediaItem],
        coverageOutletIds: [UUID],
        totalOutlets: Int,
        coveragePercentage: Int,
        coverageStatus: CoverageStatus,
        isFeatured: Bool,
        priority: Int,
        trendingTopicIds: [UUID],
        publishedAt: Date,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.summaryCards = summaryCards
        self.deepDive = deepDive
        self.evidenceCards = evidenceCards
        self.carouselMedia = carouselMedia
        self.coverageOutletIds = coverageOutletIds
        self.totalOutlets = totalOutlets
        self.coveragePercentage = coveragePercentage
        self.coverageStatus = coverageStatus
        self.isFeatured = isFeatured
        self.priority = priority
        self.trendingTopicIds = trendingTopicIds
        self.publishedAt = publishedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        deepDive = try container.decode(String.self, forKey: .deepDive)
        totalOutlets = try container.decode(Int.self, forKey: .totalOutlets)
        coveragePercentage = try container.decode(Int.self, forKey: .coveragePercentage)
        coverageStatus = try container.decode(CoverageStatus.self, forKey: .coverageStatus)
        isFeatured = try container.decode(Bool.self, forKey: .isFeatured)
        priority = try container.decode(Int.self, forKey: .priority)
        publishedAt = try container.decode(Date.self, forKey: .publishedAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode JSONB arrays - they might come as strings from Supabase
        if let cardsArray = try? container.decode([SummaryCard].self, forKey: .summaryCards) {
            summaryCards = cardsArray
        } else {
            summaryCards = []
        }
        
        if let evidenceArray = try? container.decode([EvidenceCard].self, forKey: .evidenceCards) {
            evidenceCards = evidenceArray
        } else {
            evidenceCards = []
        }
        
        if let mediaArray = try? container.decode([MediaItem].self, forKey: .carouselMedia) {
            carouselMedia = mediaArray
        } else {
            carouselMedia = []
        }
        
        if let outletArray = try? container.decode([UUID].self, forKey: .coverageOutletIds) {
            coverageOutletIds = outletArray
        } else {
            coverageOutletIds = []
        }
        
        if let topicArray = try? container.decode([UUID].self, forKey: .trendingTopicIds) {
            trendingTopicIds = topicArray
        } else {
            trendingTopicIds = []
        }
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: publishedAt)
    }
}

// MARK: - Trending Topic
struct TrendingTopic: Codable, Identifiable {
    let id: UUID
    let name: String
    let displayOrder: Int
    let isActive: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case displayOrder = "display_order"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
    
    init(id: UUID = UUID(), name: String, displayOrder: Int, isActive: Bool, createdAt: Date) {
        self.id = id
        self.name = name
        self.displayOrder = displayOrder
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
