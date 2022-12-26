import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "14.txt")) else {
    fatalError("File error")
}

struct Coordinate {
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

    func toString() -> String {
        switch self {
            case .air: return "."
            case .rock: return "#"
            case .sand: return "o"
        }
    }
}

class Map {
    var grid: [[Cell]]

    var height: Int { grid.count }
    var width: Int { grid[0].count }

    subscript(coordinate: Coordinate) -> Cell {
        get {
            return self.grid[coordinate.y][coordinate.x]
        }
        set(cell) {
            self.grid[coordinate.y][coordinate.x] = cell
        }
    }

    func isValid(_ coordinate: Coordinate) -> Bool {
        return (0..<width).contains(coordinate.x) && (0..<height).contains(coordinate.y)
    }

    init(_ width: Int, _ height: Int) {
        self.grid = Array(repeating: Array(repeating: .air, count: width), count: height)
    }

    func makeRange(_ a: Int, _ b: Int) -> ClosedRange<Int> {
        if a < b {
            return a...b
        }
        if b < a {
            return b...a
        }
        fatalError("Unexpeced empty range")
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

    func toString() -> String {
        self.grid.map { $0.map { $0.toString() }.joined(separator: "") }.joined(separator: "\n")
    }
}

let lines = input.components(separatedBy: .newlines)

let paths = lines.map { Path.parse($0) }

let largestX = paths.map { $0.largestX() }.max()!
let largestY = paths.map { $0.largestY() }.max()!

let width = largestX + 1
let height = largestY + 1

let map = Map(width, height)

for path in paths {
    map.drawPath(path: path, cell: .rock)
}

var rest = 0;
simulation: while true {
    var movingSand = Coordinate(x: 500, y: 0)
    falling: while true {
        switch map.fall(coordinate: movingSand) {
            case .still: break falling;
            case .abyss: break simulation
            case .next(let next): movingSand = next
        }
    }
    map[movingSand] = .sand
    rest += 1
}
let answer1 = rest
print(answer1)
assert(answer1 == 901)