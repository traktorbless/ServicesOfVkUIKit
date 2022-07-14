//
//  ViewController.swift
//  ServicesOfVkUIKit
//
//  Created by Антон Таранов on 15.07.2022.
//

import UIKit

class ViewController: UIViewController {
    var services = [Service]()
    
    var tableView = UITableView()
    
    let refreshControl = UIRefreshControl()
    
    let cellIdentifire = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        createTableView()
        createRefereshControl()
        title = "VK сервисы"
    }
}


// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifire, for: indexPath)
        let service = services[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = service.name
        content.secondaryText = service.description
        if let imageURL = service.getUrlOfImage {
            if let imageData = try? Data(contentsOf: imageURL) {
                let image = UIImage(data: imageData)
                content.image = image
            } else {
                content.image = UIImage(systemName: "icloud.slash.fill")
            }
        } else {
            content.image = UIImage(systemName: "icloud.slash.fill")
        }
        cell.contentConfiguration = content
        
        return cell
    }
    
    func createTableView() {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifire)
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        self.view.addSubview(tableView)
    }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = services[indexPath.row]
        if let url = service.getUrlOfLink {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: Load data

extension ViewController {
    func loadData() {
        guard let url = URL(string: "https://publicstorage.hb.bizmrg.com/sirius/result.json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                self.services = decodedResponse.body.services
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Invalid decode")
            }
        }.resume()
    }
}

//MARK: Pull-to-refresh

extension ViewController {
    @objc func refresh(_ sender: AnyObject) {
        loadData()
        refreshControl.endRefreshing()
    }
    
    func createRefereshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Обновляем")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .allEvents)
        tableView.addSubview(refreshControl)
    }
}
