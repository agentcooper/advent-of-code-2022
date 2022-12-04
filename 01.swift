import Foundation

guard var input = try? String(contentsOf: URL(fileURLWithPath: "01.txt")) else {
    fatalError("File error")
}

let groups = input.components(separatedBy: "\n\n")

let elfs: [[Int]] = groups.map { group in
    return group.components(separatedBy: .newlines).map { line in
        guard let value = Int(line) else {
            fatalError("Parse error")
        }
        return value
    }
}

let sums = elfs.map { $0.reduce(0, +) }
let topThree = sums.sorted().suffix(3)

let answer1 = topThree.last!
let answer2 = topThree.reduce(0, +)

print(answer1)
assert(answer1 == 69289)

print(answer2)
assert(answer2 == 205615)
