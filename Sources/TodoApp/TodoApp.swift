import Foundation

// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: Codable, CustomStringConvertible {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false

    var description: String {
        return self.title
    }

    init(_ title: String) {
        self.title = title
        self.isCompleted = false
    }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system 
// to persist and retrieve the list of todos. 
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {

    var jsonBaseFileName: String

    var jsonFileURL: URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("\(jsonBaseFileName).json")
    }

    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    func save(todos: [Todo]) {
        do {
            let json = try JSONFileManagerCache.encoder.encode(todos)
            try json.write(to: jsonFileURL)
        } catch {
            print("Error when saving todos.")
        }
    }

    func load() -> [Todo]? {
        do {
            let data = try Data(contentsOf: jsonFileURL)
            let todos = try JSONFileManagerCache.decoder.decode([Todo].self, from: data)
            return todos
        } catch {
            print("Empty or invalid cached file. Load empty todo list.")
        }

        return [Todo]()
    }

    init(name: String) {
        jsonBaseFileName = name
    }
}

// `InMemoryCache`: : Keeps todos in an array or similar structure during the session. 
// This won't retain todos across different app launches, 
// but serves as a quick in-session cache.
final class InMemoryCache: Cache {
    var cachedTodos = [Todo]()

    func save(todos: [Todo]) {
        cachedTodos = todos
    }

    func load() -> [Todo]? {
        return cachedTodos
    }
}

// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)` 
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.
final class TodoManager {
    var todos = [Todo]()
    var cache: Cache

    func listTodos() {
        print("📝 Your Todos:")
        for (index, todo) in todos.enumerated() {
            let emoji = todo.isCompleted ? "✅" : "❌"
            print("  \(index+1). \(emoji) \(todo.title)")
        }
    }

    func saveCache() {
        cache.save(todos: todos)
    }

    func addTodo(_ title: String) {
        todos.append(Todo(title))
        saveCache()
    }

    func toggleCompletion(at index: Int) {
        todos[index].isCompleted = !todos[index].isCompleted
        saveCache()
    }

    func deleteTodo(at index: Int) {
        todos.remove(at: index)
        saveCache()
    }

    func checkOutOfRange(at index: Int) -> Bool {
        return (index >= 0) && (index < todos.count)
    }

    init(cacheFileName: String? = nil) {
        if let name = cacheFileName {
            cache = JSONFileManagerCache(name: name)
        } else {
            cache = InMemoryCache()
        }
        todos = cache.load() ?? [Todo]()
    }

}

final class App {
    enum Command {
        case add
        case list
        case toggle
        case delete
        case exit
        case unknown
    }

    let todoManager = TodoManager(cacheFileName: "todos")

    func inputCommand() -> Command {
        print("What would you like to do? (add, list, toggle, delete, exit): ", terminator: "")
        let commandStr = readLine() ?? ""
        switch commandStr.lowercased() {
        case "add": return .add
        case "list": return .list
        case "toggle": return .toggle
        case "delete": return .delete
        case "exit": return .exit
        default: return .unknown
        }
    }

    func inputIndex() -> Int {
        print("Enter the number of the todo to toggle: ", terminator: "")
        if let input = readLine() {
            if let index = Int(input) {
                if todoManager.checkOutOfRange(at: index-1) {
                    return index-1
                }
                print("❗ Index out of range.")
                return -1
            }
            print("❗ Invalid number.")
        }

        print("❗ Invalid input.")

        return -1
    }

    func run() {
        print("🌟 Welcome to Todo CLI! 🌟")
        while true {
            let command = inputCommand()
            switch command {
            case .exit:
                print("👋 Thanks for using Todo CLI! See you next time!")
                return
            case .add:
                print("Enter todo title: ", terminator: "")
                todoManager.addTodo(readLine() ?? "")
                print("📌 Todo added")
            case .list: todoManager.listTodos()
            case .toggle:
                todoManager.listTodos()
                let index = inputIndex()
                if index != -1 {
                    todoManager.toggleCompletion(at: index)
                    print("Todo completion status toggled!")
                }
            case .delete:
                todoManager.listTodos()
                let index = inputIndex()
                if index != -1 {
                    todoManager.deleteTodo(at: index)
                    print("🗑️ Todo deleted!")
                }
            default:
                print("❗ The chosen action is not supported. Please select again!")
            }
        }
    }
}
