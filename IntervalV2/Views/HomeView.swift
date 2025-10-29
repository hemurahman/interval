import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("II")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .padding(.leading)
                    Spacer()
                }
                .padding(.vertical, 12)
                
                if !viewModel.trendingTopics.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.trendingTopics) { topic in
                                Text(topic.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text("⚠️ " + errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                }
                
                if let featuredArticle = viewModel.featuredArticle {
                    NavigationLink(destination: ArticleDetailView(article: featuredArticle)) {
                        FeaturedArticleCard(article: featuredArticle)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 16)
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.secondaryArticles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            SecondaryArticleCard(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            if article.id == viewModel.secondaryArticles.last?.id {
                                Task {
                                    await viewModel.loadMoreArticles()
                                }
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView().padding()
                    }
                }
                .padding(.horizontal)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.loadInitialContent()
            }
        }
    }
}
