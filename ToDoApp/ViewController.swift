//
//  ViewController.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 30.08.25.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    
    let coreDataManager = CoreDataManager.shared
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
    }
    
    //MARK: - Setup User Interface
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "To Do App"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        datas = coreDataManager.fetchAllToDoItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    //MARK: - Add Button Action
    @objc
    func addButtonTapped() {
        
        let alert = UIAlertController(title: "Add Task", message: "Please Add A Task", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.clearButtonMode = .whileEditing
        }
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                let alert = UIAlertController(title: "Cannot Add Empty Task", message: "Please Add A Task", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                alert.addAction(ok)
                
                self?.present(alert, animated: true)
                
                return
            }
            
            let newItem = self?.coreDataManager.createToDoItem(name: text)
            
            if let newItem = newItem {
                self?.datas.append(newItem)
                self?.reload()
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        reload()
    }
    
    // MARK: - Long Press on TableView Cell
    @objc
    func longPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let indexPath = tableView.indexPathForRow(at: gesture.location(in: tableView)) else { return }
            let itemToChange = datas[indexPath.row]
            let alert = UIAlertController(title: "Delete or Update Task", message: "This action cannot be undone", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.coreDataManager.deleteToDoItem(itemToChange)
                self?.datas.remove(at: indexPath.row)
                self?.reload()
            }))
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                guard let self = self else { return }
                let alertController = UIAlertController(title: "Update Task", message: nil, preferredStyle: .alert)
                alertController.addTextField { tf in
                    tf.text = itemToChange.name
                    tf.clearButtonMode = .whileEditing
                }
                
                let updateAction = UIAlertAction(title: "Update", style: .default, handler: { [weak self] _ in
                    
                    guard let tf = alertController.textFields?.first else { return }
                    
                    guard let text = tf.text, !text.isEmpty else {
                        let alert = UIAlertController(title: "Cannot Update", message: "Please Enter A Task Name", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(ok)
                        
                        self?.present(alert, animated: true)
                        
                        return }
                    
                    if tf.text == itemToChange.name { return }
                    self?.coreDataManager.updateToDoItem(itemToChange, name: text)
                    self?.datas[indexPath.row].name = text
                    self?.reload()
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                
                alertController.addAction(updateAction)
                alertController.addAction(cancelAction)
                present(alertController, animated: true)
            }
            
            alert.addAction(updateAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            
            present(alert, animated: true)
        }
    }
    
    //MARK: - Reload TableView Data
    func reload(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

//MARK: - UITableView Functions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        if data.isDone {
            config.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            config.image = UIImage(systemName: "circle")
        }
        
        
        cell.contentConfiguration = config
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressed)))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.row]
        let alert = UIAlertController(title: "Alert", message: data.isDone ? "Are you sure you want to mark this as undone?" : "Are you sure you want to mark this as done?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.coreDataManager.toggleIsDone(data)
            self?.reload()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}
