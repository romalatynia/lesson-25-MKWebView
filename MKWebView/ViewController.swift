//
//  ViewController.swift
//  MKWebView
//
//  Created by Roma Latynia on 3/27/21.
//

import UIKit
import WebKit

protocol WebTableViewControllerDelegate: AnyObject {
    
    func send(requestType: TypeRequest, pathsStrings: [String], indexPath: IndexPath)
    
}

private enum Constants {
    static let identifier = "Cell"
    static let title = "WebView"
}

class ViewController: UIViewController {
    
    private weak var delegate: WebTableViewControllerDelegate?
    private var webViewController = WebViewController()
    private var tableView: UITableView?
    private var sections = [Group]()
    private let sectionWeb: Group = {
        let section = Group(section: "Web")
        section.adress = [
            "https://swiftbook.ru",
            "https://vk.com/iosdevcourse",
            "https://www.google.ru/?client=safari&channel=mac_bm"
        ]
        return section
    }()
    
    private let sectionPDF: Group = {
        let section = Group(section: "PDF")
        section.adress = [
            "молодёжный сборник (новый)",
            "Молодёжный сборник (старый)"
        ]
        return section
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        sections = [sectionWeb, sectionPDF]
        delegate = webViewController
        createTableview()
    }
    
    private func createTableview() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: Constants.identifier)
        tableView?.delegate = self
        tableView?.dataSource = self
        view.addSubview(tableView ?? UITableView())
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let adressInSectionCount = sections[section].adress?.count else { return .zero }
        return adressInSectionCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifier)
        guard let cells = cell else { return UITableViewCell(style: .default, reuseIdentifier: Constants.identifier) }
        let section = sections[indexPath.section]
        let adress = section.adress?[indexPath.row]
        cells.textLabel?.text = adress
        return cells
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName = sections[section].section
        
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let address = sections[indexPath.section].adress ?? [String]()
            delegate?.send(requestType: .web, pathsStrings: address, indexPath: indexPath)
            navigationController?.show(webViewController, sender: nil)
        case 1:
            let address = sections[indexPath.section].adress ?? [String]()
            delegate?.send(requestType: .file, pathsStrings: address, indexPath: indexPath)
            navigationController?.show(webViewController, sender: nil)
        default:
            break
        }
    }
}
