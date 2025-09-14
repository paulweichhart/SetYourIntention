import SwiftUI

struct IntentionProgressView: View {
    
    // TODO: implement
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    let progress: Double
    let percentage: Int
    
    private let width = Style.size
    
    var body: some View {
        GeometryReader { geometry in

            let angle = progress * 360
            let diameter = geometry.size.height
            ZStack {
                
                // Background ring
                Circle()
                    .stroke(progress >= 1.0 ? Colors.foreground.value : Colors.background.value,
                            style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .frame(width: diameter, height: diameter)
                
                // Progress
                Circle()
                    .trim(from: 0, to: progress.truncatingRemainder(dividingBy: 1))
                    .stroke(Colors.foreground.value,
                            style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(.degrees(-90))
                
                // Moving Cursor
                Circle()
                    .frame(width: width, height: width)
                    .position(x: diameter / 2 + (diameter / 2) * cos(angle * .pi / 180),
                              y: diameter / 2 + (diameter / 2) * sin(angle * .pi / 180))
                    .foregroundStyle(Colors.foreground.value)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Colors.shadow.value,
                            radius: 0.7,
                            x: cos(angle * .pi / 180) * 3,
                            y: sin(angle * .pi / 180) * 3)
                
            }
            .frame(width: geometry.size.height, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .accessibility(label: Text(Texts.progressInMinutes.localisation))
            .accessibility(value: Text("\(percentage)"))
            .accessibility(addTraits: .isHeader)
        }
    }
}


#Preview {
    IntentionProgressView(progress: 0.99999999, percentage: 150)
        .frame(width: .zero)
}
