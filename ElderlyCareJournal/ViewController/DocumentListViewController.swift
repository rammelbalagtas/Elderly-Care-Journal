//
//  DocumentListViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-31.
//

import UIKit
import MobileCoreServices
import FirebaseStorage

class DocumentListViewController: UIViewController {
    
    var familyMember: FamilyMember!
    
    @IBOutlet weak var sideMenuBtn: UIBarButtonItem!
    
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup side menu
        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)
    }
    
    @IBAction func addDocumentAction(_ sender: UIBarButtonItem) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .png])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .automatic
        present(documentPicker, animated: true)
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

extension DocumentListViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        dismiss(animated: true)
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        
        DocumentStorageService.upload(path: "/documents/\(url.lastPathComponent)", localFile: url, storage: storage)
        { result in
            switch result {
            case .success(let metadata):
               
                guard
                    let name = metadata.name,
                    let path = metadata.path,
                    let contentType = metadata.contentType,
                    let timeCreated = metadata.timeCreated
                else { return }
                
                let document = Document(name: name, path: path, contentType: contentType, size: metadata.size, createdOn: timeCreated)
                
                self.familyMember.documents.append(document)
                
                FamilyMemberDbService.update(familyMember: self.familyMember)
                { result in
                    switch result {
                    case .success(_):
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    //reload table view data
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
