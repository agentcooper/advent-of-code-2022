import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "03.txt")) else {
    fatalError("File error")
}

struct Rucksack {
    let first: Set<Character>
    let second: Set<Character>

    static func from(_ characters: String) -> Rucksack {
        let halfLength = characters.count / 2
        let firstPart = characters.prefix(halfLength)
        let secondPart = characters.suffix(halfLength)
        return Rucksack(first: Set(Array(firstPart)), second: Set(Array(secondPart)))
    }

    func getCommon() -> Character? {
        return first.intersection(second).first
    }

    func allItems() -> Set<Character> {
        return first.union(second)
    }

    static func getScore(_ character: Character) -> Int {
        guard let value = character.asciiValue else {
            fatalError("Parse error")
        }
        switch character.isLowercase {
            case true: return Int(value) - Int(Character("a").asciiValue!) + 1
            case false: return Int(value) - Int(Character("A").asciiValue!) + 27
        }
    }
}

struct ElfGroup {
    let rucksacks: [Rucksack]

    func findCommon() -> Character? {
        return rucksacks.reduce(rucksacks.first!.allItems(), { acc, value in acc.intersection(value.allItems()) }).first
    }
}

let rucksacks = input.components(separatedBy: .newlines).map { Rucksack.from($0) }

let scores1: [Int] = rucksacks.map {
    guard let common = $0.getCommon() else {
        fatalError("Data error")
    }
    return Rucksack.getScore(common)
}

let answer1 = scores1.reduce(0, +)
print(answer1)
assert(answer1 == 7742)

let groups = stride(from: 0, to: rucksacks.endIndex, by: 3).map {
    ElfGroup(rucksacks: Array(rucksacks[$0..<min($0+3, rucksacks.count)]))
}

let scores2: [Int] = groups.map {
    guard let common = $0.findCommon() else {
        fatalError("Data error")
    }
    return Rucksack.getScore(common)
}
let answer2 = scores2.reduce(0, +)
print(answer2)
assert(answer2 == 2276)