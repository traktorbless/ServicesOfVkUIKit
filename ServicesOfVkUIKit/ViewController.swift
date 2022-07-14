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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView

        title = "VK сервисы"
        
        view.addSubview(tableView)
    }


}


// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
    
    
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
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

