//
//  TaskListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-26.
//

import UIKit

class TaskListViewController: UIViewController, UITableViewDelegate {
    
    var tasks = [Task]()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
            if let indexPaths = tableView.indexPathsForSelectedRows {
                destination.task = tasks[indexPaths[0].row]
            }
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
    
    
}
