import SwiftUI

struct ContentView: View {
    @State private var firstNumber = 12
    @State private var secondNumber = 34
    @State private var result: Int? = nil
    @State private var showDetail = false
    @State private var showFactorTable = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("かけ算")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .padding(.top, 40)

                    HStack(alignment: .center, spacing: 20) {
                        NumberInputView(value: $firstNumber)
                        Text("×")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.secondary)
                        NumberInputView(value: $secondNumber)
                    }
                    .onChange(of: firstNumber) { _, _ in result = nil; showDetail = false }
                    .onChange(of: secondNumber) { _, _ in result = nil; showDetail = false }

                    HStack(spacing: 16) {
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

                        Button {
                            showFactorTable = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "tablecells")
                                Text("素因数表")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 110, height: 64)
                            .background(Color.purple)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }

                    if showDetail, let r = result {
                        HissanView(a: firstNumber, b: secondNumber, result: r)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))

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
        .sheet(isPresented: $showFactorTable) {
            FactorTableView()
        }
    }
}

// MARK: - 普通の筆算

struct HissanView: View {
    let a: Int, b: Int, result: Int

    var b0: Int { b % 10 }
    var b1: Int { b / 10 }
    var p0: Int { a * b0 }
    var p1: Int { a * b1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.and.ruler.fill")
                    .foregroundColor(.teal)
                    .font(.title2)
                Text("筆算")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.teal)
            }

            VStack(alignment: .trailing, spacing: 6) {
                Text("\(a)")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))

                HStack(spacing: 6) {
                    Text("×")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.secondary)
                    Text("\(b)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                }

                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.primary.opacity(0.4))

                // a × 一の位
                HStack(spacing: 8) {
                    Text("← \(a)×\(b0)")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.7))
                    Text(b0 == 0 ? "0" : "\(p0)")
                        .font(.system(size: 30, weight: .semibold, design: .monospaced))
                        .foregroundColor(.red)
                }

                // a × 十の位（シフト）
                if b1 > 0 {
                    HStack(spacing: 8) {
                        Text("← \(a)×\(b1*10)")
                            .font(.system(size: 12))
                            .foregroundColor(.blue.opacity(0.7))
                        HStack(spacing: 0) {
                            Text("\(p1)")
                                .font(.system(size: 30, weight: .semibold, design: .monospaced))
                                .foregroundColor(.blue)
                            Text("0")
                                .font(.system(size: 30, weight: .semibold, design: .monospaced))
                                .foregroundColor(.blue.opacity(0.35))
                        }
                    }
                }

                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.primary.opacity(0.4))

                Text("\(result)")
                    .font(.system(size: 52, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
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

    // 方法③: おみやげ算（条件: 十の位が同じ）
    var isOmiyageApplicable: Bool { a / 10 == b / 10 }
    var omiyageT: Int    { a / 10 }
    var omiyageA0: Int   { a % 10 }
    var omiyageB0: Int   { b % 10 }
    var omiyageStep1: Int { a + omiyageB0 }
    var omiyageStep2: Int { omiyageT * 10 * omiyageStep1 }
    var omiyageStep3: Int { omiyageA0 * omiyageB0 }
    var isClassicCase: Bool { omiyageA0 + omiyageB0 == 10 }

    // 方法④: インド式・クロス計算（縦・斜め・縦）
    var a1: Int { a / 10 }
    var a0: Int { a % 10 }
    var b1: Int { b / 10 }
    var b0: Int { b % 10 }
    var crossRight: Int { a0 * b0 }
    var crossMid:   Int { a1 * b0 + a0 * b1 }
    var crossLeft:  Int { a1 * b1 }
    var crossRightDigit: Int { crossRight % 10 }
    var crossRightCarry: Int { crossRight / 10 }
    var crossMidTotal:   Int { crossMid + crossRightCarry }
    var crossMidDigit:   Int { crossMidTotal % 10 }
    var crossMidCarry:   Int { crossMidTotal / 10 }
    var crossLeftTotal:  Int { crossLeft + crossMidCarry }

    // 方法⑤: 素因数分解
    func primeFactors(of n: Int) -> [Int] {
        var factors: [Int] = []
        var m = n
        var d = 2
        while d * d <= m {
            while m % d == 0 { factors.append(d); m /= d }
            d += 1
        }
        if m > 1 { factors.append(m) }
        return factors
    }
    var factorsA: [Int] { primeFactors(of: a) }
    var factorsB: [Int] { primeFactors(of: b) }
    var isFactorMethodApplicable: Bool { factorsA.count > 1 || factorsB.count > 1 }
    // 因数の多い方を分解し、もう一方から順番に掛ける
    var useFactorsOfB: Bool { factorsB.count >= factorsA.count }
    var factorBase:    Int  { useFactorsOfB ? a : b }
    var factorFactors: [Int] { useFactorsOfB ? factorsB : factorsA }
    var factorTarget:  Int  { useFactorsOfB ? b : a }
    var factorSteps: [(factor: Int, result: Int)] {
        var steps: [(factor: Int, result: Int)] = []
        var current = factorBase
        for f in factorFactors { current *= f; steps.append((f, current)) }
        return steps
    }

    // 方法⑥: 素因数を統合・組み換えて10を作る
    var allPrimeFactors: [Int] { (factorsA + factorsB).sorted() }

    func niceGroupings(from factors: [Int]) -> [Int] {
        var counts = [Int: Int]()
        for f in factors { counts[f, default: 0] += 1 }
        var groups = [Int]()
        // 2 × 5 → 10
        let numTens = min(counts[2, default: 0], counts[5, default: 0])
        for _ in 0..<numTens { groups.append(10) }
        if let c = counts[2] { let r = c - numTens; if r > 0 { counts[2] = r } else { counts.removeValue(forKey: 2) } }
        if let c = counts[5] { let r = c - numTens; if r > 0 { counts[5] = r } else { counts.removeValue(forKey: 5) } }
        // 残り: 同じ素因数をまとめる
        for prime in counts.keys.sorted() {
            guard let cnt = counts[prime], cnt > 0 else { continue }
            var val = 1; for _ in 0..<cnt { val *= prime }
            groups.append(val)
        }
        // 10の倍数を先頭に、残りは大きい順
        return groups.sorted { lhs, rhs in
            let lRound = lhs % 10 == 0, rRound = rhs % 10 == 0
            if lRound != rRound { return lRound }
            return lhs > rhs
        }
    }
    var regrouped: [Int] { niceGroupings(from: allPrimeFactors) }
    var regroupSteps: [(factor: Int, result: Int)] {
        guard regrouped.count > 1 else { return [] }
        var steps = [(Int, Int)]()
        var current = regrouped[0]
        for i in 1..<regrouped.count { current *= regrouped[i]; steps.append((regrouped[i], current)) }
        return steps
    }
    // a と b の「異なる数」由来の 2 と 5 を組み合わせて初めて 10 ができるときに表示
    var isRegroupApplicable: Bool {
        let a2 = factorsA.filter { $0 == 2 }.count, a5 = factorsA.filter { $0 == 5 }.count
        let b2 = factorsB.filter { $0 == 2 }.count, b5 = factorsB.filter { $0 == 5 }.count
        return min(a2 + b2, a5 + b5) > min(a2, a5) + min(b2, b5)
    }

    // 方法⑦: ゾロ目（11の倍数）計算
    var isZoromeA: Bool { a >= 11 && a % 11 == 0 && a / 11 <= 9 }
    var isZoromeB: Bool { b >= 11 && b % 11 == 0 && b / 11 <= 9 }
    var isZoromeApplicable: Bool { isZoromeA || isZoromeB }
    var zoromeBase: Int  { isZoromeA ? a : b }   // ゾロ目の数
    var zoromeOther: Int { isZoromeA ? b : a }   // 掛ける相手
    var zoromeDigit: Int { zoromeBase / 11 }      // ゾロ目の一桁
    var zoromeOther1: Int { zoromeOther / 10 }
    var zoromeOther0: Int { zoromeOther % 10 }
    var zoromeMidSum: Int { zoromeOther1 + zoromeOther0 }
    var zoromeCarry: Int  { zoromeMidSum / 10 }
    var zoromeMidDigit: Int { zoromeMidSum % 10 }
    var zoromeX11: Int { 11 * zoromeOther }
    private var zoromeBaseName: String { "\(zoromeDigit) × 11" }

    // キャッシュプロパティ（型推論コスト削減）
    private var factorsAStr: String { factorsA.map { String($0) }.joined(separator: " × ") }
    private var factorsBStr: String { factorsB.map { String($0) }.joined(separator: " × ") }
    private var factorsACompact: String { factorsA.map { String($0) }.joined(separator: "×") }
    private var factorsBCompact: String { factorsB.map { String($0) }.joined(separator: "×") }
    private var factorTargetStr: String { factorFactors.map { String($0) }.joined(separator: " × ") }
    private var allFactorsStr: String { allPrimeFactors.map { String($0) }.joined(separator: " × ") }
    private var regroupedStr: String { regrouped.map { String($0) }.joined(separator: " × ") }
    private var regroupBase: Int { regrouped.first ?? result }
    private var regroupRoundCount: Int { regrouped.filter { $0 % 10 == 0 }.count }

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
            method1Card
            if bDiff != 0 { method2Card }
            if isOmiyageApplicable { method3Card }
            method4Card
            if isFactorMethodApplicable { method5Card }
            if isRegroupApplicable { method6Card }
            if isZoromeApplicable { method7Card }
        }
    }

    // MARK: 各方法カード（独立プロパティで型推論コストを分散）

    private var method1Card: some View {
        MentalCard(title: "方法①　2段階で計算する") {
            VStack(alignment: .leading, spacing: 10) {
                Text("一の位 → 十の位 の順に掛けて、最後に足す")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                MentalRow(circled: "①", formula: "\(a) × \(bOnes)（一の位）", value: partOnes, color: .orange)
                MentalRow(circled: "②", formula: "\(a) × \(bTens)（十の位）", value: partTens, color: .green)
                Divider()
                HStack {
                    Text("③ 合計").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(partOnes) + \(partTens) = \(result)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private var method2Card: some View {
        MentalCard(title: "方法②　キリのいい数に丸めて補正する") {
            VStack(alignment: .leading, spacing: 10) {
                Text(isRoundedUp
                    ? "\(b) を \(bRounded) に切り上げて計算し、余分を引く"
                    : "\(b) を \(bRounded) に切り捨てて計算し、不足を足す")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                MentalRow(circled: "①", formula: "\(a) × \(bRounded)", value: roundedProduct, color: .purple)
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("② 補正").font(.system(size: 15, weight: .semibold))
                        Text(isRoundedUp
                            ? "\(bRounded)−\(b)=\(abs(bDiff)) → \(a)×\(abs(bDiff))=\(adjustAmount) を引く"
                            : "\(b)−\(bRounded)=\(abs(bDiff)) → \(a)×\(abs(bDiff))=\(adjustAmount) を足す")
                            .font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(isRoundedUp ? "−\(adjustAmount)" : "+\(adjustAmount)")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(isRoundedUp ? .red : .green)
                }
                Divider()
                HStack {
                    Text("③ 合計").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(roundedProduct) \(isRoundedUp ? "−" : "+") \(adjustAmount) = \(result)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private var method3Card: some View {
        MentalCard(title: "方法③　おみやげ算 🎁") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("十の位が同じ（\(omiyageT)）のとき使える方法")
                        .font(.system(size: 13)).foregroundColor(.secondary)
                    if isClassicCase {
                        Text("✨ 一の位の和が10")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(.orange)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15)).cornerRadius(6)
                    }
                }
                HStack(spacing: 4) {
                    Group {
                        Text("\(omiyageT)").foregroundColor(.blue)
                        Text("\(omiyageA0)").foregroundColor(.orange)
                    }
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    Text(" × ").font(.system(size: 26, weight: .bold)).foregroundColor(.secondary)
                    Group {
                        Text("\(omiyageT)").foregroundColor(.blue)
                        Text("\(omiyageB0)").foregroundColor(.green)
                    }
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                }
                .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)
                Text("bの一の位（\(omiyageB0)）を「おみやげ」としてaに渡す")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                HStack {
                    Text("①").font(.system(size: 15, weight: .bold)).frame(width: 24)
                    Text("\(a) + \(omiyageB0)（おみやげを渡す）")
                        .font(.system(size: 15, design: .monospaced)).foregroundColor(.secondary)
                    Spacer()
                    Text("= \(omiyageStep1)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(isClassicCase ? .orange : .primary)
                }
                if isClassicCase {
                    Text("　→ キリのいい数になる！")
                        .font(.system(size: 12)).foregroundColor(.orange).padding(.leading, 28)
                }
                MentalRow(circled: "②",
                          formula: "\(omiyageT * 10) × \(omiyageStep1)（十の位×受け取った数）",
                          value: omiyageStep2, color: .blue)
                MentalRow(circled: "③",
                          formula: "\(omiyageA0) × \(omiyageB0)（一の位どうし）",
                          value: omiyageStep3, color: .orange)
                Divider()
                HStack {
                    Text("④ 合計").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(omiyageStep2) + \(omiyageStep3) = \(result)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private var method4Card: some View {
        MentalCard(title: "方法④　インド式・クロス計算 ✕") {
            VStack(alignment: .leading, spacing: 12) {
                Text("縦・斜め・縦の3ゾーンに分けて計算する")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                CrossDiagramView(a1: a1, a0: a0, b1: b1, b0: b0)
                VStack(spacing: 8) {
                    crossRow("①", "一の位：\(a0) × \(b0) = \(crossRight)",
                             crossRightCarry, crossRightDigit,
                             "\(crossRightDigit) を書いて \(crossRightCarry) 繰り上げ", .red)
                    crossRow("②",
                             "十の位：\(a1)×\(b0) + \(a0)×\(b1)\(crossRightCarry > 0 ? " + \(crossRightCarry)" : "") = \(crossMidTotal)",
                             crossMidCarry, crossMidDigit,
                             "\(crossMidDigit) を書いて \(crossMidCarry) 繰り上げ", .orange)
                    crossRow("③",
                             "百の位：\(a1) × \(b1)\(crossMidCarry > 0 ? " + \(crossMidCarry)" : "") = \(crossLeftTotal)",
                             0, crossLeftTotal, "", .purple)
                }
                Divider()
                HStack {
                    Text("④ 桁を並べる").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    (Text("\(crossLeftTotal)").foregroundColor(.purple) +
                     Text("\(crossMidDigit)").foregroundColor(.orange) +
                     Text("\(crossRightDigit)").foregroundColor(.red) +
                     Text("  =  \(result)").foregroundColor(.blue))
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                }
            }
        }
    }

    @ViewBuilder
    private func crossRow(_ label: String, _ desc: String,
                          _ carry: Int, _ digit: Int,
                          _ carryText: String, _ color: Color) -> some View {
        HStack(alignment: .top) {
            Text(label).font(.system(size: 15, weight: .bold)).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(desc).font(.system(size: 14, design: .monospaced)).minimumScaleFactor(0.75)
                if carry > 0 {
                    Text("　→ \(carryText)").font(.system(size: 12)).foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("→ \(digit)")
                .font(.system(size: 20, weight: .bold, design: .monospaced)).foregroundColor(color)
        }
    }

    private var method5Card: some View {
        let steps = factorSteps
        let circ = ["①","②","③","④","⑤","⑥","⑦","⑧"]
        return MentalCard(title: "方法⑤　素因数分解で計算する") {
            VStack(alignment: .leading, spacing: 12) {
                Text("数を素因数に分解し、小さい数の掛け算を繰り返す")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(a) =").foregroundColor(.secondary)
                        Text(factorsAStr).foregroundColor(.blue)
                    }.font(.system(size: 15, design: .monospaced))
                    HStack(spacing: 4) {
                        Text("\(b) =").foregroundColor(.secondary)
                        Text(factorsBStr).foregroundColor(.orange)
                    }.font(.system(size: 15, design: .monospaced))
                }
                .padding(10).background(Color(.secondarySystemBackground)).cornerRadius(8)
                Text("\(factorTarget) = \(factorTargetStr) なので \(factorBase) から順に掛ける")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                VStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { idx in
                        let prev = idx == 0 ? factorBase : steps[idx - 1].result
                        MentalRow(circled: idx < circ.count ? circ[idx] : "\(idx+1)",
                                  formula: "\(prev) × \(steps[idx].factor)",
                                  value: steps[idx].result, color: .teal)
                    }
                }
                Divider()
                HStack {
                    Text("答え").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(factorBase) × \(factorTargetStr) = \(result)")
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue).minimumScaleFactor(0.7)
                }
            }
        }
    }

    private var method6Card: some View {
        let steps = regroupSteps
        let circ = ["①","②","③","④","⑤","⑥","⑦","⑧"]
        return MentalCard(title: "方法⑥　因数を統合・組み換えて計算する") {
            VStack(alignment: .leading, spacing: 12) {
                Text("a と b の素因数をまとめて、2 と 5 を組み合わせて 10 を作る")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("\(a) =").foregroundColor(.secondary)
                        Text(factorsACompact).foregroundColor(.blue)
                        Text("  \(b) =").foregroundColor(.secondary)
                        Text(factorsBCompact).foregroundColor(.orange)
                    }.font(.system(size: 14, design: .monospaced))
                    HStack(spacing: 4) {
                        Text("全素因数:").foregroundColor(.secondary)
                        Text(allFactorsStr).foregroundColor(.primary)
                    }.font(.system(size: 13, design: .monospaced))
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down").foregroundColor(.teal).font(.system(size: 11))
                        Text("組み換え:").foregroundColor(.teal).font(.system(size: 13, weight: .semibold))
                        Text(regroupedStr)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.teal)
                    }
                    Text("✓ キリのいい数が \(regroupRoundCount) 個できた！")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.teal)
                }
                .padding(10).background(Color(.secondarySystemBackground)).cornerRadius(8)
                if !steps.isEmpty {
                    Text("〔\(regroupBase)〕から順に掛ける")
                        .font(.system(size: 13)).foregroundColor(.secondary)
                    VStack(spacing: 6) {
                        ForEach(0..<steps.count, id: \.self) { idx in
                            let prev = idx == 0 ? regroupBase : steps[idx - 1].result
                            MentalRow(circled: idx < circ.count ? circ[idx] : "\(idx+1)",
                                      formula: "\(prev) × \(steps[idx].factor)",
                                      value: steps[idx].result, color: .teal)
                        }
                    }
                }
                Divider()
                HStack {
                    Text("答え").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(regroupedStr) = \(result)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue).minimumScaleFactor(0.65)
                }
            }
        }
    }

    private var method7Card: some View {
        MentalCard(title: "方法⑦　ゾロ目（11の倍数）で計算する") {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(zoromeBase) = \(zoromeBaseName) なので、まず 11 × \(zoromeOther) を求める")
                    .font(.system(size: 13)).foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("【× 11 のコツ】十の位・(十+一)の位・一の位 と並べる")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(.orange)
                    HStack(spacing: 6) {
                        Group {
                            Text("\(zoromeOther1 + zoromeCarry)")
                                .foregroundColor(.purple)
                            Text(zoromeCarry > 0 ? "\(zoromeMidDigit)←繰上" : "\(zoromeMidDigit)")
                                .foregroundColor(.orange)
                            Text("\(zoromeOther0)")
                                .foregroundColor(.red)
                        }
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .frame(minWidth: 36)
                        .padding(6)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        Text("= \(zoromeX11)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                    if zoromeCarry > 0 {
                        Text("　十の位+一の位 = \(zoromeMidSum) なので十の位に1繰り上げ")
                            .font(.system(size: 12)).foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(Color.orange.opacity(0.06))
                .cornerRadius(10)

                MentalRow(circled: "①",
                          formula: "11 × \(zoromeOther)",
                          value: zoromeX11, color: .orange)
                MentalRow(circled: "②",
                          formula: "\(zoromeDigit) × \(zoromeX11)",
                          value: result, color: .blue)
                Divider()
                HStack {
                    Text("答え").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(zoromeDigit) × \(zoromeX11) = \(result)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
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

// MARK: - 桁ごとの数字入力

struct NumberInputView: View {
    @Binding var value: Int

    var tens: Int { value / 10 }
    var ones: Int { value % 10 }

    var body: some View {
        HStack(spacing: 8) {
            DigitSelector(label: "十", digit: tens, range: 1...9) { value = $0 * 10 + ones }
            DigitSelector(label: "一", digit: ones, range: 0...9) { value = tens * 10 + $0 }
        }
    }
}

struct DigitSelector: View {
    let label: String
    let digit: Int
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    var canIncrement: Bool { digit < range.upperBound }
    var canDecrement: Bool { digit > range.lowerBound }

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            Button {
                if canIncrement { onChange(digit + 1) }
            } label: {
                Image(systemName: "chevron.up.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(canIncrement ? .blue : Color(.systemGray4))
            }
            .buttonStyle(.plain)

            Text("\(digit)")
                .font(.system(size: 68, weight: .bold, design: .monospaced))
                .frame(width: 80, height: 86)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(radius: 3)

            Button {
                if canDecrement { onChange(digit - 1) }
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(canDecrement ? .blue : Color(.systemGray4))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - クロス計算図

struct CrossDiagramView: View {
    let a1: Int, a0: Int, b1: Int, b0: Int

    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            // 数字の表示（色分け）
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    digitBox("\(a1)", .purple)
                    digitBox("\(a0)", .red)
                }
                HStack(spacing: 4) {
                    Text("×")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    digitBox("\(b1)", .purple)
                    digitBox("\(b0)", .red)
                }
            }

            // ゾーン説明
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 11))
                        .foregroundColor(.purple)
                    Text("百の位：")
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                    Text("\(a1) × \(b1)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.purple)
                }
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    Text("十の位：")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("\(a1)×\(b0) + \(a0)×\(b1)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.orange)
                }
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                    Text("一の位：")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    Text("\(a0) × \(b0)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.red)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    @ViewBuilder
    func digitBox(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.system(size: 30, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .frame(width: 42, height: 42)
            .background(color.opacity(0.12))
            .cornerRadius(8)
    }
}

// MARK: - 素因数表ヘルパー

private func isPrimeNumber(_ n: Int) -> Bool {
    guard n >= 2 else { return false }
    if n == 2 { return true }
    if n % 2 == 0 { return false }
    var i = 3
    while i * i <= n {
        if n % i == 0 { return false }
        i += 2
    }
    return true
}

private func primeFactorsOf(_ n: Int) -> [Int] {
    var result = [Int]()
    var num = n
    var d = 2
    while d * d <= num {
        while num % d == 0 {
            result.append(d)
            num /= d
        }
        d += 1
    }
    if num > 1 { result.append(num) }
    return result
}

private func factorLabel(_ n: Int) -> String {
    if n == 1 { return "1" }
    if isPrimeNumber(n) { return "素数" }
    let factors = primeFactorsOf(n)
    var counts = [Int: Int]()
    for f in factors { counts[f, default: 0] += 1 }
    let superscripts = ["2": "²", "3": "³", "4": "⁴", "5": "⁵", "6": "⁶"]
    let parts = counts.keys.sorted().map { p -> String in
        let c = counts[p]!
        let exp = c > 1 ? (superscripts["\(c)"] ?? "^\(c)") : ""
        return "\(p)\(exp)"
    }
    return parts.joined(separator: "×")
}

// MARK: - 素因数表ビュー

struct FactorTableView: View {
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1..<100) { n in
                        FactorCell(n: n)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("素因数表 1〜99")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

struct FactorCell: View {
    let n: Int

    private var cellColor: Color {
        if n == 1 { return .gray }
        return isPrimeNumber(n) ? .orange : .blue
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(n)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(cellColor)
            Text(factorLabel(n))
                .font(isPrimeNumber(n)
                    ? .system(size: 16, weight: .bold, design: .rounded)
                    : .system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(cellColor.opacity(0.85))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(cellColor.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
