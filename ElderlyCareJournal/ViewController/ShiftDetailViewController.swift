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
    private var careProviderId = ""
    private var careProviderName = ""
    private var isExisting: Bool?
    
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
        self.performSegue(withIdentifier: "ViewTasks", sender: self)
    }
    
    @IBAction func assignCareProviderAction(_ sender: UIButton) {
        assignCareProvider()
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
        let shift = Shift(id: shiftId, memberId: memberId, description: description, fromDateTime: fromDateTime, toDateTime: toDateTime, tasks: tasks, careProviderId: careProviderId, careProviderName: careProviderName, status: ShiftStatus.New.rawValue, uid: uid)
        ShiftDbService.create(shift: shift)
        { result in
            switch result {
            case .success(_):
                self.promptMessage(message: "Shift record is created") { _ in
                    self.performSegue(withIdentifier: "unwindToShiftList", sender: self)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.promptMessage(message: error.localizedDescription, handler: nil)
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if let shift = shift {
            ShiftDbService.delete(shiftId: shift.id)
            { result in
                switch result {
                case .success(_):
                    self.promptMessage(message: "Shift record is deleted") { _ in
                        self.performSegue(withIdentifier: "unwindToShiftList", sender: self)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.promptMessage(message: error.localizedDescription, handler: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let shift = shift {
            isExisting = true
            displayDetail(shift)
        } else {
            isExisting = false
        }
        
        self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberOfTaskText.text = String(tasks.count)
        if careProviderName.isEmpty {
            careProviderText.text = "Care Provider"
        } else {
            careProviderText.text = careProviderName
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    private func displayDetail(_ shift: Shift) {
        shiftDescriptionText.text = shift.description
        if let fromDate = buildDateTime(using: shift.fromDateTime) {
            fromDateTime.setDate(fromDate, animated: .random())
        }
        if let toDate = buildDateTime(using: shift.toDateTime) {
            toDateTime.setDate(toDate, animated: .random())
        }
        tasks = shift.tasks
        numberOfTaskText.text = String(tasks.count)
        careProviderId = shift.careProviderId
        careProviderName = shift.careProviderName
    }
    
    private func buildDateTime(using dateString: String) -> Date? {
        let dateTimeArray = dateString.components(separatedBy: "T")
        var dateComponents = DateComponents()
        let dateValue = dateTimeArray[0]
        let timeValue = dateTimeArray[1]
        let dateArray = dateValue.components(separatedBy: "-")
        let timeArray = timeValue.components(separatedBy: ":")
        dateComponents.year = Int(dateArray[0])
        dateComponents.month = Int(dateArray[1])
        dateComponents.day = Int(dateArray[2])
        dateComponents.hour = Int(timeArray[0])
        dateComponents.minute = Int(timeArray[1])
        dateComponents.second = Int(timeArray[2])
        let userCalendar = Calendar.current
        if let dateTime = userCalendar.date(from: dateComponents) {
            return dateTime
        } else {
            return nil
        }
    }
    
    private func assignCareProvider() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let careProviderListController = storyboard.instantiateViewController(identifier: "CareProviderList") as CareProviderListController
        careProviderListController.delegate = self
        show(careProviderListController, sender: self)
    }
    
    private func promptMessage(message: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "", message: message , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? TaskListViewController {
            destination.tasks = self.tasks
            destination.delegate = self
        }
    }
}

extension ShiftDetailViewController: TaskListDelegate {
    func updateTaskList(tasks: [Task]) {
        self.tasks = tasks
        tableView.reloadData()
    }
}

extension ShiftDetailViewController: CareProviderListDelegate {
    func assignCareProvider(careProvider: User) {
        careProviderId = careProvider.uid
        careProviderName = "\(careProvider.firstName) \(careProvider.lastName)"
    }
}
