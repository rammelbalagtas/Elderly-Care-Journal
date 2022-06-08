//
//  TaskTableViewCell.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-08.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }

    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var completionDateStackView: UIStackView!
    @IBOutlet weak var completionDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(using task: Task) {
        descriptionText.text = task.description
        if let completedOn = task.completedOn {
            // Create Date Formatter
            let dateFormatter = DateFormatter()
            // Set Date Format
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            // Convert Date to String
            completionDateLabel.text = dateFormatter.string(from: completedOn)
            completionDateStackView.isHidden = false
        } else {
            completionDateStackView.isHidden = true
            completionDateLabel.text = ""
        }
    }
    
}
