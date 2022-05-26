//
//  TaskDetailViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-26.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    var task: Task?
    
    @IBOutlet weak var taskDescriptionText: UITextView!
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToTaskList", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let task = task {
            taskDescriptionText.text = task.description
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
