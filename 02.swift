import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "02.txt")) else {
    fatalError("File error")
}

struct Game {
    enum Tool: CaseIterable {
        case Rock
        case Paper
        case Scissors
    }

    enum Outcome {
        case Win
        case Lose
        case Draw
    }

    static func play(you: Tool, opponent: Tool) -> Outcome {
        switch (you, opponent) {
            case (.Rock, .Paper): return .Lose
            case (.Rock, .Scissors): return .Win
            case (.Rock, .Rock): return .Draw

            case (.Paper, .Paper): return .Draw
            case (.Paper, .Scissors): return .Lose
            case (.Paper, .Rock): return .Win

            case (.Scissors, .Paper): return .Win
            case (.Scissors, .Scissors): return .Draw
            case (.Scissors, .Rock): return .Lose
        }
    }

    static func findToolForOutcome(opponent: Tool, outcome: Outcome) -> Tool {
        for tool in Tool.allCases {
            if play(you: tool, opponent: opponent) == outcome {
                return tool
            }
        }
        fatalError("Unexpected error")
    }
}

struct Guide {
    static func fromOpponent(letter: String) -> Game.Tool {
        switch letter {
            case "A": return .Rock
            case "B": return .Paper
            case "C": return .Scissors
            default: fatalError("Unknown letter")
        }
    }

    static func forResponse(letter: String) -> Game.Tool {
        switch letter {
            case "X": return .Rock
            case "Y": return .Paper
            case "Z": return .Scissors
            default: fatalError("Unknown letter")
        }
    }

    static func outcome(letter: String) -> Game.Outcome {
        switch letter {
            case "X": return .Lose
            case "Y": return .Draw
            case "Z": return .Win
            default: fatalError("Unknown letter")
        }
    }

    static func parse(input: String) -> [(String, String)] {
        return input.components(separatedBy: .newlines).compactMap { line in
            if line.isEmpty {
                return nil
            }
            let columns = line.components(separatedBy: " ")
            return (columns[0], columns[1])
        }
    }
}

let guide = Guide.parse(input: input)

enum Part {
    case One
    case Two
}

func getAnswer(part: Part) -> Int {
    let rounds: [Int] = guide.map { (first, second) in
        let opponentTool = Guide.fromOpponent(letter: first)

        let playerTool: Game.Tool
        switch part {
            case .One:
                playerTool = Guide.forResponse(letter: second)
            case .Two:
                let desiredOutcome = Guide.outcome(letter: second)
                playerTool = Game.findToolForOutcome(opponent: opponentTool, outcome: desiredOutcome)
        }

        let outcome = Game.play(you: playerTool, opponent: opponentTool)
        
        var score = 0
        switch playerTool {
            case .Rock: score += 1
            case .Paper: score += 2
            case .Scissors: score += 3
        }
        switch outcome {
            case .Win: score += 6
            case .Draw: score += 3
            case .Lose: ()
        }

        return score
    }

    return rounds.reduce(0, +)
}

let answer1 = getAnswer(part: .One)
print(answer1)
assert(answer1 == 17189)

let answer2 = getAnswer(part: .Two)
print(answer2)
assert(answer2 == 13490)
