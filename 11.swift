import Foundation

extension String {
    func extractInts() -> [Int] {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
    }
}

guard let input = try? String(contentsOf: URL(fileURLWithPath: "11.txt")) else {
    fatalError("File error")
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

for _ in 0..<20 {
    for monkey in monkeys {
        for item in monkey.items {
            monkey.inspectedItems += 1
            let worryLevel = monkey.operation.apply(item) / 3
            let newMonkeyIndex = monkey.testItem(worryLevel)
            monkeys[newMonkeyIndex].items.append(worryLevel)
        }
        monkey.items.removeAll()
    }
}

let answer1 = monkeys.map { $0.inspectedItems }.sorted(by: >).prefix(2).reduce(1, *)
print(answer1)
assert(answer1 == 61503)