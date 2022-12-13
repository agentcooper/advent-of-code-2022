import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "06.txt")) else {
    fatalError("File error")
}

func findMarker(windowSize: Int) -> Int {
    let chars = Array(input)
    for (i, _) in chars.enumerated() {
        if i >= windowSize - 1 {
            let s = Set(chars[i - (windowSize - 1)...i])
            if s.count == windowSize {
                return i + 1
            }
        }
    }
    fatalError("Data error")
}

let answer1 = findMarker(windowSize: 4)
assert(answer1 == 1042)
print(answer1)

let answer2 = findMarker(windowSize: 14)
assert(answer2 == 2980)
print(answer2)