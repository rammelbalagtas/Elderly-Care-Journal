//
//  NotesListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-10.
//

import UIKit

class ShiftNotesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    var shift: Shift!
    var user: User!
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupView()

    }
    
    @IBAction func unwindToShiftNoteList( _ seg: UIStoryboardSegue) {
    }
    
    private func setupView() {
        //Only Care Provider can add notes
        if user.userType == UserType.Guardian.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func updateShift() {
        ShiftDbService.update(shift: shift) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: .random())
        self.performSegue(withIdentifier: "VIewShiftNote", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? ShiftNoteDetailViewController {
            destination.delegate = self
            destination.user = user
            if let selectedIndex = selectedIndex {
                destination.note = shift.notes[selectedIndex]
                destination.selectedIndex = selectedIndex
            }
        }
    }

}

extension ShiftNotesListViewController: UITableViewDelegate {
    
}

extension ShiftNotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shift.notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShiftNote")
        else{preconditionFailure("unable to dequeue reusable cell")}
        var content = cell.defaultContentConfiguration()
        let note = shift.notes[indexPath.row]
        content.text = note.description
        cell.contentConfiguration = content
        return cell
    }
}

extension ShiftNotesListViewController: ShiftNoteDetailDelegate {
    func addNote(note: ShiftNote) {
        self.shift.notes.append(note)
        updateShift()
    }
    
    func updateNote(at index: Int, note: ShiftNote) {
        self.shift.notes[index] = note
        updateShift()
    }

}
