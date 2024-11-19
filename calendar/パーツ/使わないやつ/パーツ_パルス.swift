import SwiftUI

struct PulseCircleView: View {
    let circleCount = 2
    let animationDuration = 3.0
    let animationDelay = 1.5

    @State private var pulseStates: [Bool] = []

    var body: some View {
        ZStack {
            ForEach(0..<circleCount, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(.orange)
                    .opacity(pulseStates.indices.contains(index) && pulseStates[index] ? 0 : 1.0)
                    .scaleEffect(pulseStates.indices.contains(index) && pulseStates[index] ? 3 : 1.0)
            }
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(.orange) // 静止した円
        }
        .onAppear {
            initializeStates()
            startPulseAnimation(for: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                startPulseAnimation(for: 1)
            }
        }
    }

    private func initializeStates() {
        pulseStates = Array(repeating: false, count: circleCount)
    }

    private func startPulseAnimation(for index: Int) {
        withAnimation(.linear(duration: animationDuration)) {
            pulseStates[index] = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            resetPulseAnimation(for: index)
        }
    }

    private func resetPulseAnimation(for index: Int) {
        pulseStates[index] = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            startPulseAnimation(for: index)
        }
    }
}

struct PulseCircleView_Previews: PreviewProvider {
    static var previews: some View {
        PulseCircleView()
    }
}
