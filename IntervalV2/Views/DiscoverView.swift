import SwiftUI

struct DiscoverView: View {
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
                
                VStack(spacing: 16) {
                    Image(systemName: "binoculars.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 60)
                    
                    Text("Discover")
                        .font(.largeTitle.weight(.bold))
                    
                    Text("Explore topics and stories from around the world")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    DiscoverView()
}
