import UIKit

class ViewController: UIViewController {
    var services = [Service]()
    
    var icons = [UIImage?]()
    
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
        content.image = icons[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    private func createTableView() {
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
    private func loadData() {
        guard let url = URL(string: "https://publicstorage.hb.bizmrg.com/sirius/result.json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                self.services = decodedResponse.body.services
                self.icons = self.loadIcon(for: self.services)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Invalid decode")
            }
        }.resume()
    }
    
    private func loadIcon(for services: [Service]) -> [UIImage?] {
        var images = [UIImage?]()
        
        for service in services {
            if let imageURL = service.getUrlOfImage {
                if let imageData = try? Data(contentsOf: imageURL) {
                    let image = UIImage(data: imageData)
                    images.append(image)
                } else {
                    images.append(UIImage(systemName: "icloud.slash.fill"))
                }
            } else {
                images.append(UIImage(systemName: "icloud.slash.fill"))
            }
        }
        
        return images
    }
}

//MARK: Pull-to-refresh

extension ViewController {
    @objc private func refresh(_ sender: AnyObject) {
        loadData()
        refreshControl.endRefreshing()
    }
    
    private func createRefereshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Обновляем")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .allEvents)
        tableView.addSubview(refreshControl)
    }
}
