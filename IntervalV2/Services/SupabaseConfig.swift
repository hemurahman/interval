import Foundation
import Supabase

enum SupabaseConfig {
    // IMPORTANT: Add your Supabase credentials here
    // Get from: Supabase Dashboard → Project Settings → API
    static let url = URL(string: "https://jypogotnvasxgbubppxn.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5cG9nb3RudmFzeGdidWJwcHhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyNDU1OTksImV4cCI6MjA3NjgyMTU5OX0.1C3pu3uQhERBsl6cgXvHJPZ3GeWIC_f8__X_M9WFgO0"
    
    static let client: SupabaseClient = {
        // iOS Simulator HTTP/3 workaround: Use ephemeral session which behaves better
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Disable connection pooling which can cause issues with HTTP/3
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.urlCache = nil
        
        let session = URLSession(configuration: configuration)
        
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey,
            options: SupabaseClientOptions(
                global: SupabaseClientOptions.GlobalOptions(
                    session: session
                )
            )
        )
    }()
}
