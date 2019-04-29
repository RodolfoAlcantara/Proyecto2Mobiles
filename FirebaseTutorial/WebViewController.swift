//
//  ViewController.swift
//  webview
//
//  Created by Rodolfo Alcantara on 4/8/19.
//  Copyright © 2019 rodolfo. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webviewUI: UIWebView!
    @IBAction func goHome(_ sender: Any) {
        loadPage(urlString: "https://www.google.com")
    }
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButton(_ sender: Any) {
        webviewUI.goBack()
        self.checkButtons()
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func nextButton(_ sender: Any) {
        webviewUI.goForward()
        self.checkButtons()
    }
    
    @IBAction func searchPage(_ sender: Any) {
        searchAlertWithTextField()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        webviewUI.delegate = self
        loadPage(urlString: "https://mobiletestescompruebas.000webhostapp.com/login/index.html")
        checkButtons()
    }
    func checkButtons() {
        backButton.isEnabled = false
        nextButton.isEnabled = false
        if webviewUI.canGoBack {
            backButton.isEnabled = true
        } else {
            backButton.isEnabled = false
        }
        if webviewUI.canGoForward {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    func loadPage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webviewUI.loadRequest(request)
        self.checkButtons()
    }
    func searchAlertWithTextField() {
        let alertController = UIAlertController(title: "Buscador", message: "Ingresa tu búsqueda", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enlace válido"
        }
        let saveAction = UIAlertAction(title: "Buscar", style: .default, handler: { alert -> Void in
            guard let firstTextField = alertController.textFields?[0] else { return }
            guard let textUrl = firstTextField.text else { return }
            
            // LOGICA DE CARGAR EL ENLACE
            // Recuerda que el enlace debe de empezar con "https://"
            self.loadPage(urlString: self.adaptURL(urlString: textUrl))
        })
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    public func adaptURL(urlString: String) -> String {
        if urlString.contains("https://") {
            if urlString.contains("www.") {
                return urlString
            } else {
                let textReplaced = urlString.replacingOccurrences(of: "https://", with: "")
                return "https://wwww.\(textReplaced)"
            }
        } else if urlString.contains("www.") {
            return "https://\(urlString)"
        } else {
            let textReplaced = urlString.replacingOccurrences(of: " ", with: "%20")
            return "https://www.google.com/search?q=\(textReplaced)"
        }
    }
    
}

extension WebViewController {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.checkButtons()
    }
}
