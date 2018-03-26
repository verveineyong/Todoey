//
//  ViewController.swift
//  Todoey
//
//  Created by BB on 19/3/18.
//  Copyright © 2018 Yong. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var toDoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
            
        }
    }
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
    }
    
    //it will load after viewDidLoad
    override func viewDidAppear(_ animated: Bool) {
        
        title = selectedCategory!.name
        
        guard let colourHex = selectedCategory?.colour else { fatalError() }
        
        updateNavBar(withHexCode: colourHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // guard let originalColour = UIColor(hexString : "9ACBFF") else {fatalError()}
        
        updateNavBar(withHexCode: "007AFF")
        
        //        navigationController?.navigationBar.barTintColor = originalColour
        //        navigationController?.navigationBar.tintColor = FlatWhite()
        //        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(FlatWhite(), returnFlat: true)]
        
    }
    
    //Mark: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHexCode : String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString : colorHexCode) else { (fatalError()) }
        
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes  = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
    }
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            
            //current on row #5
            // there is a total of 10 items in the todoItems
            if let colour = UIColor(hexString : selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            
            //Ternary operator ==>
            //value = condition ? valueIftrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No item added"
            
        }
        return cell
    }
    
    //MARK - Tableview Delegate Method
    // this is the place when we select the item (checked/unchecked)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    //                    realm.delete(item)
                    item.done = !item.done  //(false -> true ; true -> false>
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        //        toDoItems?[indexPath.row].done = !(toDoItems)[indexPath.row].done)
        //        saveItems()
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items.
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //what will happen once the user click the Add Item button on our UIAlert
            
            if let currentCategory  = self.selectedCategory {
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    //Mark - Model Manupulation Methods
    //    func saveItems() {
    //
    //        do {
    //            try context.save()
    //        }catch {
    //            print("Error saving context \(error)")
    //        }
    //
    //        self.tableView.reloadData()
    //    }
    //
    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        
        tableView.reloadData()
    }
    
    //MARK : - Delete data from swift
    override func updateModel(at indexPath: IndexPath) {
        //update model - called by superclass
        if let item = toDoItems?[indexPath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleteing category, \(error)")
            }
        }
    }
    
}

//MARK: - Search Bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
}


