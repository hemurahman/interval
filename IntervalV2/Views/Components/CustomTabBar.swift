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
    @Namespace private var animation
    
    var body: some View {
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
            
            // Separate search button
            Button {
                selectedTab = .discover
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(selectedTab == .discover ? .primary : .secondary)
                }
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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .headlines:
                    NavigationStack {
                        HomeView()
                    }
                case .misinformation:
                    NavigationStack {
                        MisinformationView()
                    }
                case .discover:
                    NavigationStack {
                        DiscoverView()
                    }
                case .profile:
                    NavigationStack {
                        ProfileView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainTabView()
}
