//
//  DocumentViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-02.
//

import UIKit
import WebKit
import FirebaseStorage

class FileWebDocumentViewController: UIViewController, WKUIDelegate {

    var path: String!
    private let storage = Storage.storage().reference()

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        
        DocumentStorageService.getDownloadURL(path: path, storage: storage)
        { result in
            switch result {
            case .success(let url):
                let request = URLRequest(url: url)
                self.webView.load(request)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }

}
