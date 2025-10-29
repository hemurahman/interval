import Foundation
import SwiftUI
import Supabase

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [Article] = []
    @Published var recentSearches: [String] = []
    @Published var trendingTopics: [TrendingTopic] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let articleService = ArticleService()
    private let trendingTopicService = TrendingTopicService()
    private let client = SupabaseConfig.client
    
    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 10
    
    init() {
        loadRecentSearches()
    }
    
    // MARK: - Recent Searches
    
    func loadRecentSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: recentSearchesKey) {
            recentSearches = saved
        }
    }
    
    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        
        // Add to front
        recentSearches.insert(trimmed, at: 0)
        
        // Keep only max number of searches
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
    
    func deleteRecentSearch(at index: Int) {
        guard index < recentSearches.count else { return }
        recentSearches.remove(at: index)
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    // MARK: - Trending Topics
    
    func loadTrendingTopics() async {
        do {
            trendingTopics = try await trendingTopicService.fetchActiveTrendingTopics()
        } catch {
            print("❌ Error loading trending topics: \(error)")
        }
    }
    
    // MARK: - Search
    
    func performSearch() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Add to recent searches
            addRecentSearch(query)
            
            // Perform full-text search across multiple fields
            searchResults = try await searchArticlesFullText(query: query)
            
            print("✅ Search completed: \(searchResults.count) results found")
        } catch {
            print("❌ Search error: \(error)")
            errorMessage = "Search failed. Please try again."
            searchResults = []
        }
        
        isLoading = false
    }
    
    private func searchArticlesFullText(query: String) async throws -> [Article] {
        print("🔍 Searching for: \(query)")
        
        // Use Supabase's or operator to search across multiple fields
        // Search in: title, subtitle, deep_dive
        // Note: For JSONB fields (summary_cards, evidence_cards), we'd need a different approach
        // or use PostgreSQL full-text search if configured
        
        let response = try await client
            .from("articles")
            .select()
            .or("title.ilike.%\(query)%,subtitle.ilike.%\(query)%,deep_dive.ilike.%\(query)%")
            .order("published_at", ascending: false)
            .limit(50)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Article].self, from: response.data)
    }
    
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        errorMessage = nil
    }
    
    func performRecentSearch(_ query: String) async {
        searchQuery = query
        await performSearch()
    }
    
    func searchByTopic(_ topic: TrendingTopic) async {
        isLoading = true
        errorMessage = nil
        
        do {
            searchResults = try await articleService.fetchArticlesByTopic(topicId: topic.id)
            searchQuery = topic.name
            addRecentSearch(topic.name)
        } catch {
            print("❌ Topic search error: \(error)")
            errorMessage = "Failed to load articles for this topic."
            searchResults = []
        }
        
        isLoading = false
    }
}
