import SwiftUI

struct IntentionProgressView: View {
    
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    let progress: Double
    let percentage: Int
    let isMeditating: Bool
    
    private let width = 8.0
    
    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .frame(width: width, height: width)
                .foregroundStyle(Colors.foreground.value)
                .zIndex(10)
            ZStack {
                // Background ring
                Circle()
                    .stroke(progress >= 1.0 ? Colors.foreground.value : Colors.background.value,
                            style: StrokeStyle(lineWidth: width, lineCap: .round))
                
                let trimmedTo = isMeditating ? progress : Converter.truncate(progress: progress)
                // Shadow
                Circle()
                    .trim(from: 0, to: trimmedTo + 0.01)
                    .stroke(Color.cyan,
                            style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .opacity(progress > 0 ? 1 : 0)
                
                // Progress ring
                
                Circle()
                    .trim(from: 0, to: trimmedTo)
                    .stroke(Colors.foreground.value,
                            style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
            }.offset(y: -(width / 2))
        }
        .accessibility(label: Text(Texts.progressInMinutes.localisation))
        .accessibility(value: Text("\(percentage)"))
        .accessibility(addTraits: .isHeader)
    }
}
