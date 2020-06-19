//
//  ViewController.swift
//  Todoey
//
//  Created by TomHe on 06/06/2020.
//  Copyright © 2020 TomHe. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    //for saving into shared document folder for the application using user defaults
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(dataFilePath) where we will find the plist storage for our app
        
        //Just want path to where our data is stored for this app
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }

    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title //set the current text lable in the indexPath item of array
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell //return new populated cell to be displayed
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
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
            
            let newItem = Item(context: self.context)
            newItem.parentCategory = self.selectedCategory
            newItem.title = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            
            self.saveItems()
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
    func saveItems() {
        
        do {
           try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData() //to add to tableview
    }
    
    
// with is the external parameter used when calling
//request is the internal paramter with default value Item.fetchRequest()
//if parameter of type NSFetchRequest<Item> is not passed
/* With the Encodable stuff
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
              itemArray = try decoder.decode([Item].self, from: data)
                //swift bad at inferring datatype so have to tell array of item: [Item].self
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
*/
    //predicate parameter is optional
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //Below is loading from Core Data:
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error in fetching data from Core Data: \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //cd - so it is not (c) case sensitive and (d) diacratic sensitive
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //.sortDescriptors requires array of sort descriptors so we put
        //right hand side in []
        //It will fetch item and sort acc. to title in asc' order
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
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
