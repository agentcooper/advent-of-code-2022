import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "10.txt")) else {
    fatalError("File error")
}

enum Instruction {
    case noop
    case addx(value: Int)

    static func parse(description: String) -> Instruction {
        let parts = description.split(separator: " ")
        let command = parts[0]
        switch command {
            case "noop": return .noop
            case "addx": return .addx(value: Int(parts[1])!)
            default: fatalError("Unknown command")
        }
    } 
}

class CPU {
    let instructions: [Instruction]

    var cycle: Int = 0
    var ip: Int = -1
    var cyclesLeft: Int = -1
    var registerX = 1

    var measurement: (() -> Void)? = nil

    init(_ text: String) {
        let lines = text.components(separatedBy: .newlines)       
        self.instructions = lines.map { Instruction.parse(description: $0) }
        let _ = loadNextInstruction()
    }

    func numberOfCycles(_ instruction: Instruction) -> Int {
        switch instruction {
            case .noop: return 1
            case .addx: return 2
        }
    }

    func executeCurrentInstruction() {
        switch instructions[ip] {
            case .addx(value: let value):
                self.registerX += value
            case .noop:
                // do nothing
                break
        }        
    }

    func loadNextInstruction() -> Bool {
        if ip == instructions.endIndex - 1 {
            return false
        }
        ip += 1
        cyclesLeft = numberOfCycles(instructions[ip])
        return true
    }

    func next() -> Bool {
        cycle += 1
        cyclesLeft -= 1

        if let measurement = measurement {
            measurement()
        }

        if cyclesLeft == 0 {
            executeCurrentInstruction()
            return loadNextInstruction()
        }
        return true
    }
}

let cpu1 = CPU(input);
var nextMeasure = 20
var signalStrengths = [Int]()
cpu1.measurement = {
    if cpu1.cycle == nextMeasure {
        let signalStrength = cpu1.cycle * cpu1.registerX
        signalStrengths.append(signalStrength)
        nextMeasure += 40
    }
}
while true {
    if !cpu1.next() {
        break;
    }
}
let answer1 = signalStrengths.reduce(0, +)
print(answer1)

// part 2

class CRT {
    var screen: [[Bool]]

    init() {
        self.screen = Array(repeating: Array(repeating: false, count: 40), count: 6)
    }

    func light(x: Int, y: Int) {
        screen[y][x] = true
    }

    func output() -> String {
        return screen.map { line in
            line.map { $0 ? "#" : "." }.joined(separator: "")
        }.joined(separator: "\n")
    }
}

let cpu2 = CPU(input);
let crt = CRT()
var spritePosition = 0
while true {
    spritePosition = cpu2.registerX
    let x = cpu2.cycle % 40
    let y = cpu2.cycle / 40
    if (spritePosition-1...spritePosition+1).contains(x) {
        crt.light(x: x, y: y)
    }
    if !cpu2.next() {
        break;
    }
}

let output = crt.output()
print(output)
let expectedOutput = """
###..#....###...##..####.###...##..#....
#..#.#....#..#.#..#.#....#..#.#..#.#....
#..#.#....#..#.#..#.###..###..#....#....
###..#....###..####.#....#..#.#....#....
#....#....#....#..#.#....#..#.#..#.#....
#....####.#....#..#.#....###...##..####.
""".trimmingCharacters(in: .whitespacesAndNewlines)
assert(output == expectedOutput)
