//
//  WebVC.swift
//  ConnexionScreen
//
//  Created by Raphaël Payet on 02/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController {

    //MARK: - Objects
    var webView : WKWebView!
    var acIndicator : UIActivityIndicatorView!
    
    
    //MARK: - Properties
    var website : String!
    
    //MARK: - Lifecyle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadWebView()
        setupToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Override Methods
    
    fileprivate func setupWebView() {
        webView     = WKWebView()
        acIndicator = UIActivityIndicatorView()
        
        view = webView
        
        webView.addSubview(acIndicator)
        
        acIndicator.translatesAutoresizingMaskIntoConstraints   = false
        
        NSLayoutConstraint.activate([
            acIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            acIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            acIndicator.heightAnchor.constraint(equalToConstant: 37),
            acIndicator.widthAnchor.constraint(equalToConstant: 37)
        ])
        
        
        acIndicator.startAnimating()
        acIndicator.style = .large
        acIndicator.color = .systemGray3
        
        webView.navigationDelegate      = self
        acIndicator.hidesWhenStopped    = true
    }
    fileprivate func setupToolBar() {
        
        
        let rewind  = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(rewind(_:)))
        let forward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(forward(_:)))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
        let stop    = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stop(_:)))
        let spacer  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [rewind, forward,spacer,refresh, stop]
        navigationController?.isToolbarHidden = false
    }
    
    //MARK: - Helper Methods
    private func loadWebView() {
        guard let url = URL(string: website) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    //MARK: - Actions
    
    @objc func rewind(_ sender : Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    @objc func forward(_ sender : UIBarButtonItem) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func refresh(_ sender : UIBarButtonItem) {
        webView.reload()
    }
    
    @objc func stop(_ sender : Any) {
        webView.stopLoading()
    }
    
}

//MARK: - Extension
extension WebVC : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        acIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        acIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        acIndicator.startAnimating()
    }
    
}
