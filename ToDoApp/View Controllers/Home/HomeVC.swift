//
//  ViewController.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 30.08.25.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore

class HomeVC: UIViewController {
    
    let coreDataManager = DataRepository.shared
    lazy var datas = [ToDoAppItem]()
    
    //MARK: - Views
    var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let _ = Auth.auth().currentUser?.uid {
            DataRepository.shared.syncFromFirebase(uid: Auth.auth().currentUser!.uid) { [weak self] in
                guard let self = self else { return }
                self.datas = self.coreDataManager.fetchAllToDoItems(for: Auth.auth().currentUser!.uid)
                self.reload()
            }
        }
    }
    
    //MARK: - Network Check
    func observeNetwork() {
        NetworkMonitor.shared.didChangeStatus = { [weak self] isConnected in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if isConnected {
                    self.reload()
                } else {
                    self.showTemporarilyAlert(title: "Network error", message: "You are not connected to the internet. Showing local data.", isError: true)
                }
            }
        }
    }
    
    //MARK: - Setup User Interface
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "To Do App"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        view.addSubview(tableView)
        
        tableView.pinToSafeArea(of: view)
        
        tableView.dataSource = self
        tableView.delegate = self

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        navigationItem.rightBarButtonItems = [addButton, refreshButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        observeNetwork()
    }
    //MARK: - Refresh Button Action
    @objc
    func refreshButtonTapped(){
        
        guard NetworkMonitor.shared.isConnected else {
            self.showTemporarilyAlert(title: "Network error", message: "You are not connected to the internet. Showing local data.", isError: true)
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        coreDataManager.syncFromFirebase(uid: uid) { [weak self] in
            guard let self = self else { return }
            
            self.datas = self.coreDataManager.fetchAllToDoItems(for: uid)
            
            self.reload()
        }
    }
    
    //MARK: - Add Button Action
    @objc
    func addButtonTapped() {
        
        let alert = UIAlertController(title: "Add Task", message: "Please add a task", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.clearButtonMode = .whileEditing
        }
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                let alert = UIAlertController(title: "Cannot add empty task", message: "Please add a task", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                alert.addAction(ok)
                
                self.present(alert, animated: true)
                
                return
            }

            let newItem = self.coreDataManager.createToDoItem(name: text)
            
            
            self.datas.append(newItem)
            self.reload()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        reload()
    }

    //MARK: - Settings Button Action
    @objc
    func settingsButtonTapped() {
        let vc = SettingsVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Reload TableView Data
    func reload(){
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            if self.datas.isEmpty {
                let noTaskLabel = UILabel()
                noTaskLabel.text = "No Task"
                noTaskLabel.textAlignment = .center
                noTaskLabel.textColor = .systemGray
                noTaskLabel.font = .boldSystemFont(ofSize: 30)
                self.tableView.backgroundView = noTaskLabel
            } else {
                self.tableView.backgroundView = nil
            }
            
        }
        
    }
    
}

//MARK: - UITableView Functions
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = datas[indexPath.row]
        var config = UIListContentConfiguration.cell()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let name = data.name, let date = data.createdAt {
            config.text = "\(name)\n\(date.formatted())"
        } else {
            config.text = "No Name - No Date"
        }
        
        config.textProperties.color = data.isDone ? .systemGreen : .systemOrange
        
        if data.isDone {
            config.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            config.image = UIImage(systemName: "circle")
        }
        
        cell.contentConfiguration = config

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.row]
        if UserDefaults.standard.bool(forKey: "showAlertOnToggle") {
            let alert = UIAlertController(title: "Alert", message: data.isDone ? "Are you sure you want to mark this as undone?" : "Are you sure you want to mark this as done?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
                self?.coreDataManager.toggleIsDone(data)
                self?.reload()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else {
            self.coreDataManager.toggleIsDone(data)
            self.reload()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in

            guard let self = self else { return }
            
            let alert = TDAlertController(title: "Delete item", message: "Are you sure you want to delete this item?")

            alert.createButton(title: "Delete", style: .dangerous) {
                let item = self.datas[indexPath.row]
                self.coreDataManager.deleteToDoItem(item) {
                    self.showTemporarilyAlert(title: "Item deleted", message: "Item deleted successfully")
                }
                self.datas.remove(at: indexPath.row)
                self.reload()
                completion(true)
            }
            
            alert.createButton(title: "Cancel") {
                completion(true)
            }
            
            view.addSubview(alert)
            alert.pinToEdges(of: view)
            


        }

        let updateAction = UIContextualAction(style: .normal, title: "Update") { [weak self] _, _, completion in
            self?.presentUpdateAlert(for: indexPath)
            completion(true)
        }
        updateAction.backgroundColor = .systemBlue

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func presentUpdateAlert(for indexPath: IndexPath) {
        let item = datas[indexPath.row]
        let alert = UIAlertController(title: "Update Task", message: "Edit your task", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = item.name
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  !text.isEmpty else { return }
            self.coreDataManager.updateToDoItem(item, name: text)
            self.datas[indexPath.row].name = text
            self.reload()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

#Preview {
    UINavigationController(rootViewController: HomeVC())
}
