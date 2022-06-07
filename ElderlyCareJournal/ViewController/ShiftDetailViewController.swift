//
//  ShiftDetailTableViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import UIKit

class ShiftDetailViewController: UITableViewController {
    
    var shift: Shift?
    var user: User!
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
    
    @IBOutlet weak var startShiftBtn: UIButton!
    @IBOutlet weak var endShiftBtn: UIButton!
    @IBOutlet weak var addNotesBtn: UIButton!
    
    @IBAction func startShiftAction(_ sender: UIButton) {
        if var shift = shift {
            shift.startedOn = Utilities.extractDateTimeComponents(using: Date.now)
            shift.status = ShiftStatus.InProgress.rawValue
            ShiftDbService.create(shift: shift)
            { result in
                switch result {
                case .success(_):
                    self.shift = shift
                    self.promptMessage(message: "Shift status set to Active")
                    {_ in self.performSegue(withIdentifier: "unwindToShiftList", sender: self)}
                case .failure(let error):
                    print(error.localizedDescription)
                    self.promptMessage(message: error.localizedDescription, handler: nil)
                }
            }
        }
    }
    
    @IBAction func endShiftAction(_ sender: UIButton) {
        if var shift = shift {
            shift.completedOn = Utilities.extractDateTimeComponents(using: Date.now)
            shift.status = ShiftStatus.Completed.rawValue
            ShiftDbService.create(shift: shift)
            { result in
                switch result {
                case .success(_):
                    self.shift = shift
                    self.promptMessage(message: "Shift status set to Completed")
                    {_ in self.performSegue(withIdentifier: "unwindToShiftList", sender: self)}
                case .failure(let error):
                    print(error.localizedDescription)
                    self.promptMessage(message: error.localizedDescription, handler: nil)
                }
            }
        }
    }
    
    @IBAction func addNotesAction(_ sender: UIButton) {
    }
    
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
        let createdOn = Utilities.extractDateTimeComponents(using: Date.now)
        
        var shiftId = ""
        if let shift = shift {
            shiftId = shift.id
        } else {
            shiftId = UUID().uuidString
        }
        let shift = Shift(id: shiftId, memberId: memberId, description: description, fromDateTime: fromDateTime, toDateTime: toDateTime, tasks: tasks, careProviderId: careProviderId, careProviderName: careProviderName, status: ShiftStatus.New.rawValue, uid: user.uid, createdOn: createdOn, startedOn: nil, completedOn: nil)
        ShiftDbService.create(shift: shift)
        { result in
            switch result {
            case .success(_):
                var message = ""
                if self.isExisting! {
                    message = "Shift record is updated"
                } else {
                    message = "Shift record is created"
                }
                self.promptMessage(message: message)
                {_ in self.performSegue(withIdentifier: "unwindToShiftList", sender: self)}
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
        
        shiftDescriptionText.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        self.clearsSelectionOnViewWillAppear = true
        
        setupView()
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
        if section == 3 && user.userType == UserType.CareProvider.rawValue {
            return 30
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
            //hide Assign Care provider option in care provider screen
            if indexPath.row == 1 && user.userType == UserType.CareProvider.rawValue {
                return 0
            }
        case 2:
            //hide Save/Delete buttons in care provider screen and in completed shifts
            if user.userType == UserType.CareProvider.rawValue || shift?.status == ShiftStatus.Completed.rawValue {
                return 0
            } else {
                //hide Delete button for new shift
                if indexPath.row == 1 {
                    if let _ = shift {
                    } else {
                        return 0
                    }
                }
            }
        case 3:
            if user.userType == UserType.Guardian.rawValue {
                return 0
            }
        default:
            return tableView.rowHeight
        }
        return tableView.rowHeight
    }
    
    private func setupView() {
        //disable input fields in care provider view
        if user.userType == UserType.CareProvider.rawValue {
            shiftDescriptionText.isEditable = false
            fromDateTime.isUserInteractionEnabled = false
            toDateTime.isUserInteractionEnabled = false
        }
        
        //disable Start shift for in progress and completed shift
        //disable End Shift and Add Notes of new and completed shift
        if let shift = shift {
            
            if shift.status == ShiftStatus.New.rawValue {
                endShiftBtn.isEnabled = false
                addNotesBtn.isEnabled = false
            } else if shift.status == ShiftStatus.InProgress.rawValue {
                startShiftBtn.isEnabled = false
            } else if shift.status == ShiftStatus.Completed.rawValue {
                startShiftBtn.isEnabled = false
                endShiftBtn.isEnabled = false
            }
        }
        
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
            destination.user = self.user
            destination.delegate = self
        } else if let destination = segue.destination as? ShiftListViewController {
            if segue.identifier == "unwindToShiftList" {
                if let shift = shift {
                    if shift.status == ShiftStatus.New.rawValue {
                        destination.selectedSegment = 0
                    } else if shift.status == ShiftStatus.InProgress.rawValue {
                        destination.selectedSegment = 1
                    } else {
                        destination.selectedSegment = 2
                    }
                }
            }
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

extension ShiftDetailViewController: UITextViewDelegate {
    // Resize textview depending on it's content
    func textViewDidChange(_ textView: UITextView) {
        if textView == shiftDescriptionText {
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))!
            let newHeight = cell.frame.size.height + textView.contentSize.height
            cell.frame.size.height = newHeight
            updateTableViewContentOffsetForTextView()
        }
    }
        
    // Animate cell, the cell frame will follow textView content
    func updateTableViewContentOffsetForTextView() {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
}
