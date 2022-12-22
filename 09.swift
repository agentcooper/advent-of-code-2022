import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "09.txt")) else {
    fatalError("File error")
}

typealias Coordinate = (Int, Int)

enum Direction: String {
    case Up = "U"
    case Down = "D"
    case Left = "L"
    case Right = "R"

    func toCoordinate() -> Coordinate {
        switch self {
            case .Down: return (0, -1)
            case .Up: return (0, 1)
            case .Left: return (-1, 0)
            case .Right: return (1, 0)
        }
    }
}

struct RuleSet {
    struct Rule {
        let direction: Direction
        let distance: Int
    }

    let rules: [Rule]

    init(_ list: String) {
        let lines = list.components(separatedBy: .newlines)
        self.rules = lines.map { line in
            let parts = line.split(separator: " ")
            return Rule(direction: Direction(rawValue: String(parts[0]))!, distance: Int(parts[1])!)
        }
    }
}

class Simulation {
    var rope: [Coordinate]

    init(ropeLength: Int) {
        self.rope = Array(repeating: (0, 0), count: ropeLength)
    }

    var tail: Coordinate {
        rope.last!
    }

    struct Position: Hashable {
        let x: Int
        let y: Int
    }

    var visited = Set<Position>()

    func markAsVisited(_ coordinate: Coordinate) {
        let (x, y) = coordinate
        visited.insert(Position(x: x, y: y))
    }

    func moveHead(direction: Direction) {
        let (xOffset, yOffset) = direction.toCoordinate()
        let (x, y) = rope[0]
        rope[0] = (x + xOffset, y + yOffset)
    }
    
    func moveTail(headIndex: Int, tailIndex: Int) {
        let head = rope[headIndex]
        let tail = rope[tailIndex]

        if (head == tail) {
            return
        }

        let (headX, headY) = head
        let (tailX, tailY) = tail

        let inSameColumn = headX == tailX
        let inSameRow = headY == tailY

        let xOffset = headX - tailX
        let yOffset = headY - tailY

        let isTouching = abs(xOffset) <= 1 && abs(yOffset) <= 1

        if isTouching {
            return
        }

        if inSameRow {
            rope[tailIndex] = (tailX + xOffset.signum(), tailY)
        } else if inSameColumn {
            rope[tailIndex] = (tailX, tailY + yOffset.signum())
        } else {
            rope[tailIndex] = (tailX + xOffset.signum(), tailY + yOffset.signum())
        }
    }

    func run(_ ruleSet: RuleSet) {
        markAsVisited(tail)
        for rule in ruleSet.rules {
            for _ in 0..<rule.distance {
                moveHead(direction: rule.direction)
                for i in 1..<rope.count {
                    moveTail(headIndex: i - 1, tailIndex: i)
                }
                markAsVisited(tail)
            }
        }
    }
}

let ruleSet = RuleSet(input)

let simulation1 = Simulation(ropeLength: 2)
simulation1.run(ruleSet)
let answer1 = simulation1.visited.count
print(answer1)
assert(answer1 == 6209)

let simulation2 = Simulation(ropeLength: 10)
simulation2.run(ruleSet)
let answer2 = simulation2.visited.count
print(answer2)
assert(answer2 == 2460)