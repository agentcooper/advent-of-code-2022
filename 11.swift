import Foundation

extension String {
    func extractInts() -> [Int] {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
    }
}

guard let input = try? String(contentsOf: URL(fileURLWithPath: "11.txt")) else {
    fatalError("File error")
}

indirect enum Expression {
    case constant(Int)
    case sum(Expression, Expression)
    case product(Expression, Expression)

    func add(_ value: Int) -> Expression {
        .sum(self, .constant(value))
    }

    func multiply(_ value: Int) -> Expression {
        .product(self, .constant(value))
    }

    func square() -> Expression {
        .product(self, self)
    }

    func calculate() -> Int {
        switch self {
            case .constant(let value): return value
            case .product(let a, let b): return a.calculate() * b.calculate()
            case .sum(let a, let b): return a.calculate() + b.calculate()
        }
    }

    func modulo(_ other: Int) -> Int {
        switch self {
            case .constant(let value): return value % other
            case .sum(let a, let b): return ((a.calculate() % other) + (b.calculate() % other)) % other
            case .product(let a, let b): return ((a.calculate() % other) * (b.calculate() % other)) % other
        }
    }
}

enum Operation {
    case plus(Int)
    case multiply(Int)
    case square

    func apply(_ value: Int) -> Int {
        switch self {
            case .multiply(let other): return value * other
            case .plus(let other): return value + other
            case .square: return value * value
        }
    }
}

class Monkey {
    var items: [Int]
    var inspectedItems = 0

    let operation: Operation
    let divisibleBy: Int
    let ifTrue: Int
    let ifFalse: Int

    func testItem(_ value: Int) -> Int {
        if value % divisibleBy == 0 {
            return ifTrue
        }
        return ifFalse
    }

    init(_ description: String) {
        let lines = description.components(separatedBy: .newlines)

        self.items = lines[1].extractInts()

        let operation: Operation
        if lines[2].contains("new = old * old") {
            operation = Operation.square
        } else if lines[2].contains("new = old + old") {
            operation = Operation.multiply(2)
        } else if lines[2].contains("new = old + ") {
            operation = Operation.plus(lines[2].extractInts()[0])
        } else if lines[2].contains("new = old * ") {
            operation = Operation.multiply(lines[2].extractInts()[0])
        } else {
            fatalError("Parse error")
        }

        self.operation = operation

        self.divisibleBy = lines[3].extractInts().first!
        self.ifTrue = lines[4].extractInts().first!
        self.ifFalse = lines[5].extractInts().first!
    }
}

var monkeys = input.components(separatedBy: "\n\n").map { Monkey($0) }
let supermodulo = monkeys.map { $0.divisibleBy }.reduce(1, *)

enum Part {
    case one
    case two

    func rounds() -> Int {
        switch self {
            case .one: return 20
            case .two: return 1000
        }
    }

    func manageWorry(value: Int) -> Int {
        switch self {
            case .one: return value / 3
            case .two: return value % supermodulo
        }
    }
}

func run(part: Part) -> Int {
    for _ in 0..<part.rounds() {
        for monkey in monkeys {
            for item in monkey.items {
                monkey.inspectedItems += 1
                let worryLevel = part.manageWorry(value: monkey.operation.apply(item))
                let newMonkeyIndex = monkey.testItem(worryLevel)
                monkeys[newMonkeyIndex].items.append(worryLevel)
            }
            monkey.items.removeAll()
        }
    }

    return monkeys.map { $0.inspectedItems }.sorted(by: >).prefix(2).reduce(1, *)
}

let answer1 = run(part: .one)
print(answer1)
assert(answer1 == 61503)

let answer2 = run(part: .two)
print(answer2)
assert(answer2 == 180391736)