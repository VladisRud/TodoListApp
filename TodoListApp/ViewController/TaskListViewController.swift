//
//  ViewController.swift
//  TodoListApp
//
//  Created by Alexey Efimov on 24.09.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private var taskList: [TodoTask] = []
    private let cellID = "task"
    private let storageManager = StorageManager.delegate

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(updateText: taskList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storageManager.delete(task: taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor.milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
}

//MARK: - Data Method
extension TaskListViewController {
    func fetchData() {
        storageManager.fetchData { [unowned self] result in
            switch result {
            case .success(let taskList):
                self.taskList = taskList
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - AlertMethods
private extension TaskListViewController {
    func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            let newTask = storageManager.create(taskWithName: task)
            taskList.append(newTask)
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    func showAlert(updateText task: TodoTask) {
        let alert = UIAlertController(title: "Update Task Name", message: "How To Rename Task", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "Update Task", style: .default) { [unowned self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            storageManager.update(task: task, withNewName: text)
            tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = task.title
        }
        present(alert, animated: true)
    }
}
