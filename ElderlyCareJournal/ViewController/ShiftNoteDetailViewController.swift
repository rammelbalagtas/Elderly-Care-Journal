//
//  ShiftNotesTableViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-10.
//

import UIKit

class ShiftNoteDetailViewController: UITableViewController {

    @IBOutlet weak var noteDescriptionText: UITextView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    
    @IBAction func addPhotoAction(_ sender: UIButton) {
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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
        return 0
    }
    
    //data per collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ReuseIdentifier.photoCollectionCell, for: indexPath) as? PhotoCollectionCell
        else{preconditionFailure("unable to dequeue reusable cell")}
        return cell
    }
}
