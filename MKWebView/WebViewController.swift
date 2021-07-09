//
//  WebViewViewController.swift
//  MKWebView
//
//  Created by Roma Latynia on 3/27/21.
//

import UIKit
import WebKit

private enum Constants {
    static let helpSizeToolBar: CGFloat = 40
    static let space: CGFloat = 20
    static let pdf = "pdf"
    static let pathToTheFile = "pdf file/"
    static let helpValueCenterIndicator: CGFloat = 2
}

class WebViewController: UIViewController, WKUIDelegate {

    private lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private lazy var forwardButton = UIBarButtonItem(
        barButtonSystemItem: .fastForward,
        target: self,
        action: #selector(goForward(sender:))
    )
    private lazy var backButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(goBack(sender:)))
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let bounds = UIScreen.main.bounds
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(
            x: bounds.width / Constants.helpValueCenterIndicator,
            y: bounds.height / Constants.helpValueCenterIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemBlue
        return activityIndicator
    }()

    override func loadView() {
        super.loadView()
        
        webView.navigationDelegate = self
        view = webView
        toolbarSetup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
    }
    
    private func webViewbCanGoOrNot() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    private func toolbarSetup() {
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = Constants.space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        webViewbCanGoOrNot()
        let bounds = UIScreen.main.bounds
        let toolbar = UIToolbar(
            frame: CGRect(
                x: bounds.minX,
                y: bounds.maxY - Constants.helpSizeToolBar,
                width: bounds.width, height: Constants.helpSizeToolBar
            )
        )
        toolbar.backgroundColor = .blue
        toolbar.items = [backButton, fixedSpace, forwardButton, flexibleSpace]
        view.addSubview(toolbar)
    }

    @objc private func goBack(sender: UIBarButtonItem) {
            webView.goBack()
    }
    
    @objc private func goForward(sender: UIBarButtonItem) {
            webView.goForward()
    }
}

extension WebViewController: WebTableViewControllerDelegate {
    func send(requestType: TypeRequest, pathsStrings: [String], indexPath: IndexPath) {
        guard !pathsStrings.isEmpty else { return }
        
        switch requestType {
        case .web:
            let webString = pathsStrings[indexPath.row]
            guard let webURL = URL(string: webString) else { return }
            let urlRequest = URLRequest(url: webURL)
            webView.load(urlRequest)
        case .file:
            let nameFolder = Constants.pathToTheFile
            let filePathString = nameFolder + pathsStrings[indexPath.row]
            guard let fullFilePath = Bundle.main.path(forResource: filePathString, ofType: Constants.pdf) else { return }
            let fileURL = URL(fileURLWithPath: fullFilePath)
            let urlRequest = URLRequest(url: fileURL)
            webView.load(urlRequest)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewbCanGoOrNot()
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webViewbCanGoOrNot()
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewbCanGoOrNot()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.stopLoading()
        print(error.localizedDescription)
    }
}
