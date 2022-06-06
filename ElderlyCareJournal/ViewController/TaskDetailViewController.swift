//
//  TaskDetailViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-26.
//

import UIKit

protocol TaskDetailDelegate: AnyObject {
    func addTask(description: String)
    func updateTask(at index: Int, with description: String)
}

class TaskDetailViewController: UIViewController {
    
    var task: Task?
    var user: User!
    var selectedIndex: Int?
    weak var delegate: TaskDetailDelegate?
    
    @IBOutlet weak var taskDescriptionText: UITextView!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        guard
            let taskDescription = taskDescriptionText.text, taskDescriptionText.hasText
        else {return}
        
        if let _ = task, let index = selectedIndex {
            delegate?.updateTask(at: index, with: taskDescription)
        } else {
            delegate?.addTask(description: taskDescription)
        }
        self.performSegue(withIdentifier: "unwindToTaskList", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        if user.userType == UserType.CareProvider.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        if let task = task {
            taskDescriptionText.text = task.description
        }
        
        //add border to textview
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        taskDescriptionText.layer.borderWidth = 0.5
        taskDescriptionText.layer.borderColor = borderColor.cgColor
        taskDescriptionText.layer.cornerRadius = 5.0
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }

}



