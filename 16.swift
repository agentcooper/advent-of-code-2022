// Based on https://github.com/gereons/AoC2022/blob/main/Sources/Day16/Day16.swift

import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "16.txt")) else {
    fatalError("File error")
}

extension Set {
    public func combinations() -> [Set<Element>] {
        var result = [Set<Element>]()
        for element in self {
            let oneElementCombo = Set([element])
            for i in 0..<result.count {
                result.append(oneElementCombo.union(result[i]))
            }
            result.append(oneElementCombo)
        }
        return result
    }
}

struct Valve {
    let name: String
    let flow: Int
    let leads: [String]

    init(_ description: String) {
        let parts = description.components(separatedBy: ";")
        let firstParts = parts[0].components(separatedBy: CharacterSet.init(charactersIn: " ="))
        self.name = firstParts[1]
        self.flow = Int(firstParts.last!)!
        self.leads = Array(parts[1].components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }.dropFirst(4))
    }
}

class Graph {
    var valves: [String: Valve]

    init(_ valves: [Valve]) {
        self.valves = valves.reduce(into: [:], { $0[$1.name] = $1 })
    }

    func distances() -> [String: [String: Int]] {
        let flowValves = valves.values.filter { $0.name == "AA" || $0.flow > 0 }.map { $0.name }

        let result = flowValves.map { valve in
            var distances = [valve: 0]
            var queue = [valve]
            while !queue.isEmpty {
                let current = queue.removeFirst()
                for next in valves[current]!.leads {
                    let newDistance = distances[current]! + 1
                    if newDistance < distances[next, default: Int.max] {
                        distances[next] = newDistance
                        queue.append(next)
                    }
                }
            }
            distances = distances.filter { valves[$0.key]!.flow > 0 }
            return (valve, distances)
        }
        return Dictionary(uniqueKeysWithValues: result)
    }

    func searchPaths(from valve: String,
                            timeAllowed: Int,
                            visited: Set<String> = [],
                            distances: [String: [String: Int]],
                            timeTaken: Int = 0,
                            totalFlow: Int = 0
    ) -> Int {
        let next = distances[valve]!
            .map { ($0, $1) }
            .filter { valve, _ in !visited.contains(valve) }
            .filter { _, distance in timeTaken + distance + 1 < timeAllowed }

        var maxFlow = Int.min
        for (nextValve, distance) in next {
            let flow = searchPaths(from: nextValve,
                                   timeAllowed: timeAllowed,
                                   visited: visited.union(Set([nextValve])),
                                   distances: distances,
                                   timeTaken: timeTaken + distance + 1,
                                   totalFlow: totalFlow + ((timeAllowed - timeTaken - distance - 1) * valves[nextValve]!.flow)
            )
            maxFlow = max(maxFlow, flow)
        }

        return maxFlow != Int.min ? maxFlow : totalFlow
    }
}

let lines = input.components(separatedBy: .newlines)
let graph = Graph(lines.map { Valve($0) })

// part 1
let distances = graph.distances()
let answer1 = graph.searchPaths(from: "AA", timeAllowed: 30, distances: distances)
print(answer1)
assert(answer1 == 1701)

// part 2
let valves = Set(distances.keys.filter { $0 != "AA" })
var answer2 = Int.min
let halfSizedCombinations = valves.combinations().filter { $0.count == distances.count / 2 }
for halfOfValves in halfSizedCombinations {
    let myPart = graph.searchPaths(from: "AA", timeAllowed: 26, visited: Set(halfOfValves), distances: distances)
    let elephant = graph.searchPaths(from: "AA", timeAllowed: 26, visited: valves.subtracting(Set(halfOfValves)), distances: distances)
    answer2 = max(answer2, myPart + elephant)
}
print(answer2)
assert(answer2 == 2455)