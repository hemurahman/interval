import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("II")
                .font(.system(size: 72, weight: .bold, design: .serif))
            
            Text("Interval V2")
                .font(.title)
            
            Text("✅ Project Setup Complete!")
                .foregroundColor(.green)
            
            Text("All your files have been restored.\nNow add the Supabase package to continue.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
