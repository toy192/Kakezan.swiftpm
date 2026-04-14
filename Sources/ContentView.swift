import SwiftUI

struct ContentView: View {
    @State private var firstNumber = 12
    @State private var secondNumber = 34
    @State private var result: Int? = nil
    @State private var showDetail = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
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
                    .onChange(of: firstNumber) { _, _ in
                        result = nil
                        showDetail = false
                    }
                    .onChange(of: secondNumber) { _, _ in
                        result = nil
                        showDetail = false
                    }

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            result = firstNumber * secondNumber
                            showDetail = true
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

                    if showDetail, let result = result {
                        StepByStepView(a: firstNumber, b: secondNumber, result: result)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - 途中経過ビュー

struct StepByStepView: View {
    let a: Int
    let b: Int
    let result: Int

    var a1: Int { a / 10 }   // aの十の位
    var a0: Int { a % 10 }   // aの一の位
    var b1: Int { b / 10 }   // bの十の位
    var b0: Int { b % 10 }   // bの一の位

    var p1: Int { a1 * 10 * b1 * 10 }  // 十×十
    var p2: Int { a1 * 10 * b0 }        // 十×一
    var p3: Int { a0 * b1 * 10 }        // 一×十
    var p4: Int { a0 * b0 }             // 一×一

    var body: some View {
        VStack(spacing: 16) {

            // STEP 1: 分解
            StepCard(number: 1, title: "十の位と一の位に分解") {
                HStack(spacing: 24) {
                    DecomposeView(number: a, tens: a1, ones: a0, color: .blue)
                    Text("×")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.secondary)
                    DecomposeView(number: b, tens: b1, ones: b0, color: .orange)
                }
                .frame(maxWidth: .infinity)
            }

            // STEP 2: 4つの部分積
            StepCard(number: 2, title: "それぞれ掛け合わせる") {
                VStack(spacing: 10) {
                    PartialRow(
                        lhs: "\(a1 * 10) × \(b1 * 10)",
                        hint: "（十の位 × 十の位）",
                        value: p1,
                        color: .purple
                    )
                    PartialRow(
                        lhs: "\(a1 * 10) × \(b0)",
                        hint: "（十の位 × 一の位）",
                        value: p2,
                        color: .teal
                    )
                    PartialRow(
                        lhs: "\(a0) × \(b1 * 10)",
                        hint: "（一の位 × 十の位）",
                        value: p3,
                        color: .teal
                    )
                    PartialRow(
                        lhs: "\(a0) × \(b0)",
                        hint: "（一の位 × 一の位）",
                        value: p4,
                        color: .red
                    )
                }
            }

            // STEP 3: 合計
            StepCard(number: 3, title: "すべて足し合わせる") {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        SumChip(value: p1, color: .purple)
                        Text("+").foregroundColor(.secondary).font(.title2)
                        SumChip(value: p2, color: .teal)
                        Text("+").foregroundColor(.secondary).font(.title2)
                        SumChip(value: p3, color: .teal)
                        Text("+").foregroundColor(.secondary).font(.title2)
                        SumChip(value: p4, color: .red)
                    }
                    .minimumScaleFactor(0.5)

                    Divider()

                    Text("\(result)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - パーツ

struct StepCard<Content: View>: View {
    let number: Int
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text("STEP \(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .cornerRadius(8)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct DecomposeView: View {
    let number: Int
    let tens: Int
    let ones: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text("\(number)")
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text("= \(tens * 10) + \(ones)")
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

struct PartialRow: View {
    let lhs: String
    let hint: String
    let value: Int
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(lhs)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                Text(hint)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("= \(value)")
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

struct SumChip: View {
    let value: Int
    let color: Color

    var body: some View {
        Text("\(value)")
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

// MARK: - 数字入力

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
