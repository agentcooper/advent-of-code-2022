import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "08.txt")) else {
    fatalError("File error")
}

struct Map {
    struct Coordinate: Hashable, CustomStringConvertible {
        var x: Int
        var y: Int

        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }

        mutating func move(_ other: Coordinate) {
            self.x += other.x
            self.y += other.y
        }

        var description: String { return "(\(x), \(y))" }

        static let right = Coordinate(1, 0)
        static let down = Coordinate(0, 1)
        static let left = Coordinate(-1, 0)
        static let up = Coordinate(0, -1)

        static let clockwise: [Coordinate] = [.right, .down, .left, .up]
    }

    let grid: [[Int]]
    let height: Int
    let width: Int

    init(_ text: String) {
        self.grid = text.components(separatedBy: .newlines).map {
            Array($0).map { c in
                c.wholeNumberValue!
            }
        }
        self.height = grid.count
        self.width = grid[0].count
    }

    subscript(coordinate: Coordinate) -> Int {
        get {
            return grid[coordinate.y][coordinate.x]
        }
    }

    func valid(_ coordinate: Coordinate) -> Bool {
        return (0..<width).contains(coordinate.x) && (0..<height).contains(coordinate.y)
    }

    var clockwiseSides: [[Coordinate]] {
        let top = cast(from: Coordinate(0, 0), offset: Coordinate.right)
        let right = cast(from: top.last!, offset: Coordinate.down)
        let bottom = cast(from: right.last!, offset: Coordinate.left)
        let left = cast(from: bottom.last!, offset: Coordinate.up)
        return [top, right, bottom, left]
    }

    let clockwiseLook: [Map.Coordinate] = [.down, .left, .up, .right]

    func cast(from: Coordinate, offset: Coordinate) -> [Coordinate] {
        var current = from
        var output = [Coordinate]()
        repeat {
            output.append(current)
            current.move(offset)
        } while valid(current)
        return output
    }
}

let map = Map(input)
var visible = Set<Map.Coordinate>()

// walk clockwise and cast a ray towards the other side
for (side, direction) in zip(map.clockwiseSides, map.clockwiseLook) {
    for startCoordinate in side {
        var currentHeight = -1
        for cell in map.cast(from: startCoordinate, offset: direction) {
            let nextHeight = map[cell]
            if nextHeight < currentHeight {
                continue
            }
            if nextHeight > currentHeight {
                currentHeight = nextHeight
                visible.insert(cell)
            }
            if nextHeight == currentHeight {
                continue;
            }
        }
    }
}

let answer1 = visible.count
print(answer1)
assert(answer1 == 1785)

// for each cell, cast a ray to every direction
var maxScenicScore = 1
for x in 0..<map.width {
    for y in 0..<map.height {
        let coordinate = Map.Coordinate(x, y)
        let height = map[coordinate]
        var scenicScore = 1
        for offset in Map.Coordinate.clockwise {
            var distance = 0
            let currentHeight = height
            for cell in map.cast(from: coordinate, offset: offset).dropFirst() {
                let nextHeight = map[cell]
                distance += 1
                if nextHeight >= currentHeight {
                    break
                }
            }
            scenicScore *= distance
        }
        maxScenicScore = max(maxScenicScore, scenicScore)
    }
}
let answer2 = maxScenicScore
print(answer2)
assert(answer2 == 345168)