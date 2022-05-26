//
//  ShiftDetailTableViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import UIKit

class ShiftDetailViewController: UITableViewController {
    
    var shift: Shift?
    var uid: String!
    var memberId: String!
    var tasks = [Task]()
    
    @IBOutlet weak var shiftDescriptionText: UITextView!
    @IBOutlet weak var fromDateTime: UIDatePicker!
    @IBOutlet weak var toDateTime: UIDatePicker!
    @IBOutlet weak var numberOfTaskText: UILabel!
    @IBOutlet weak var careProviderText: UILabel!
    
    @IBOutlet weak var addTaskBtn: UIButton!
    @IBOutlet weak var assignCareProviderBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBAction func addTaskAction(_ sender: UIButton) {
    }
    
    @IBAction func assignCareProviderAction(_ sender: UIButton) {
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        let description = shiftDescriptionText.text ?? ""
        let fromDateTime = Utilities.extractDateTimeComponents(using: fromDateTime.date)
        let toDateTime = Utilities.extractDateTimeComponents(using: toDateTime.date)
        
        var shiftId = ""
        if let shift = shift {
            shiftId = shift.id
        } else {
            shiftId = UUID().uuidString
        }
        let shift = Shift(id: shiftId, memberId: memberId, description: description, fromDateTime: fromDateTime, toDateTime: toDateTime, tasks: tasks, status: "New", uid: uid)
        ShiftNetworkService.createShift(shift: shift) { result in
            switch result {
            case .success(_):
                //unwind to task list
                return
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasks.append(Task(description: "task 1", status: "new"))
        tasks.append(Task(description: "task 2", status: "new"))
        tasks.append(Task(description: "task 3", status: "new"))
        
        numberOfTaskText.text = String(tasks.count)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func setDatePicker(using dateString: String) -> UIDatePicker {
        let dateTimeArray = dateString.components(separatedBy: "T")
        var date = DateComponents()
        let dateValue = dateTimeArray[0]
        let timeValue = dateTimeArray[1]
        let dateArray = dateValue.components(separatedBy: "-")
        let timeArray = timeValue.components(separatedBy: ":")
        date.year = Int(dateArray[0])
        date.month = Int(dateArray[1])
        date.day = Int(dateArray[2])
        date.hour = Int(timeArray[0])
        date.minute = Int(timeArray[1])
        date.second = Int(timeArray[2])
        let userCalendar = Calendar.current
        let dateAndTime = userCalendar.date(from: date)
        let datePicker = UIDatePicker()
        datePicker.setDate(dateAndTime!, animated: .random())
        return datePicker
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? TaskListViewController {
            destination.tasks = self.tasks
        }
    }
    

}
