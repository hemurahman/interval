import SwiftUI

struct ProfileView: View {
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
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                        .padding(.top, 60)
                    
                    Text("Profile")
                        .font(.largeTitle.weight(.bold))
                    
                    Text("Manage your account and preferences")
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
    ProfileView()
}
