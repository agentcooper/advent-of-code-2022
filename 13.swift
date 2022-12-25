import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "13.txt")) else {
    fatalError("File error")
}

enum Node: Equatable {
    case value(Int)
    case list([Node])

    static func parse(_ input: String) -> Self {
        var stack = [Node]()
        var currentNumber: Int? = nil

        for char in input {
            if char == "[" {
                currentNumber = nil
                stack.append(Node.list([]))
            }

            if char == "," || char == "]" {
                if let currentNumber = currentNumber {
                    stack[stack.endIndex - 1] = stack[stack.endIndex - 1].append(Node.value(currentNumber))
                }
                currentNumber = nil
            }

            if char == "]" {
                let value = stack.popLast()!
                if stack.isEmpty {
                    if value.toString() != input {
                        fatalError("Parse gone wrong")
                    }
                    return value
                }
                stack[stack.endIndex - 1] = stack[stack.endIndex - 1].append(value)
            }

            if let numberValue = char.wholeNumberValue {
                if currentNumber == nil {
                    currentNumber = numberValue
                } else {
                    currentNumber = currentNumber! * 10 + numberValue
                }
            }
        }

        fatalError("Parse error")
    }

    func append(_ node: Node) -> Node {
        switch self {
            case .list(let values): return Node.list(values + [node])
            case .value: fatalError("Can't append to a value")
        }
    }

    func toString() -> String {
        switch self {
            case .value(let value): return "\(value)"
            case .list(let values): return "[\(values.map { $0.toString() }.joined(separator: ","))]"
        }
    }
}

enum Order {
    case correct
    case incorrect
    case unknown
}

func checkOrder(_ a: Node, _ b: Node) -> Order {
    switch (a, b) {
        case (Node.value(let aValue), Node.value(let bValue)):
            if aValue < bValue {
                return .correct
            }
            if aValue > bValue {
                return .incorrect
            }
            return .unknown

        case (Node.list(let aValues), Node.list(let bValues)):
            var lastOrder: Order = .unknown
            for (aValue, bValue) in zip(aValues, bValues) {
                lastOrder = checkOrder(aValue, bValue) 
                switch lastOrder {
                    case .correct: return .correct
                    case .unknown: continue
                    case .incorrect: return .incorrect
                }
            }
            if lastOrder == .unknown {
                if aValues.count < bValues.count {
                    return .correct
                }
                if aValues.count > bValues.count {
                    return .incorrect
                }
                return .unknown
            }
            return .correct

        case (Node.list, Node.value):
            return checkOrder(a, Node.list([b]))

        case (Node.value, Node.list):
            return checkOrder(Node.list([a]), b)
    }
}

// part 1
let packets = input.components(separatedBy: .newlines).filter { !$0.isEmpty }.map { Node.parse($0) }
var indices = [Int]()
for i in 0..<packets.count/2 {
    let a = packets[2*i]
    let b = packets[2*i+1]
    if checkOrder(a, b) == .correct {
        indices.append(i + 1)
    }
}
let answer1 = indices.reduce(0, +)
print(answer1)
assert(answer1 == 5623)

// part 2
let divider1 = Node.parse("[[2]]")
let divider2 = Node.parse("[[6]]")
var allPackets = packets + [divider1, divider2]
allPackets.sort { (a, b) in
    switch checkOrder(a, b) {
        case .correct: return true
        case .incorrect: return false
        case .unknown: fatalError("Unexpected")
    }
}
let index1 = allPackets.firstIndex(where: { $0 == divider1 })! + 1
let index2 = allPackets.firstIndex(where: { $0 == divider2 })! + 1
let answer2 = index1 * index2
print(answer2)
assert(answer2 == 20570)