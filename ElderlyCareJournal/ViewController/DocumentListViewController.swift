//
//  DocumentListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-31.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import UniformTypeIdentifiers

protocol DocumentListDelegate: AnyObject {
    func addDocument(document: Document)
    func removeDocument(at index: Int)
}

class DocumentListViewController: UIViewController {
    
    weak var delegate: DocumentListDelegate?
    var familyMember: FamilyMember!
    var user: User!
    
    private var selectedDocument: Document?
    
    @IBOutlet weak var sideMenuBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        //setup side menu
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
        
        setupView()

    }
    
    @IBAction func addDocumentAction(_ sender: UIBarButtonItem) {
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .png, .jpeg, .text, .appleArchive])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .automatic
        present(documentPicker, animated: true)
    }
    
    private func setupView() {
        if user.userType == UserType.CareProvider.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? FileWebDocumentViewController {
            destination.path = selectedDocument?.path
        }
    }
    
}

extension DocumentListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDocument = familyMember.documents[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "OpenDocument", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        //Disable swipe to delete action for care provider
        if user.userType == UserType.CareProvider.rawValue {
            return UITableViewCell.EditingStyle.none
        }
        return UITableViewCell.EditingStyle.delete
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let document = familyMember.documents[indexPath.row]
            DocumentStorageService.delete(path: document.path, storage: storage)
            { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.delegate?.removeDocument(at: indexPath.row)
                        self.familyMember.documents.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        FamilyMemberDbService.update(familyMember: self.familyMember)
                        { result in
                            switch result {
                            case .success(_):
                                return
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension DocumentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return familyMember.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "Document")
        else {fatalError("Unable to dequeue cell")}
        let document = familyMember.documents[indexPath.row]
        cell.textLabel?.text = document.name
        return cell
    }
    
}

extension DocumentListViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        dismiss(animated: true)
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        
        let documentId = UUID().uuidString
        DocumentStorageService.upload(path: "/documents/\(familyMember.memberId)/\(documentId)/\(url.lastPathComponent)", localFile: url, storage: storage)
        { result in
            switch result {
            case .success(let metadata):
                guard
                    let name = metadata.name,
                    let path = metadata.path,
                    let contentType = metadata.contentType,
                    let timeCreated = metadata.timeCreated
                else { return }
                
                let document = Document(id: documentId, name: name, path: path, contentType: contentType, size: metadata.size, createdOn: timeCreated)
                
                self.familyMember.documents.append(document)
                FamilyMemberDbService.update(familyMember: self.familyMember)
                { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.delegate?.addDocument(document: document)
                        self?.tableView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        do {
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

    }


}
