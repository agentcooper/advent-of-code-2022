import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "14.txt")) else {
    fatalError("File error")
}

struct Coordinate: Hashable {
    let x: Int
    let y: Int

    static func parse(_ pair: String) -> Coordinate {
        let parts = pair.components(separatedBy: ",")
        return Coordinate(x: Int(parts[0])!, y: Int(parts[1])!)
    }

    var below: Coordinate { Coordinate(x: x, y: y + 1) }
    var belowLeft: Coordinate { Coordinate(x: x - 1, y: y + 1) }
    var belowRight: Coordinate { Coordinate(x: x + 1, y: y + 1) }
}

struct Path {
    let parts: [Coordinate]

    static func parse(_ line: String) -> Path {
        Path(parts: line.components(separatedBy: " -> ").map { Coordinate.parse($0) })
    }

    func largestX() -> Int {
        parts.map { $0.x }.max()!
    }

    func largestY() -> Int {
        parts.map { $0.y }.max()!
    }
}

enum Cell {
    case rock
    case sand
    case air
}

class Map {
    let hasFloor: Bool

    var grid: [Coordinate: Cell]

    var height: Int
    var width: Int

    subscript(coordinate: Coordinate) -> Cell {
        get {
            if hasFloor, coordinate.y == height - 1 {
                return .rock
            }

            return self.grid[coordinate, default: .air]
        }
        set(cell) {
            self.grid[coordinate] = cell
        }
    }

    func isValid(_ coordinate: Coordinate) -> Bool {
        return (0..<height).contains(coordinate.y)
    }

    init(paths: [Path], hasFloor: Bool) {
        let largestX = paths.map { $0.largestX() }.max()!
        let largestY = paths.map { $0.largestY() }.max()!

        self.width = largestX + 1
        self.height = largestY + 1
        self.grid = [:]
        self.hasFloor = hasFloor

        for path in paths {
            drawPath(path: path, cell: .rock)
        }

        if hasFloor {
            self.height += 2
        }
    }

    func makeRange(_ a: Int, _ b: Int) -> ClosedRange<Int> {
        if a < b {
            return a...b
        }
        if b < a {
            return b...a
        }
        fatalError("Unexpected empty range")
    }

    func drawLine(start: Coordinate, end: Coordinate, cell: Cell) {
        if (start.x == end.x) {
            for y in makeRange(start.y, end.y) {
                self[Coordinate(x: start.x, y: y)] = cell
            }
        } else if (start.y == end.y) {
            for x in makeRange(start.x, end.x) {
                self[Coordinate(x: x, y: start.y)] = cell
            }
        } else {
            fatalError("Unexpected skewed line")
        }
    }

    func drawPath(path: Path, cell: Cell) {
        var start = path.parts[0]
        for part in path.parts.dropFirst() {
            drawLine(start: start, end: part, cell: cell)
            start = part
        }
    }

    enum FallResult {
        case next(Coordinate)
        case still
        case abyss
    }

    func fall(coordinate: Coordinate) -> FallResult {
        let attempts: [Coordinate] = [coordinate.below, coordinate.belowLeft, coordinate.belowRight]

        if attempts.contains(where: { !isValid($0) }) {
            return .abyss
        }

        for attempt in attempts {
            if self[attempt] == .air {
                return .next(attempt)
            }
        }
        return .still
    }

    func simulate() -> Int {
        var rest = 0;
        let initialPosition = Coordinate(x: 500, y: 0)
        simulation: while true {
            var movingSand = initialPosition
            falling: while true {
                switch fall(coordinate: movingSand) {
                    case .still: break falling;
                    case .abyss: break simulation
                    case .next(let next): movingSand = next
                }
            }
            self[movingSand] = .sand
            rest += 1
            if movingSand == initialPosition {
                break;
            }
        }
        return rest
    }
}

let lines = input.components(separatedBy: .newlines)
let paths = lines.map { Path.parse($0) }

let map1 = Map(paths: paths, hasFloor: false)
let answer1 = map1.simulate()
print(answer1)
assert(answer1 == 901)

let map2 = Map(paths: paths, hasFloor: true)
let answer2 = map2.simulate()
print(answer2)
assert(answer2 == 24589)