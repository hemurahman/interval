import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Binding var isSearchPageActive: Bool
    @Binding var isSearchFieldFocused: Bool
    @FocusState private var localFocusState: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Stage 3: Active search with keyboard and text field
            if isSearchFieldFocused {
                activeSearchHeader
            } else {
                // Stage 2: Brand header
                brandHeader
            }
            
            ScrollView {
                if isSearchFieldFocused {
                    // Stage 3: Minimal recent searches UI
                    minimalRecentSearchesView
                } else if viewModel.searchQuery.isEmpty {
                    // Stage 2: Full discover content
                    discoverContent
                } else {
                    // Search results
                    searchResultsContent
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadTrendingTopics()
        }
        .onChange(of: isSearchFieldFocused) { _, newValue in
            localFocusState = newValue
        }
        .onChange(of: localFocusState) { _, newValue in
            isSearchFieldFocused = newValue
        }
    }
    
    // MARK: - Brand Header (Stage 2)
    
    private var brandHeader: some View {
        HStack {
            Text("II")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .padding(.leading)
            Spacer()
        }
        .padding(.vertical, 12)
        .transition(.opacity)
    }
    
    // MARK: - Active Search Header (Stage 3)
    
    private var activeSearchHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Search articles...", text: $viewModel.searchQuery)
                        .focused($localFocusState)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            Task {
                                await viewModel.performSearch()
                            }
                        }
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                Button("Cancel") {
                    viewModel.clearSearch()
                    isSearchFieldFocused = false
                }
                .font(.body)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .onChange(of: viewModel.searchQuery) { _, newValue in
                if !newValue.isEmpty {
                    Task {
                        // Small delay for better UX
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        await viewModel.performSearch()
                    }
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Minimal Recent Searches (Stage 3)
    
    private var minimalRecentSearchesView: some View {
        VStack(spacing: 0) {
            if viewModel.searchQuery.isEmpty {
                // Show recent searches when no query
                if viewModel.recentSearches.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                            .padding(.top, 80)
                        
                        Text("No Recent Searches")
                            .font(.title2.weight(.semibold))
                        
                        Text("Your recent searches will appear here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    // Recent searches list
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.recentSearches.enumerated()), id: \.element) { index, search in
                            Button {
                                Task {
                                    await viewModel.performRecentSearch(search)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.secondary)
                                        .font(.body)
                                    
                                    Text(search)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.deleteRecentSearch(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            
                            if index < viewModel.recentSearches.count - 1 {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            } else {
                // Show search results when there's a query
                searchResultsContent
            }
        }
    }
    
    private var discoverContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recent Searches
            if !viewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Searches")
                            .font(.title2.weight(.bold))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Button("Clear") {
                            viewModel.clearRecentSearches()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                    }
                    
                    ForEach(Array(viewModel.recentSearches.enumerated()), id: \.element) { index, search in
                        Button {
                            Task {
                                await viewModel.performRecentSearch(search)
                                isSearchFieldFocused = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                
                                Text(search)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button {
                                    viewModel.deleteRecentSearch(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        
                        if index < viewModel.recentSearches.count - 1 {
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Trending Topics
            if !viewModel.trendingTopics.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Trending Topics")
                        .font(.title2.weight(.bold))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.trendingTopics) { topic in
                                Button {
                                    Task {
                                        await viewModel.searchByTopic(topic)
                                        isSearchFieldFocused = true
                                    }
                                } label: {
                                    Text(topic.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.top, 16)
    }
    
    private var searchResultsContent: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 60)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .padding(.top, 60)
            } else if viewModel.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No results found")
                        .font(.title3.weight(.semibold))
                    
                    Text("Try a different search term")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.searchResults) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            SecondaryArticleCard(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DiscoverView(
            isSearchPageActive: .constant(true),
            isSearchFieldFocused: .constant(false)
        )
    }
}
