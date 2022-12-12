import Foundation

extension String {
    func extractInts() -> [Int] {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
    }
}

guard let input = try? String(contentsOf: URL(fileURLWithPath: "05.txt")) else {
    fatalError("File error")
}

let lines = input.components(separatedBy: CharacterSet.newlines)

guard let emptyLineIndex = lines.firstIndex(where: { $0.isEmpty }) else {
    fatalError("Parse error")
}

let numberLine = lines[emptyLineIndex.advanced(by: -1)]
let max = numberLine.extractInts().last!

// Setup
var initialStacks = Array(repeating: [Character](), count: max)
for y in (0...emptyLineIndex - 2).reversed() {
    let line = lines[y]
    for x in 0..<max {
        let n = x + 1
        let before = n - 1
        let spaces = before
        let brackets = before * 2
        let index = line.index(line.startIndex, offsetBy: spaces + brackets + n)
        let char = line[index]
        if !char.isWhitespace {
            initialStacks[x].append(char)
        }
    }
}

enum Part {
    case One
    case Two
}

func execute(part: Part) -> String {
    var stacks = initialStacks

    for y in emptyLineIndex+1..<lines.endIndex {
        let values = lines[y].extractInts()
        let (amount, from, to) = (values[0], values[1], values[2])
        
        switch part {
            case .One:
                for _ in 0..<amount {
                    guard let value = stacks[from - 1].popLast() else {
                        fatalError("Data error")
                    }
                    stacks[to - 1].append(value)
                }
            case .Two:
                var temporary = [Character]()
                for _ in 0..<amount {
                    guard let value = stacks[from - 1].popLast() else {
                        fatalError("Data error")
                    }
                    temporary.append(value)
                }
                while let value = temporary.popLast() {
                    stacks[to - 1].append(value)
                }
        }
    }
    return String(stacks.map { $0.last! })
}

let answer1 = execute(part: .One)
print(answer1)
assert(answer1 == "CNSZFDVLJ")

let answer2 = execute(part: .Two)
print(answer2)
assert(answer2 == "QNDWLMGNS")