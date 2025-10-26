import Foundation
import Supabase

@MainActor
class TrendingTopicService {
    private let client = SupabaseConfig.client
    
    func fetchActiveTrendingTopics() async throws -> [TrendingTopic] {
        print("📡 Fetching trending topics from Supabase...")
        
        do {
            let response = try await client
                .from("trending_topics")
                .select()
                .eq("is_active", value: true)
                .order("display_order", ascending: true)
                .execute()
            
            print("✅ Received trending topics response")
            print("📦 Response data size: \(response.data.count) bytes")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let topics = try decoder.decode([TrendingTopic].self, from: response.data)
            print("✅ Successfully decoded \(topics.count) topics")
            return topics
        } catch {
            print("❌ TrendingTopicService Error: \(error)")
            print("❌ Error type: \(type(of: error))")
            throw error
        }
    }
}
