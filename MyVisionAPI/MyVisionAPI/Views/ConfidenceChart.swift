import SwiftUI
import Charts

struct ConfidenceChart: View {
    let data: [TextConfidence]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Text Recognition Confidence")
                .font(.headline)
                .foregroundColor(.primary)
            
            if data.isEmpty {
                Text("No text detected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Text", String(item.text.prefix(20))),
                        y: .value("Confidence", item.confidence)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartYScale(domain: 0...1)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            Text("\(value.as(Double.self)?.formatted(.percent) ?? "")")
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            Text(value.as(String.self) ?? "")
                                .font(.caption)
                                .rotationEffect(.degrees(-45))
                        }
                    }
                }
            }
            
            // Summary statistics
            if !data.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        StatCard(
                            title: "Total Texts",
                            value: "\(data.count)",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Avg Confidence",
                            value: String(format: "%.1f%%", data.map(\.confidence).reduce(0, +) / Double(data.count) * 100),
                            color: .green
                        )
                        
                        StatCard(
                            title: "High Confidence",
                            value: "\(data.filter { $0.confidence > 0.8 }.count)",
                            color: .orange
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ConfidenceChart(data: [
        TextConfidence(text: "Hello", confidence: 0.95, boundingBox: .zero),
        TextConfidence(text: "World", confidence: 0.87, boundingBox: .zero),
        TextConfidence(text: "Vision", confidence: 0.92, boundingBox: .zero),
        TextConfidence(text: "API", confidence: 0.78, boundingBox: .zero)
    ])
    .padding()
}
