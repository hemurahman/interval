import Foundation
import Supabase

@MainActor
class ArticleService {
    private let client = SupabaseConfig.client
    
    func fetchTopStories(limit: Int = 10, offset: Int = 0) async throws -> [Article] {
        print("📡 Fetching articles from Supabase...")
        print("📍 URL: \(SupabaseConfig.url)")
        
        do {
            let response = try await client
                .from("articles")
                .select()
                .order("is_featured", ascending: false)
                .order("priority", ascending: false)
                .order("published_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
            
            print("✅ Received response from Supabase")
            print("📦 Response data size: \(response.data.count) bytes")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let articles = try decoder.decode([Article].self, from: response.data)
            print("✅ Successfully decoded \(articles.count) articles")
            return articles
        } catch {
            print("❌ ArticleService Error: \(error)")
            print("❌ Error type: \(type(of: error))")
            if let errorData = error as? DecodingError {
                print("❌ Decoding error details: \(errorData)")
            }
            throw error
        }
    }
    
    func searchArticles(query: String) async throws -> [Article] {
        let response = try await client
            .from("articles")
            .select()
            .ilike("title", pattern: "%\(query)%")
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Article].self, from: response.data)
    }
    
    func fetchArticlesByTopic(topicId: UUID) async throws -> [Article] {
        let response = try await client
            .from("articles")
            .select()
            .contains("trending_topic_ids", value: [topicId.uuidString])
            .order("published_at", ascending: false)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Article].self, from: response.data)
    }
}
