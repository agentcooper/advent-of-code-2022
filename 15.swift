import Foundation

extension String {
    func extractInts() -> [Int] {
        var s = CharacterSet()
        s.insert(charactersIn: "-")
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted.subtracting(s)).compactMap { Int($0) }
    }
}

guard let input = try? String(contentsOf: URL(fileURLWithPath: "15.txt")) else {
    fatalError("File error")
}

struct Point: Hashable {
    let x: Int
    let y: Int

    func distance(to: Point) -> Int {
        return abs(x - to.x) + abs(y - to.y)
    }

    func isInCircle(center: Point, radius: Int) -> Bool {
        return distance(to: center) <= radius
    }
}

struct Sensor {
    let origin: Point
    let beacon: Point

    static func parse(_ line: String) -> Sensor {
        let values = line.extractInts()
        return Sensor(origin: Point(x: values[0], y: values[1]), beacon: Point(x: values[2], y: values[3]))
    }

    func xRange() -> (Int, Int) {
        let d = origin.distance(to: beacon)
        return (origin.x - d, origin.x + d)
    }

    func yRange() -> (Int, Int) {
        let d = origin.distance(to: beacon)
        return (origin.y - d, origin.y + d)
    }
}

class Map {
    enum Cell: String {
        case beacon = "B"
        case sensor = "S"
        case empty = "."
    }

    let sensors: [Sensor]

    var cells: [Point: Cell]
    let x: (Int, Int)
    let y: (Int, Int)

    subscript(point: Point) -> Cell {
        get {
            return self.cells[point, default: .empty]
        }
        set(cell) {
            self.cells[point] = cell
        }
    }

    init(_ sensors: [Sensor]) {
        self.cells = [:]
        self.sensors = sensors

        let xs: [Int] = sensors.flatMap { [$0.xRange().0, $0.xRange().1] }
        let ys: [Int] = sensors.flatMap { [$0.origin.y, $0.beacon.y] }
        self.x = (xs.min()!, xs.max()!)
        self.y = (ys.min()!, ys.max()!)

        for sensor in sensors {
            self[sensor.origin] = .sensor
            self[sensor.beacon] = .beacon
        }
    }

    func intersections(y: Int) -> [ClosedRange<Int>] {
        let intervals: [ClosedRange<Int>] = sensors.compactMap {
            let (yLow, yHigh) = $0.yRange()
            if !(yLow...yHigh).contains(y) {
                return nil
            }
            let ySpan = $0.origin.distance(to: $0.beacon) - abs($0.origin.y - y)
            return $0.origin.x-ySpan...$0.origin.x+ySpan
        }
        return combinedIntervals(intervals: intervals)
    }

    var beacons: Set<Point> {
        Set(sensors.map(\.beacon))
    }

    func beacons(y: Int) -> Int {
        sensors.filter { $0.beacon.y == y }.count
    }
}

let lines = input.components(separatedBy: .newlines)
let sensors = lines.map { Sensor.parse($0) }

func inside(value: Int, ranges: [ClosedRange<Int>]) -> Bool {
    for range in ranges {
        if range.contains(value) {
            return true
        }
    }
    return false
}

do {
    let Y = 2000000
    let map = Map(sensors)
    let mm = map.intersections(y: Y)
    let answer1 = mm.reduce(0, { acc, range in
        let numberOfBeacons = map.beacons.filter { $0.y == Y && range.contains($0.x) }.count
        return acc + range.count - numberOfBeacons
    })
    print(answer1)
    assert(answer1 == 5181556)
}

do {
    let INTERVAL = 0...4000000
    let map = Map(sensors)

    var foundPoint: Point? = nil
    loop: for y in INTERVAL {
        let m = map.intersections(y: y)
        if m.count > 1 { // just a heuristic
            for x in INTERVAL {
                let p = Point(x: x, y: y)
                if map[p] == .empty && !inside(value: x, ranges: m) {
                    foundPoint = p
                    break loop
                }
            }
        }
    }

    guard let foundPoint = foundPoint else {
        fatalError("Unexpected: point not found")
    }
    let answer2 = foundPoint.x * 4000000 + foundPoint.y
    print(answer2)
}

// https://gist.github.com/proxpero/0cee32a53b94c37e1e92?permalink_comment_id=2037983#gistcomment-2037983
func combinedIntervals(intervals: [CountableClosedRange<Int>]) -> [CountableClosedRange<Int>] {
    
    var combined = [CountableClosedRange<Int>]()
    var accumulator = (0...0) // empty range
    
    for interval in intervals.sorted(by: { $0.lowerBound  < $1.lowerBound  } ) {
        
        if accumulator == (0...0) {
            accumulator = interval
        }
        
        if accumulator.upperBound >= interval.upperBound {
            // interval is already inside accumulator
        }
            
        else if accumulator.upperBound >= interval.lowerBound  {
            // interval hangs off the back end of accumulator
            accumulator = (accumulator.lowerBound...interval.upperBound)
        }
            
        else if accumulator.upperBound <= interval.lowerBound  {
            // interval does not overlap
            combined.append(accumulator)
            accumulator = interval
        }
    }
    
    if accumulator != (0...0) {
        combined.append(accumulator)
    }
    
    return combined
}