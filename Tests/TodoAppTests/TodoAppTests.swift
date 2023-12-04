import XCTest
@testable import TodoApp

final class AppTests: XCTestCase {
    func testTodoStringRepresentation() {
        let todo = Todo("title")
        XCTAssertEqual(todo.description, "title",
            "string representation should match")
    }

    func testTodoManagerAddTodoIncreasesCountByOne() {
        let todoManager = TodoManager()
        let count = todoManager.todos.count
        let newTodoTitle = "new todo title 123456789"
        todoManager.addTodo(newTodoTitle)
        XCTAssertEqual(
            todoManager.todos.count, count + 1,
            "add todo must increase the count of todo list by 1",
        )
    }

    func testTodoManagerAddTodoContainsNewTodo() {
        let todoManager = TodoManager()
        let newTodoTitle = "new todo title 123456789"
        todoManager.addTodo(newTodoTitle)
        var found = false

        for todo in todoManager.todos where todo.title == newTodoTitle {
            found = true
            break
        }

        XCTAssertEqual(found, true,
            "New todo must be present in the todo list after adding")
    }

    func testTodoManagerDeleteTodoDecreasesCountByOne() {
        let todoManager = TodoManager()
        let newTodoTitle = "new todo title \(UUID())"
        todoManager.addTodo(newTodoTitle)

        let oldCount = todoManager.todos.count
        todoManager.deleteTodo(at: 0)

        XCTAssertEqual(todoManager.todos.count, oldCount - 1,
            "count must decreae by 1 after deleting")

    }

    func testTodoManagerDeleteTodoNotContainOldTodo() {
        let todoManager = TodoManager()
        let newTodoTitle = "new todo title 123456789"
        todoManager.addTodo(newTodoTitle)

        let deletedTodo = todoManager.todos[0]
        todoManager.deleteTodo(at: 0)

        var found = false

        for todo in todoManager.todos where todo.id == deletedTodo.id {
            found = true
            break
        }

        XCTAssertEqual(found, false, "deleted todo must not be present after deleting")
    }

    func testTodoManagerToggleTodoNotChangeCount() {
        let todoManager = TodoManager()
        let newTodoTitle = "new todo title 123456789"
        todoManager.addTodo(newTodoTitle)

        let oldCount = todoManager.todos.count

        XCTAssertEqual(todoManager.todos.count, oldCount,
            "count must remain unchanged after toggling")

    }

    func testTodoManagerToggleChangesStatus() {
        let todoManager = TodoManager()
        let newTodoTitle = "new todo title 123456789"
        todoManager.addTodo(newTodoTitle)

        let oldCompletionStatus = todoManager.todos[0].isCompleted

        todoManager.toggleCompletion(at: 0)

        XCTAssertEqual(todoManager.todos[0].isCompleted, !oldCompletionStatus,
            "Toggle must change the completion status of the todo")
    }

    func testInMemoryCache() {
        let cache = InMemoryCache()

        let todo1 = Todo("one")
        let todo2 = Todo("two")

        cache.save(todos: [todo1, todo2])

        let todos = cache.load()

        XCTAssertEqual(todos?.count ?? 0, 2,
            "Loading should return the correct number of todos saved")
    }

    func testFileSystemCache() {
        let cache = JSONFileManagerCache(name: "test\(UUID())")

        let todo1 = Todo("one")
        let todo2 = Todo("two")

        cache.save(todos: [todo1, todo2])

        let todos = cache.load()

        XCTAssertEqual(todos?.count ?? 0, 2,
            "Loading should return the correct number of todos saved")
    }

}
