import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "04.txt")) else {
    fatalError("File error")
}

struct Assignment {
    let start: Int
    let end: Int

    func contains(_ other: Assignment) -> Bool {
        return start <= other.start && end >= other.end
    }

    func overlap(_ other: Assignment) -> Bool {
        return (start >= other.start && start <= other.end) || (other.start >= start && other.start <= end)
    }
}

struct Pair {
    let first: Assignment
    let second: Assignment

    func hasFullOverlap() -> Bool {
        return first.contains(second) || second.contains(first)
    }

    func hasSomeOverlap() -> Bool {
        return first.overlap(second) || second.overlap(first)
    }
}

struct List {
    let pairs: [Pair]

    static func from(_ input: String) -> List {
        return List(pairs: input.components(separatedBy: .newlines).map { line in
            let assignments: [Assignment] = line.components(separatedBy: ",").map { part in
                let indices: [Int] = part.components(separatedBy: "-").map { stringIndex in
                    guard let index = Int(stringIndex) else {
                        fatalError("Parse error")
                    }
                    return index
                }
                return Assignment(start: indices[0], end: indices[1])
            }
            return Pair(first: assignments[0], second: assignments[1])
        })
    }

    func countFullOverlaps() -> Int {
        return pairs.reduce(0, { acc, pair in acc + (pair.hasFullOverlap() ? 1 : 0) })
    }

    func countSomeOverlaps() -> Int {
        return pairs.reduce(0, { acc, pair in acc + (pair.hasSomeOverlap() ? 1 : 0) })
    }
}

let list = List.from(input)

let answer1 = list.countFullOverlaps()
print(answer1)
assert(answer1 == 494)

let answer2 = list.countSomeOverlaps()
print(answer2)
assert(answer2 == 833)