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
        
        // Create a reference to the file you want to download
        let reference = storage.child(path)
        
        // Fetch the download URL
        reference.downloadURL
        { url, error in
          if let error = error {
              print(error.localizedDescription)
          } else {
              if let url = url {
                  let request = URLRequest(url: url)
                  self.webView.load(request)
              }
          }
        }
        
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
