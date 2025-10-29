import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearchActive: Bool
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search articles...", text: $searchText)
                    .focused(isFocused)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(12)
            
            if isSearchActive && isFocused.wrappedValue {
                Button("Cancel") {
                    searchText = ""
                    isFocused.wrappedValue = false
                    isSearchActive = false
                }
                .font(.body)
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused.wrappedValue)
        .onAppear {
            // Auto-focus when search becomes active
            if isSearchActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused.wrappedValue = true
                }
            }
        }
    }
}
