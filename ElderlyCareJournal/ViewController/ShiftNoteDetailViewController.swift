//
//  ShiftNotesTableViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-10.
//

import UIKit
import FirebaseStorage

protocol ShiftNoteDetailDelegate: AnyObject {
    func addNote(note: ShiftNote, images: [ShiftNoteImage])
    func updateNote(at index: Int, note: ShiftNote, images: [ShiftNoteImage])
}

class ShiftNoteDetailViewController: UITableViewController {

    @IBOutlet weak var noteDescriptionText: UITextView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    
    var user: User!
    var note: ShiftNote?
    var selectedIndex: Int?
    private var images = [ShiftNoteImage]()
    private var shouldSavePhoto: Bool = false
    weak var delegate: ShiftNoteDetailDelegate?
    
    private let storage = Storage.storage().reference()
    
    @IBAction func addPhotoAction(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    @IBAction func saveNoteAction(_ sender: UIBarButtonItem) {
        guard
            let noteDescription = noteDescriptionText.text, noteDescriptionText.hasText
        else {return}
        
        if var note = note, let index = selectedIndex {
            note.description = noteDescription
            delegate?.updateNote(at: index, note: note, images: images)
        } else {
            let note = ShiftNote(description: noteDescription, photos: [])
            delegate?.addNote(note: note, images: images)
        }
        self.performSegue(withIdentifier: "unwindToShiftNoteList", sender: self)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    private func loadData() {
        if let note = note {
            noteDescriptionText.text = note.description
            
            if !note.photos.isEmpty {
                for photo in note.photos {
                    images.append(ShiftNoteImage(path: photo, image: nil))
                }
            }
        }
    }
    
    private func setupView() {
        
        registerNib()
        
        noteDescriptionText.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    func registerNib() {
        //Register nib for collection view
        let nib = UINib(nibName: Constants.NibName.photoCollectionCell, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: Constants.ReuseIdentifier.photoCollectionCell)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 150 , height: 200)
        flowLayout.estimatedItemSize = CGSize(width: 150 , height: 200)
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.sectionInset.left = 8.0
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.showsHorizontalScrollIndicator = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShiftNoteDetailViewController: UITextViewDelegate {
    
    // Resize textview depending on it's content
    func textViewDidChange(_ textView: UITextView) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
        let newHeight = cell.frame.size.height + textView.contentSize.height
        cell.frame.size.height = newHeight
        updateTableViewContentOffsetForTextView()
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

extension ShiftNoteDetailViewController: UICollectionViewDelegate {

}

extension ShiftNoteDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    //data per collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ReuseIdentifier.photoCollectionCell, for: indexPath) as? PhotoCollectionCell
        else{preconditionFailure("unable to dequeue reusable cell")}
        let image = images[indexPath.row]
        if let imageData = image.image {
            cell.configureImage(path: nil, image: imageData, storage: storage)
        } else {
            cell.configureImage(path: image.path, image: nil, storage: storage)
        }
        return cell
    }
}

extension ShiftNoteDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.images.append(ShiftNoteImage(path: "", image: image))
        collectionView.reloadItems(at: [IndexPath(item: images.count - 1, section: 0)])
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
