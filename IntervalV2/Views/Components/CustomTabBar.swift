import SwiftUI

enum Tab: String, CaseIterable {
    case headlines = "Headlines"
    case misinformation = "Misinformation"
    case profile = "Profile"
    case discover = "Discover"
    
    var icon: String {
        switch self {
        case .headlines:
            return "newspaper.fill"
        case .misinformation:
            return "flame.fill"
        case .profile:
            return "person.circle.fill"
        case .discover:
            return "magnifyingglass"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Binding var isSearchPageActive: Bool
    @Binding var isSearchFieldFocused: Bool
    @Binding var previousTab: Tab
    @Namespace private var animation
    @Namespace private var searchAnimation
    
    var body: some View {
        HStack(spacing: 0) {
            if isSearchPageActive {
                // Stage 2 & 3: Collapsed state - show only back button
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        isSearchPageActive = false
                        isSearchFieldFocused = false
                        selectedTab = previousTab
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: previousTab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .transition(.scale.combined(with: .opacity))
                
                Spacer()
                    .frame(width: 12)
                
                // Inactive search bar (Stage 2)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isSearchFieldFocused = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Search articles...")
                            .foregroundColor(.secondary)
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(.ultraThinMaterial)
                    .cornerRadius(28)
                }
                .matchedGeometryEffect(id: "searchBar", in: searchAnimation)
                
            } else {
                // Stage 1: Normal tab bar
                HStack(spacing: 0) {
                    // Main tab bar pill with 3 tabs
                    HStack(spacing: 0) {
                        ForEach([Tab.headlines, Tab.misinformation, Tab.profile], id: \.self) { tab in
                            TabButton(
                                tab: tab,
                                selectedTab: $selectedTab,
                                animation: animation
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                    }
                    
                    Spacer()
                        .frame(width: 12)
                    
                    // Search circle button
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                            previousTab = selectedTab == .discover ? .headlines : selectedTab
                            selectedTab = .discover
                            isSearchPageActive = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 56, height: 56)
                                .matchedGeometryEffect(id: "searchBar", in: searchAnimation)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}


struct TabButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    let animation: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .medium))
                
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(selectedTab == tab ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemBackground).opacity(0.8))
                        .matchedGeometryEffect(id: "TAB", in: animation)
                }
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .headlines
    @State private var previousTab: Tab = .headlines
    @State private var isSearchPageActive: Bool = false
    @State private var isSearchFieldFocused: Bool = false
    @State private var isTabBarHidden: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .headlines:
                    NavigationStack {
                        HomeView()
                            .environment(\.hideTabBar, $isTabBarHidden)
                    }
                case .misinformation:
                    NavigationStack {
                        MisinformationView()
                            .environment(\.hideTabBar, $isTabBarHidden)
                    }
                case .discover:
                    NavigationStack {
                        DiscoverView(
                            isSearchPageActive: $isSearchPageActive,
                            isSearchFieldFocused: $isSearchFieldFocused
                        )
                        .environment(\.hideTabBar, $isTabBarHidden)
                    }
                case .profile:
                    NavigationStack {
                        ProfileView()
                            .environment(\.hideTabBar, $isTabBarHidden)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            if !isTabBarHidden {
                CustomTabBar(
                    selectedTab: $selectedTab,
                    isSearchPageActive: $isSearchPageActive,
                    isSearchFieldFocused: $isSearchFieldFocused,
                    previousTab: $previousTab
                )
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainTabView()
}
