import SwiftUI

struct ContentView: View {
    @State private var firstNumber = 12
    @State private var secondNumber = 34
    @State private var result: Int? = nil
    @State private var animateResult = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 50) {
                Text("かけ算")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .padding(.top, 40)

                HStack(alignment: .center, spacing: 30) {
                    NumberInputView(value: $firstNumber)

                    Text("×")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.secondary)

                    NumberInputView(value: $secondNumber)
                }

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        result = firstNumber * secondNumber
                        animateResult = true
                    }
                } label: {
                    Text("計算する")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 64)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)

                if let result = result {
                    VStack(spacing: 8) {
                        Text("\(firstNumber) × \(secondNumber) =")
                            .font(.system(size: 28, design: .rounded))
                            .foregroundColor(.secondary)

                        Text("\(result)")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .scaleEffect(animateResult ? 1.0 : 0.5)
                    }
                    .transition(.opacity.combined(with: .scale))
                }

                Spacer()
            }
            .padding(.horizontal, 40)
        }
    }
}

struct NumberInputView: View {
    @Binding var value: Int

    var body: some View {
        VStack(spacing: 14) {
            Button {
                if value < 99 { value += 1 }
            } label: {
                Image(systemName: "chevron.up.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)

            Text("\(value)")
                .font(.system(size: 80, weight: .bold, design: .monospaced))
                .frame(width: 160, height: 100)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 4)

            Button {
                if value > 10 { value -= 1 }
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ContentView()
}
