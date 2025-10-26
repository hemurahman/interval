import Foundation
import Supabase

@MainActor
class NetworkTest {
    static func testConnection() async {
        print("🧪 Testing Supabase connection...")
        print("📍 URL: \(SupabaseConfig.url)")
        
        do {
            // Test 1: Simple select
            print("🧪 Test 1: Fetching trending topics...")
            let response = try await SupabaseConfig.client
                .from("trending_topics")
                .select()
                .execute()
            
            print("✅ Test 1 PASSED: Received \(response.data.count) bytes")
            print("📦 Raw response: \(String(data: response.data, encoding: .utf8) ?? "Unable to decode")")
            
            // Test 2: Decode to model
            print("🧪 Test 2: Decoding to TrendingTopic model...")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let topics = try decoder.decode([TrendingTopic].self, from: response.data)
            print("✅ Test 2 PASSED: Decoded \(topics.count) topics")
            topics.forEach { print("  - \($0.name)") }
            
            // Test 3: Articles
            print("🧪 Test 3: Fetching articles...")
            let articlesResponse = try await SupabaseConfig.client
                .from("articles")
                .select()
                .limit(1)
                .execute()
            
            print("✅ Test 3 PASSED: Received \(articlesResponse.data.count) bytes")
            print("📦 Raw article response (first 500 chars): \(String(data: articlesResponse.data, encoding: .utf8)?.prefix(500) ?? "Unable to decode")")
            
            print("🎉 ALL NETWORK TESTS PASSED!")
            
        } catch {
            print("❌ NETWORK TEST FAILED")
            print("❌ Error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Localized: \(error.localizedDescription)")
            
            if let urlError = error as? URLError {
                print("❌ URLError code: \(urlError.code.rawValue)")
                print("❌ URLError description: \(urlError.localizedDescription)")
            }
        }
    }
}
