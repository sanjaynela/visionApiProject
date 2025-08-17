import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Vision API Demo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Experience Apple's On-Device AI")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Features
                    VStack(spacing: 20) {
                        FeatureCard(
                            icon: "text.viewfinder",
                            title: "Text Recognition",
                            description: "Extract text from images with confidence scores and beautiful visualizations",
                            color: .blue
                        )
                        
                        FeatureCard(
                            icon: "rectangle.dashed",
                            title: "Rectangle Detection",
                            description: "Perfect for document scanning and receipt processing",
                            color: .orange
                        )
                        
                        FeatureCard(
                            icon: "figure.stand",
                            title: "Body Pose Detection",
                            description: "Track 17 key body joints for fitness and AR applications",
                            color: .green
                        )
                        
                        FeatureCard(
                            icon: "barcode.viewfinder",
                            title: "Barcode Detection",
                            description: "Support for QR codes, UPC, EAN, and more barcode formats",
                            color: .purple
                        )
                    }
                    
                    // Benefits
                    VStack(spacing: 16) {
                        Text("Why Vision Framework?")
                            .font(.headline)
                            .padding(.top, 20)
                        
                        BenefitRow(icon: "lock.shield", text: "Privacy - All processing on-device")
                        BenefitRow(icon: "bolt", text: "Speed - No network latency")
                        BenefitRow(icon: "dollarsign.circle", text: "Free - No API costs or rate limits")
                        BenefitRow(icon: "link", text: "Integration - Seamless SwiftUI support")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Get Started Button
                    Button(action: {
                        hasSeenWelcome = true
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Inspired by the Medium article:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\"How I Taught My iPhone to 'See' Like a Human\"")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
}
