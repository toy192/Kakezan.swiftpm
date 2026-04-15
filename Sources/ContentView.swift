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
                    .onChange(of: firstNumber) { _, _ in result = nil; showDetail = false }
                    .onChange(of: secondNumber) { _, _ in result = nil; showDetail = false }

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

                    if showDetail, let r = result {
                        StepByStepView(a: firstNumber, b: secondNumber, result: r)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))

                        MentalMathView(a: firstNumber, b: secondNumber, result: r)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - 筆算ステップ

struct StepByStepView: View {
    let a: Int
    let b: Int
    let result: Int

    var a1: Int { a / 10 }
    var a0: Int { a % 10 }
    var b1: Int { b / 10 }
    var b0: Int { b % 10 }

    var p1: Int { a1 * 10 * b1 * 10 }
    var p2: Int { a1 * 10 * b0 }
    var p3: Int { a0 * b1 * 10 }
    var p4: Int { a0 * b0 }

    var body: some View {
        VStack(spacing: 16) {
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

            StepCard(number: 2, title: "それぞれ掛け合わせる") {
                VStack(spacing: 10) {
                    PartialRow(lhs: "\(a1 * 10) × \(b1 * 10)", hint: "（十の位 × 十の位）", value: p1, color: .purple)
                    PartialRow(lhs: "\(a1 * 10) × \(b0)",      hint: "（十の位 × 一の位）", value: p2, color: .teal)
                    PartialRow(lhs: "\(a0) × \(b1 * 10)",      hint: "（一の位 × 十の位）", value: p3, color: .teal)
                    PartialRow(lhs: "\(a0) × \(b0)",            hint: "（一の位 × 一の位）", value: p4, color: .red)
                }
            }

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

// MARK: - 暗算セクション

struct MentalMathView: View {
    let a: Int
    let b: Int
    let result: Int

    // 方法①: 2段階計算
    var bOnes: Int { b % 10 }
    var bTens: Int { (b / 10) * 10 }
    var partOnes: Int { a * bOnes }
    var partTens: Int { a * bTens }

    // 方法②: 丸め法
    var bRounded: Int {
        let lower = (b / 10) * 10
        let upper = lower + 10
        return (b % 10 >= 5) ? upper : lower
    }
    var bDiff: Int { b - bRounded }
    var roundedProduct: Int { a * bRounded }
    var adjustAmount: Int { abs(a * bDiff) }
    var isRoundedUp: Bool { bRounded > b }

    // 方法③: おみやげ算
    // 条件: 十の位が同じ、かつ一の位の和 = 10
    var isOmiyageApplicable: Bool {
        a / 10 == b / 10 && (a % 10) + (b % 10) == 10
    }
    var omiyageT: Int  { a / 10 }
    var omiyageA0: Int { a % 10 }
    var omiyageB0: Int { b % 10 }
    var omiyageHi: Int { omiyageT * (omiyageT + 1) }   // 上の部分
    var omiyageLo: Int { omiyageA0 * omiyageB0 }         // 下の部分（2桁で表示）

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("暗算のコツ")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
            }
            .padding(.top, 4)

            // 方法①: 2段階計算
            MentalCard(title: "方法①　2段階で計算する") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("一の位 → 十の位 の順に掛けて、最後に足す")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    MentalRow(circled: "①", formula: "\(a) × \(bOnes)（一の位）", value: partOnes, color: .orange)
                    MentalRow(circled: "②", formula: "\(a) × \(bTens)（十の位）", value: partTens, color: .green)

                    Divider()
                    HStack {
                        Text("③ 合計")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text("\(partOnes) + \(partTens) = \(result)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                }
            }

            // 方法②: 丸め法
            if bDiff != 0 {
                MentalCard(title: "方法②　キリのいい数に丸めて補正する") {
                    VStack(alignment: .leading, spacing: 10) {
                        let diffAbs = abs(bDiff)
                        Text(isRoundedUp
                            ? "\(b) を \(bRounded) に切り上げて計算し、余分を引く"
                            : "\(b) を \(bRounded) に切り捨てて計算し、不足を足す")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)

                        MentalRow(circled: "①", formula: "\(a) × \(bRounded)", value: roundedProduct, color: .purple)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("② 補正")
                                    .font(.system(size: 15, weight: .semibold))
                                Text(isRoundedUp
                                    ? "\(bRounded) − \(b) = \(diffAbs)  →  \(a) × \(diffAbs) = \(adjustAmount) を引く"
                                    : "\(b) − \(bRounded) = \(diffAbs)  →  \(a) × \(diffAbs) = \(adjustAmount) を足す")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(isRoundedUp ? "−\(adjustAmount)" : "+\(adjustAmount)")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(isRoundedUp ? .red : .green)
                        }

                        Divider()
                        HStack {
                            Text("③ 合計")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            let op = isRoundedUp ? "−" : "+"
                            Text("\(roundedProduct) \(op) \(adjustAmount) = \(result)")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }

            // 方法③: おみやげ算（条件が揃った場合のみ表示）
            if isOmiyageApplicable {
                MentalCard(title: "方法③　おみやげ算 🎁") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("十の位が同じ（\(omiyageT)）で一の位の和が10（\(omiyageA0)+\(omiyageB0)=10）のとき使える特別な方法")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)

                        // 数字の視覚化
                        HStack(spacing: 4) {
                            Group {
                                Text("\(omiyageT)")
                                    .foregroundColor(.blue)
                                Text("\(omiyageA0)")
                                    .foregroundColor(.orange)
                            }
                            .font(.system(size: 36, weight: .bold, design: .monospaced))

                            Text(" × ")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.secondary)

                            Group {
                                Text("\(omiyageT)")
                                    .foregroundColor(.blue)
                                Text("\(omiyageB0)")
                                    .foregroundColor(.green)
                            }
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)

                        Text("一の位（\(omiyageA0)）を「おみやげ」として十の位（\(omiyageT)）に渡す → \(omiyageT) が \(omiyageT + 1) になる")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)

                        MentalRow(
                            circled: "①",
                            formula: "\(omiyageT) × \(omiyageT + 1)（十の位 × 受け取った後の十の位）",
                            value: omiyageHi,
                            color: .blue
                        )
                        MentalRow(
                            circled: "②",
                            formula: "\(omiyageA0) × \(omiyageB0)（一の位どうし）",
                            value: omiyageLo,
                            color: .orange
                        )

                        if omiyageLo < 10 {
                            Text("※ 一の位の積が1桁のため、先頭に0を補って2桁にする")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        HStack(alignment: .center) {
                            Text("③ つなげる")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            HStack(spacing: 1) {
                                Text("\(omiyageHi)")
                                    .foregroundColor(.blue)
                                Text(String(format: "%02d", omiyageLo))
                                    .foregroundColor(.orange)
                            }
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            Text("= \(result)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                                .padding(.leading, 4)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 共通パーツ

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

struct MentalCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

struct MentalRow: View {
    let circled: String
    let formula: String
    let value: Int
    let color: Color

    var body: some View {
        HStack {
            Text(circled)
                .font(.system(size: 15, weight: .bold))
                .frame(width: 24)
            Text(formula)
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(.secondary)
            Spacer()
            Text("= \(value)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
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
