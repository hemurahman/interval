import SwiftUI

struct MisinformationView: View {
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
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .padding(.top, 60)
                    
                    Text("Misinformation")
                        .font(.largeTitle.weight(.bold))
                    
                    Text("Track and analyze misinformation across news sources")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding()
                
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    MisinformationView()
}
