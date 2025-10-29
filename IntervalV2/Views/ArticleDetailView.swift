import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @State private var selectedTab = 0
    @State private var showCoverageSheet = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(article.title)
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Image carousel
                        if !article.carouselMedia.isEmpty {
                            TabView {
                                ForEach(article.carouselMedia) { media in
                                    AsyncImage(url: URL(string: media.url)) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle().fill(Color.gray.opacity(0.2))
                                    }
                                    .frame(height: 260)
                                    .clipped()
                                }
                            }
                            .frame(height: 260)
                            .tabViewStyle(.page(indexDisplayMode: .always))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        Text(article.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Text(article.subtitle)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                    .background(Color(UIColor.systemBackground))
                    
                    // Tab Bar
                    HStack(spacing: 0) {
                        ArticleTabButton(title: "Summary", isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        ArticleTabButton(title: "Deep Dive", isSelected: selectedTab == 1) {
                            withAnimation { selectedTab = 1 }
                        }
                        ArticleTabButton(title: "Evidence", isSelected: selectedTab == 2) {
                            withAnimation { selectedTab = 2 }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Tab Content
                    Group {
                        if selectedTab == 0 {
                            SummaryTabView(article: article)
                        } else if selectedTab == 1 {
                            DeepDiveTabView(article: article)
                        } else {
                            EvidenceTabView(article: article)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100) // Add padding for bottom nav
                }
            }
            
            // Bottom Navigation Bar
            BottomNavigationBar(
                coverageStatus: article.coverageStatus,
                showCoverageSheet: $showCoverageSheet,
                onBack: { dismiss() }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 && gesture.startLocation.x < 50 {
                        dismiss()
                    }
                }
        )
        .overlay {
            if showCoverageSheet {
                CoverageDetailSheet(
                    article: article,
                    isPresented: $showCoverageSheet
                )
                .zIndex(1)
            }
        }
        .onChange(of: showCoverageSheet) {
            // Trigger animation
        }
    }
}

// MARK: - Article Tab Button
struct ArticleTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.primary)
                        .frame(height: 2)
                } else {
                    Color.clear
                        .frame(height: 2)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// MARK: - Summary Tab
struct SummaryTabView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(article.summaryCards) { card in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(card.emoji)
                            .font(.title2)
                        Text(card.title)
                            .font(.headline)
                    }
                    Text(card.body)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Deep Dive Tab
struct DeepDiveTabView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(article.deepDive)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(6)
        }
        .padding(.horizontal)
    }
}

// MARK: - Evidence Tab
struct EvidenceTabView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if article.evidenceCards.isEmpty {
                Text("No evidence cards available.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(article.evidenceCards) { card in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            // Icon/Logo
                            Image(systemName: card.icon)
                                .font(.title2)
                                .foregroundColor(.red)
                                .frame(width: 50, height: 50)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.headline)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Text(card.body)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Link(destination: URL(string: card.sourceUrl)!) {
                            HStack {
                                Text("View source")
                                    .font(.subheadline.weight(.medium))
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    let coverageStatus: CoverageStatus
    @Binding var showCoverageSheet: Bool
    let onBack: () -> Void
    @State private var isBookmarked = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Back Button
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                
                // Coverage Meter
                Button(action: { showCoverageSheet = true }) {
                    HStack(spacing: 8) {
                        // Progress bar with background and fill
                        ZStack(alignment: .leading) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 2)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                                .frame(width: 60, height: 4)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 2)
                                .fill(colorScheme == .dark ? Color.white : Color.black)
                                .frame(width: 60 * coverageProgress, height: 4)
                        }
                        
                        Text(coverageStatusText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .fixedSize()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { isBookmarked.toggle() }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Button(action: shareArticle) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 8)
            }
            .frame(height: 84)
            .background(
                Color(UIColor.systemBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
            )
        }
    }
    
    private var coverageProgress: CGFloat {
        switch coverageStatus {
        case .suppressed:
            return 0.25
        case .medium:
            return 0.5
        case .wellCovered:
            return 1.0
        case .unknown:
            return 0.0
        }
    }
    
    private var coverageStatusText: String {
        switch coverageStatus {
        case .suppressed:
            return "Suppressed"
        case .medium:
            return "Medium"
        case .wellCovered:
            return "Well Covered"
        case .unknown:
            return "Unknown"
        }
    }
    
    private func shareArticle() {
        // Placeholder for share functionality
    }
}

