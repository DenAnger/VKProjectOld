//
//  LoginFormController.swift
//  VK Project
//
//  Created by Denis Abramov on 19.07.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class LoginFormController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet var webView: WKWebView!
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        print("4")
        super.viewDidLoad()
        let url = MethodFL().auth(client_id: ClientData.app.client_id, scope: ClientData.scope.friendsPhotoGroups)
        activityIndicatorView = UIActivityIndicatorView(frame: view.bounds)
        activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicatorView.color = .gray
        activityIndicatorView?.startAnimating()
        webView.addSubview(activityIndicatorView)
        webView.load(URLRequest(url: url))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView?.stopAnimating()
        let range = webView.url?.absoluteString.lowercased().range(of: "access_token")
        print(range ?? "")
        DispatchQueue.global(qos: .userInteractive).sync {
            if !(range?.isEmpty ?? true), let urlString = webView.url?.absoluteString {
                let data = urlString.components(separatedBy: CharacterSet(charactersIn: "&="))
                ClientData.client.access_token = data[1]
                print(data[1])
                ClientData.client.user_id = data[5]
                performSegue(withIdentifier: "show_tabbar", sender: self)
            }
        }
    }
}

var loadData: Bool? {
    get {
        return UserDefaults.standard.bool(forKey: "start") as Bool?
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "start")
    }
}

var loadGroupsData: Bool? {
    get {
        return UserDefaults.standard.bool(forKey: "start1") as Bool?
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "start1")
    }
}
