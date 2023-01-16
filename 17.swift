// Solved partially
// Part 1 works for test input and my input
// Part 2 works for test input, but not for my input – need to spend some time debugging

import Foundation

guard let input = try? String(contentsOf: URL(filePath: "17.txt")) else {
    fatalError("File error")
}

enum Move: String {
    case left = "<"
    case right = ">"
}

let moves = input.split(separator: "").map { Move.init(rawValue: String($0))! }

struct Point: Hashable {
    let x: Int
    let y: Int
    static func + (left: Point, right: Point) -> Point { Point(x: left.x + right.x, y: left.y + right.y) }

    static func highest(_ a: Point, _ b: Point) -> Point {
        if a.y >= b.y {
            return a
        }
        return b
    }
}

enum Cell: String {
    case empty = "."
    case rock = "#"
    case floor = "-"
    case wall = "|"
}

struct Rock {
    let type: RockType
    let points: [Point]

    init(type: RockType, points: [Point]) {
        self.type = type
        self.points = points
    }

    init(type: RockType) {
        self.type = type
        self.points = type.getPoints()
    }

    func move(point: Point) -> Rock {
        return Rock(type: type, points: points.map { $0 + point })
    }
}

enum RockType: CaseIterable {
    case horizontal
    case plus
    case mirrorL
    case vertical
    case square

    func getPoints() -> [Point] {
        let origin = Point(x: 0, y: 0) // bottom left

        switch self {
            case .horizontal: return [
                origin,
                origin + Point(x: 1, y: 0),
                origin + Point(x: 2, y: 0),
                origin + Point(x: 3, y: 0)
            ]
            case .vertical: return [
                origin,
                origin + Point(x: 0, y: 1),
                origin + Point(x: 0, y: 2),
                origin + Point(x: 0, y: 3)
            ]
            case .square: return [
                origin,
                origin + Point(x: 1, y: 0),
                origin + Point(x: 0, y: 1),
                origin + Point(x: 1, y: 1)
            ]
            case .plus: return [
                origin + Point(x: 1, y: 0),
                origin + Point(x: 0, y: 1),
                origin + Point(x: 1, y: 1),
                origin + Point(x: 2, y: 1),
                origin + Point(x: 1, y: 2),
            ]
            case .mirrorL: return [
                origin + Point(x: 2, y: 2),
                origin + Point(x: 2, y: 1),
                origin + Point(x: 0, y: 0),
                origin + Point(x: 1, y: 0),
                origin + Point(x: 2, y: 0),
            ]
        }
    }

    func width() -> Int {
        switch self {
            case .horizontal: return 4
            case .plus: return 3
            case .mirrorL: return 3
            case .vertical: return 1
            case .square: return 2
        }
    }
}

enum Action {
    case jet
    case falling

    func next() -> Action {
        switch self {
            case .falling: return .jet
            case .jet: return .falling
        }
    }
}

func increment(_ value: inout Int, wrapAfter: Int) {
    value += 1
    if value > wrapAfter {
        value = 0
    }
}

class Map {
    var grid: [Point: Cell] = [:]
    let width = 7
    static let rockTypes = RockType.allCases

    var fallingRock: Rock = Rock(type: .horizontal).move(point: Point(x: 2, y: 4))
    var action = Action.jet
    var rockIndex = 0
    var moveIndex = 0
    var heights = (0..<7).map { Point(x: $0, y: 0) }

    var rocks = 0
    var height = 0

    subscript(point: Point) -> Cell {
        get {
            if point.y == 0 {
                return .floor
            }
            if point.x < 0 || point.x >= 7 {
                return .wall
            }
            return grid[point, default: .empty]
        }
        set(cell) {
            self.grid[point] = cell
        }
    }

    func engrave() {
        for point in fallingRock.points {
            self[point] = .rock
        }

        // recalculate hights
        var columns = [Int: Point]()
        for point in fallingRock.points {
            columns[point.x] = Point.highest(point, columns[point.x, default: Point(x: point.x, y: 0)])
        }
        heights = heights.map { Point.highest($0, columns[$0.x, default: $0]) }
        height = heights.map(\.y).max()!
    }

    func step() {
        let targetRock: Rock
        if action == .jet {
            let move = moves[moveIndex]
            switch move {
                case .left:
                    targetRock = fallingRock.move(point: Point(x: -1, y: 0))
                case .right: 
                    targetRock = fallingRock.move(point: Point(x: 1, y: 0))
            }
            if valid(rock: targetRock) {
                fallingRock = targetRock
            }
            increment(&moveIndex, wrapAfter: moves.endIndex - 1)
        } else {
            targetRock = fallingRock.move(point: Point(x: 0, y: -1))
            if valid(rock: targetRock) {
                fallingRock = targetRock
            } else {
                engrave()
                rocks += 1
                increment(&rockIndex, wrapAfter: Self.rockTypes.endIndex - 1)
                fallingRock = Rock.init(type: Self.rockTypes[rockIndex]).move(point: Point(x: 2, y: 4 + height))
            }
        }
        action = action.next()
    }

    func valid(rock: Rock) -> Bool {
        for point in rock.points {
            if self[point] != .empty {
                return false
            }
        }
        return true
    }

    func skyline() -> [Point] {
        let minY = heights.map(\.y).min()!
        return heights.map { $0 + Point(x: 0, y: -minY) }
    }

    func output() {
        for y in stride(from: max(height, fallingRock.points.map(\.y).max()!), to: -1, by: -1) {
            print(y, terminator: " ")
            for x in -1...width {
                let point = Point(x: x, y: y)
                let char: String
                if fallingRock.points.contains(point) {
                    char = "@"
                } else {
                    char = self[Point(x: x, y: y)].rawValue
                }
                print(char, terminator: "")
            }
            print()
        }
        print()
        print()
    }
}

struct State: Hashable {
    let rockIndex: Int
    let moveIndex: Int
    let skyline: [Point]
}

func simulate(target: Int, useCache: Bool = false) -> Int {
    let map = Map()
    var cache = [State: (rocks: Int, height: Int)]()

    while true {
        if map.rocks >= target {
            break
        }

        if useCache {
            let skyline = map.skyline()
            let state = State(rockIndex: map.rockIndex, moveIndex: map.moveIndex, skyline: skyline)
            if let entry = cache[state], entry.rocks > 0, entry.height > 0 {
                let cycleRocks = map.rocks - entry.rocks
                let cycleHeight = map.height - entry.height

                if cycleHeight > 0, cycleRocks > 0 {
                    let remainingRocks = target - map.rocks                
                    let repeats = remainingRocks / cycleRocks
                    if repeats > 0 {
                        map.rocks += repeats * cycleRocks
                        map.heights = map.heights.map { $0 + Point(x: 0, y: repeats * cycleHeight) }
                        map.height = map.heights.map(\.y).max()!
                        map.grid = Dictionary(uniqueKeysWithValues: map.heights.map{ ($0, .rock) })
                        continue
                    }
                }
            } else {
                cache[state] = (map.rocks, map.height)
            }
        }

        map.step()
    }

    return map.height
}

let answer1 = simulate(target: 2022)
print(answer1)
assert(answer1 == 3068)

let answer2 = simulate(target: 1000000000000, useCache: true)
print(answer2)
assert(answer2 == 1514285714288)