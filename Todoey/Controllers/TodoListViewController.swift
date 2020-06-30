//
//  ViewController.swift
//  Todoey
//
//  Created by TomHe on 06/06/2020.
//  Copyright © 2020 TomHe. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
        
        guard let colourHex = selectedCategory?.colorCategory else {fatalError()}
        
        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }

    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String){
        
        //making sure navBar is not nil
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation container does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colourHexCode) else {fatalError()}
        
            //setting nav bar color
            navBar.barTintColor = navBarColor
            
            //setting nav bar button and other elements color
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            
            //setting color of title of nav bar
            navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
            
            //Setting searchbar color
            searchBar.barTintColor = navBarColor
        
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title //set the current text lable in the indexPath item of array
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = UIColor(hexString: item.colorItem)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items Added Yet."
        }
        return cell //return new populated cell to be displayed
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status of item: \(error)")
            }
        }
        tableView.reloadData()
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//
//        saveItems()
        
        // tableView.reloadData() exists inside saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    //MARK: - Add New Item
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen after user click add button on UIAlert
            //print("Success!")
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date() //it gets stamped by the current date and time
                        newItem.colorItem = currentCategory.colorCategory
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving Item : \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        //alertTextField only available in this small closure so use the textField to store
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    func loadItems() {
        //Below is loading from Core Data:
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Items in Category
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDelete = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDelete)
                }
            } catch {
                print("Error in deleting item: \(error)")
            }
        }
    }
}

//MARK: - Search Bar Methods
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    //this function is to allow it to return to original state
    //after the search bar is cleared
    //This happens when text changes and the search bar is blank
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems() //fetch original list of itemArray due to default value
            
            //to grab main thread so that searchBar can resign
            //even if background threads are still happening
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                //return search bar to its original state without
                //blinking cursor
            }
        }
    }
}
