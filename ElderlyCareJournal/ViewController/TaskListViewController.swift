//
//  TaskListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-26.
//

import UIKit

protocol TaskListDelegate: AnyObject {
    func updateTaskList(tasks: [Task])
}

class TaskListViewController: UIViewController, UITableViewDelegate {
    
    var tasks = [Task]()
    var user: User!
    weak var delegate: TaskListDelegate?

    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
    }
    
    @IBAction func unwindToTaskList( _ seg: UIStoryboardSegue) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ViewTask", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? TaskDetailViewController {
            destination.delegate = self
            if let indexPaths = tableView.indexPathsForSelectedRows {
                destination.task = tasks[indexPaths[0].row]
                destination.selectedIndex = indexPaths[0].row
                destination.user = user
            }
        }
    }
    
    private func setupView() {
        if user.userType == UserType.CareProvider.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "Task")
        else{preconditionFailure("unable to dequeue reusable cell")}
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tasks.remove(at: indexPath.row)
            self.delegate?.updateTaskList(tasks: tasks)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

extension TaskListViewController: TaskDetailDelegate {
    func addTask(description: String) {
        self.tasks.append(Task(description: description, status: "New"))
        self.delegate?.updateTaskList(tasks: tasks)
        self.tableView.reloadData()
    }
    
    func updateTask(at index: Int, with description: String) {
        self.tasks[index].description = description
        self.delegate?.updateTaskList(tasks: tasks)
        self.tableView.reloadData()
    }
}
