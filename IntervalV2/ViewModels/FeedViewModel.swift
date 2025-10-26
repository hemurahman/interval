import Foundation
import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var trendingTopics: [TrendingTopic] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let articleService = ArticleService()
    private let topicService = TrendingTopicService()
    private var currentOffset = 0
    private let pageSize = 10
    private var loadTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    
    func loadInitialContent() async {
        loadTask?.cancel()
        loadTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                async let articlesTask = articleService.fetchTopStories(limit: pageSize)
                async let topicsTask = topicService.fetchActiveTrendingTopics()
                
                let (fetchedArticles, fetchedTopics) = try await (articlesTask, topicsTask)
                
                guard !Task.isCancelled else { return }
                
                articles = fetchedArticles
                trendingTopics = fetchedTopics
                currentOffset = pageSize
            } catch is CancellationError {
                print("🔄 Load cancelled")
            } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == -999 {
                print("🔄 URL request cancelled")
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "Failed to load content: \(error.localizedDescription)"
                print("❌ Error loading content: \(error)")
            }
            
            isLoading = false
        }
        await loadTask?.value
    }
    
    func loadMoreArticles() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let moreArticles = try await articleService.fetchTopStories(
                limit: pageSize,
                offset: currentOffset
            )
            
            articles.append(contentsOf: moreArticles)
            currentOffset += pageSize
        } catch {
            errorMessage = "Failed to load more articles"
            print("❌ Error loading more: \(error)")
        }
        
        isLoading = false
    }
    
    func refresh() async {
        refreshTask?.cancel()
        loadTask?.cancel()
        
        refreshTask = Task {
            currentOffset = 0
            errorMessage = nil
            
            do {
                async let articlesTask = articleService.fetchTopStories(limit: pageSize)
                async let topicsTask = topicService.fetchActiveTrendingTopics()
                
                let (fetchedArticles, fetchedTopics) = try await (articlesTask, topicsTask)
                
                guard !Task.isCancelled else { return }
                
                articles = fetchedArticles
                trendingTopics = fetchedTopics
                currentOffset = pageSize
            } catch is CancellationError {
                // Silently ignore cancellation errors from pull-to-refresh
                print("🔄 Refresh cancelled")
            } catch let error as NSError where error.domain == NSURLErrorDomain && error.code == -999 {
                // Silently ignore URL cancellation errors
                print("🔄 URL request cancelled")
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "Failed to load content: \(error.localizedDescription)"
                print("❌ Error loading content: \(error)")
            }
        }
        await refreshTask?.value
    }
    
    var featuredArticle: Article? {
        articles.first(where: { $0.isFeatured })
    }
    
    var secondaryArticles: [Article] {
        if featuredArticle != nil {
            return articles.filter { !$0.isFeatured }
        } else {
            return Array(articles.dropFirst())
        }
    }
}
