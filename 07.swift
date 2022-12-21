import Foundation

guard let input = try? String(contentsOf: URL(fileURLWithPath: "07.txt")) else {
    fatalError("File error")
}

struct File {
    let name: String
    let size: Int
}

class Directory: CustomStringConvertible {
    var name: String
    var subDirectories: [Directory] = []
    var files: [File] = []

    init(name: String) {
        self.name = name;
    }

    func directorySize() -> Int {
        let fileSize = files.reduce(0, { acc, file in acc + file.size })
        return fileSize + subDirectories.reduce(0, { $0 + $1.directorySize() })
    }

    var description: String {
        return "(name: \(name), subDirectories: \(subDirectories), files: \(files))"
    }

    func enumerate(_ f: (Directory) -> Void) {
        f(self);
        for subDirectory in subDirectories {
            subDirectory.enumerate(f);
        }
    }
}

let root = Directory(name: "/")
var stack = [root];
input.enumerateLines { (line, stop) in
    if line.starts(with: "$") {
        
        let command = line[line.index(line.startIndex, offsetBy: 2)...line.index(line.startIndex, offsetBy: 3)]

        if command == "cd" {
            let argument = line[line.index(line.startIndex, offsetBy: 5)...]
            if argument == "/" {
                stack = [root];
            } else if argument == ".." {
                stack.removeLast();
            } else {
                guard let found = stack.last!.subDirectories.first(where: { $0.name == argument }) else {
                    fatalError("Error")
                }
                stack.append(found)
            }
        }
        
    } else {
        if line.starts(with: "dir") {
            let name = line[line.index(line.startIndex, offsetBy: 4)...]
            let directory = Directory(name: String(name))
            stack[stack.endIndex - 1].subDirectories.append(directory);
        } else {
            let parts = line.components(separatedBy: " ")
            let file = File(name: parts[1], size: Int(parts[0])!)
            stack[stack.endIndex - 1].files.append(file);
        }
    }
}

var sum = 0;
root.enumerate { f in
    if f.name == "/" {
        return
    }
    let size = f.directorySize();
    if size <= 100000 {
        sum += size
    }
}

// part 1
let answer1 = sum;
print(answer1)
assert(answer1 == 2104783)

// part 2
let TOTAL_SPACE = 70000000
let REQUIRED_SPACE = 30000000
let freeSpace = TOTAL_SPACE - root.directorySize()
let neededSpace = REQUIRED_SPACE - freeSpace

var sizes = [Int]()
root.enumerate { f in
    if f.name == "/" {
        return
    }
    let size = f.directorySize();
    if size >= neededSpace {
        sizes.append(size)
    }
}
let answer2 = sizes.min()!
print(answer2)
assert(answer2 == 5883165)