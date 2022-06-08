//
//  TaskListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-26.
//

import UIKit

class TaskListViewController: UIViewController, UITableViewDelegate {
    
    var tasks = TaskList()
    var user: User!
    var shiftStatus: String!

    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
        registerNib()
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
            destination.user = user
            if let indexPaths = tableView.indexPathsForSelectedRows {
                destination.task = tasks.list[indexPaths[0].row]
                destination.selectedIndex = indexPaths[0].row
            }
        }
    }
    
    private func setupView() {
        if user.userType == UserType.CareProvider.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func registerNib() {
        // Register TableView Cell
        self.tableView.register(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.identifier)
    }

}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell
        else{preconditionFailure("unable to dequeue reusable cell")}
        let task = tasks.list[indexPath.row]
        cell.configureCell(using: task)
        return cell
    }
    
    private func handleSwipeToDelete(_ indexPath: IndexPath) {
        self.tasks.list.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func handleSwipeToMarkAsComplete(_ indexPath: IndexPath) {
        self.tasks.list[indexPath.row].status = TaskStatus.Completed.rawValue
        self.tasks.list[indexPath.row].completedOn = Date.now
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func handleSwipeToMarkAsIncomplete(_ indexPath: IndexPath) {
        self.tasks.list[indexPath.row].status = TaskStatus.New.rawValue
        self.tasks.list[indexPath.row].completedOn = nil
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if shiftStatus != ShiftStatus.InProgress.rawValue || user.userType != UserType.CareProvider.rawValue {
            return nil
        }
        
        let task = tasks.list[indexPath.row]
        if task.status == TaskStatus.New.rawValue {
            let markAsComplete = UIContextualAction(style: .destructive, title: "Mark As Completed") { action, view, completionHandler in
                self.handleSwipeToMarkAsComplete(indexPath)
                completionHandler(true)
            }
            markAsComplete.backgroundColor = UIColor.systemGreen
            return UISwipeActionsConfiguration(actions: [markAsComplete])
        } else {
            let markAsIncomplete = UIContextualAction(style: .destructive, title: "Mark As Not Completed") { action, view, completionHandler in
                self.handleSwipeToMarkAsIncomplete(indexPath)
                completionHandler(true)
            }
            markAsIncomplete.backgroundColor = UIColor.systemOrange
            return UISwipeActionsConfiguration(actions: [markAsIncomplete])
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // allow delete action in Guardian view and only if shift has not been completed
        if user.userType == UserType.Guardian.rawValue && shiftStatus != ShiftStatus.Completed.rawValue {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
                self.handleSwipeToDelete(indexPath)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [delete])
        } else {
            return nil
        }

    }
    
}

extension TaskListViewController: TaskDetailDelegate {
    func addTask(description: String) {
        self.tasks.list.append(Task(description: description, status: "New"))
        self.tableView.reloadData()
    }
    
    func updateTask(at index: Int, with description: String) {
        self.tasks.list[index].description = description
        self.tableView.reloadData()
    }
}
