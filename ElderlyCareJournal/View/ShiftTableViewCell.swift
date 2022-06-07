//
//  ShiftTableViewCell.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-07.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var careProviderName: UILabel!
    @IBOutlet weak var taskCompletion: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(using shift: Shift) {
        descriptionLabel.text = shift.description
        careProviderName.text = shift.careProviderName
        var completedCount = 0
        for task in shift.tasks {
            if task.status == TaskStatus.Completed.rawValue {
                completedCount += 1
            }
        }
        taskCompletion.text = "\(String(completedCount))/\(String(shift.tasks.count))"
        
        if let startDate = buildDateTime(using: shift.fromDateTime) {
            // Create Date Formatter
            let dateFormatter = DateFormatter()
            // Set Date Format
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            // Convert Date to String
            startDateLabel.text = dateFormatter.string(from: startDate)
        } else {
            startDateLabel.text = ""
        }
        
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
    
}