// MARK: - Coverage Detail Sheet
struct CoverageDetailSheet: View {
    let article: Article
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dimmed background overlay
                Color.black
                    .opacity(calculateBackgroundOpacity())
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissSheet()
                    }
                
                // Sheet content
                VStack(spacing: 0) {
                    Spacer(minLength: 140)
                    
                    VStack(spacing: 0) {
                        // Pull-down tab indicator
                        VStack(spacing: 0) {
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 36, height: 5)
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissSheet()
                        }
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                // Coverage status header
                                VStack(alignment: .center, spacing: 12) {
                                    Text("Coverage is")
                                        .font(.custom("PPEditorialNew-Regular", size: 28))
                                    
                                    Text(coverageStatusText.uppercased())
                                        .font(.custom("PPEditorialNew-Italic", size: 38))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                                
                                // Visual meter and stats
                                VStack(alignment: .leading, spacing: 16) {
                                    ZStack(alignment: .leading) {
                                        // Background bar
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 6)
                                        
                                        // Progress fill
                                        Rectangle()
                                            .fill(Color.black)
                                            .frame(width: (geometry.size.width - 48) * coverageProgress, height: 6)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                                        Text("\(article.coveragePercentage)/\(article.totalOutlets)")
                                            .font(.system(size: 48, weight: .bold))
                                        
                                        Text("Major outlets have\ncovered this headline.")
                                            .font(.system(size: 18))
                                            .foregroundColor(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(.horizontal, 24)
                                
                                // Controversial outlets section
                                if !controversialOutlets.isEmpty {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Controversial outlets")
                                            .font(.system(size: 22, weight: .bold))
                                            .padding(.horizontal, 24)
                                        
                                        ForEach(controversialOutlets, id: \.name) { outlet in
                                            HStack(alignment: .top, spacing: 16) {
                                                // Outlet logo
                                                ZStack {
                                                    Rectangle()
                                                        .fill(outlet.color)
                                                        .frame(width: 50, height: 50)
                                                        .cornerRadius(8)
                                                    
                                                    Text(outlet.logoText)
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .multilineTextAlignment(.center)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(outlet.name)
                                                        .font(.system(size: 18, weight: .bold))
                                                    
                                                    Text(outlet.description)
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.primary)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(16)
                                            .background(Color(UIColor.secondarySystemBackground))
                                            .cornerRadius(12)
                                            .padding(.horizontal, 24)
                                        }
                                    }
                                    .padding(.top, 16)
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(32)
                    .ignoresSafeArea(edges: .bottom)
                    .offset(y: max(0, dragOffset))
                    .gesture(
                        DragGesture()
                            .updating($isDragging) { _, state, _ in
                                state = true
                            }
                            .onChanged { gesture in
                                if gesture.translation.height > 0 {
                                    dragOffset = gesture.translation.height
                                }
                            }
                            .onEnded { gesture in
                                if gesture.translation.height > 100 {
                                    dismissSheet()
                                } else {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                }
                .offset(y: sheetOffset)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                sheetOffset = 0
            }
        }
    }
    
    private func dismissSheet() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            sheetOffset = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    private func calculateBackgroundOpacity() -> Double {
        if dragOffset > 0 {
            let fadeRatio = dragOffset / 300.0
            return 0.7 * (1.0 - fadeRatio)
        }
        return 0.7
    }
    
    private var coverageProgress: CGFloat {
        CGFloat(article.coveragePercentage) / CGFloat(article.totalOutlets)
    }
    
    private var coverageStatusText: String {
        switch article.coverageStatus {
        case .suppressed:
            return "Suppressed"
        case .medium:
            return "Medium"
        case .wellCovered:
            return "Well Covered"
        case .unknown:
            return "Unknown"
        }
    }
    
    // Mock controversial outlets data
    private var controversialOutlets: [(name: String, logoText: String, color: Color, description: String)] {
        [
            (
                name: "The BBC",
                logoText: "BBC\nNEWS",
                color: Color.red,
                description: "recently had a coalition of over 400 media figures, including 111 BBC journalists and freelancers, sign an open letter, alleging systematic editorial censorship in Gaza reporting."
            ),
            (
                name: "The New York Times",
                logoText: "T",
                color: Color.black,
                description: "has been criticized for editorial constraints discouraging terms like \"genocide,\" \"ethnic cleansing,\" and \"occupied territory,\" and for underrepresenting plaintiff perspectives in Gaza."
            ),
            (
                name: "CNN",
                logoText: "CNN",
                color: Color.red,
                description: "reportedly avoids using terms like \"genocide\" on air and downplays Palestinian civilian casualties; internal sources have described editorial suppression of terms such as \"war crimes\" and \"apartheid.\""
            )
        ]
    }
}
