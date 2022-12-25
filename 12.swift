import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "12.txt")) else {
    fatalError("File error")
}

extension Set {
    func inserting(_ newMember: Element) -> Set {
        var newSet = self
        newSet.insert(newMember)
        return newSet
    }
}

struct Position: Hashable {
    let x: Int
    let y: Int

    func add(_ other: Position) -> Position {
        Position(x: x + other.x, y: y + other.y)
    }
}

class Map {
    let heightMap: [[Int]]

    func heightAt(position: Position) -> Int {
        return heightMap[position.y][position.x]
    }

    var start = Position(x: 0, y: 0)
    var end = Position(x: 0, y: 0)

    var height: Int { heightMap.count }
    var width: Int { heightMap[0].count }

    func bottomPositions() -> [Position] {
        var result = [Position]()
        for (y, row) in heightMap.enumerated() {
            for (x, height) in row.enumerated() {
                if height == 0 {
                    result.append(Position(x: x, y: y))
                }
            }
        }
        return result
    }

    func isValid(_ position: Position) -> Bool {
        return (0..<height).contains(position.y) && (0..<width).contains(position.x)
    }

    static func convertToHeight(character: Character) -> Int {
        return Int(character.asciiValue! - Character("a").asciiValue!)
    }

    func allNeighbours(_ position: Position) -> [Position] {
        let left = Position(x: -1, y: 0)
        let right = Position(x: 1, y: 0)
        let up = Position(x: 0, y: -1)
        let down = Position(x: 0, y: 1)
        return [left, right, up, down].map { position.add($0) }.filter { isValid($0) }
    }

    func validNeighbours(_ position: Position) -> [Position] {
        let currentHeight = heightAt(position: position)
        return allNeighbours(position).filter {
            let neighbourHeight = heightAt(position: $0)
            return currentHeight <= neighbourHeight + 1
        }
    }

    init(_ input: String) {
        var start = Position(x: 0, y: 0)
        var end = Position(x: 0, y: 0)
        let lines = input.components(separatedBy: .newlines)
        var x = 0
        var y = 0
        self.heightMap = lines.map {
            defer { y += 1; x = 0 }
            return Array($0).map {
                defer { x += 1 }
                if $0 == "S" {
                    start = Position(x: x, y: y)
                    return Map.convertToHeight(character: "a")
                }
                if $0 == "E" {
                    end = Position(x: x, y: y)
                    return Map.convertToHeight(character: "z")
                }
                return Map.convertToHeight(character: $0)
            }
        }
        self.start = start
        self.end = end
    }

    struct SearchResult {
        let previous: [Position: Position]
        let distance: [Position: Int]
    }

    func dijkstra(source: Position) -> SearchResult {
        var distance = [Position: Int]()
        var prev = [Position: Position]()
        var queue = Set<Position>([source])
        var visited = Set<Position>()
        distance[source] = 0
        
        while !queue.isEmpty {
            let position = queue.min(by: { (distance[$0]!) < (distance[$1]!) })!
            queue.remove(position)
            visited.insert(position)
            for neighbor in validNeighbours(position) {
                let alt = distance[position]! + 1
                if alt < distance[neighbor] ?? .max {
                    distance[neighbor] = alt
                    prev[neighbor] = position
                }
                if !visited.contains(neighbor) {
                    queue.insert(neighbor)
                }
            }
        }
        return SearchResult(previous: prev, distance: distance)
    }
}

let map = Map(input)

let search = map.dijkstra(source: map.end)
let answer1 = search.distance[map.start]!
print(answer1)
assert(answer1 == 423)

var minimumDistance: Int = .max
for bottomPosition in map.bottomPositions() {
    if let distance = search.distance[bottomPosition] {
        minimumDistance = min(minimumDistance, distance)
    }
}
let answer2 = minimumDistance
print(answer2)
assert(answer2 == 416)