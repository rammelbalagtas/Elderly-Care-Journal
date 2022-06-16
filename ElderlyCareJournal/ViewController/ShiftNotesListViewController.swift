//
//  NotesListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-10.
//

import UIKit
import FirebaseStorage

class ShiftNotesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    var shift: Shift!
    var user: User!
    var selectedIndex: Int?
    
    private let storage = Storage.storage().reference()
    
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
    
    private func updateShift(at index: Int?, note: ShiftNote, imagesForUpload: [ShiftNoteImage], imagesForDeletion: [ShiftNoteImage]?) {
        
        var imagePathList = [String]()
        var noteFinal = note
        
        //check if there are images for uploading
        let shouldUpload = imagesForUpload.contains { image in
            if image.path.isEmpty {
                return true
            } else {
                return false
            }
        }
        
        var shouldDelete = false
        if let imagesForDeletion = imagesForDeletion {
            shouldDelete = !imagesForDeletion.isEmpty
        }
        
        if shouldUpload || shouldDelete {
            //upload images before updating shift
            let group = DispatchGroup()
            for image in imagesForUpload {
                if image.path.isEmpty {
                    let imageId = UUID().uuidString
                    let path = "/images/shift/\(shift.id)/\(imageId)"
                    group.enter()
                    ImageStorageService.uploadImage(path: path, image: image.image!, storage: storage)
                    { result in
                        switch result {
                        case .success(_):
                            imagePathList.append(path)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                        group.leave()
                    }
                } else {
                    imagePathList.append(image.path)
                }
            }
            
            if let imagesForDeletion = imagesForDeletion {
                for image in imagesForDeletion {
                    if !image.path.isEmpty {
                        group.enter()
                        ImageStorageService.delete(path: image.path, storage: storage)
                        { result in
                            switch result {
                            case .success(_):
                                print("photo upload successful")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                            group.leave()
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                
                if let index = index {
                    self.shift.notes[index] = note
                    self.shift.notes[index].photos = imagePathList
                } else {
                    noteFinal.photos = imagePathList
                    self.shift.notes.append(noteFinal)
                }
                
                ShiftDbService.update(shift: self.shift) { result in
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
            
        } else {
            
            for image in imagesForUpload {
                imagePathList.append(image.path)
            }
            
            if let index = index {
                self.shift.notes[index] = note
                self.shift.notes[index].photos = imagePathList
            } else {
                noteFinal.photos = imagePathList
                self.shift.notes.append(noteFinal)
            }
            
            ShiftDbService.update(shift: self.shift) { result in
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: .random())
        self.performSegue(withIdentifier: "VIewShiftNote", sender: self)
    }
    
    private func handleSwipeToDelete(_ indexPath: IndexPath) {
        self.shift.notes.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        ShiftDbService.update(shift: self.shift) { result in
            switch result {
            case .success(_):
                return
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // allow delete action in Guardian view and only if shift has not been completed
        if user.userType == UserType.CareProvider.rawValue {
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
    func addNote(note: ShiftNote, images: [ShiftNoteImage]) {
        updateShift(at: nil, note: note, imagesForUpload: images, imagesForDeletion: nil)
    }
    
    func updateNote(at index: Int, note: ShiftNote, imagesForUpload: [ShiftNoteImage], imagesForDeletion: [ShiftNoteImage]) {
        updateShift(at: index, note: note, imagesForUpload: imagesForUpload, imagesForDeletion: imagesForDeletion)
    }

}
