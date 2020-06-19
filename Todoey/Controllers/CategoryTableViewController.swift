//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by TomHe on 17/06/2020.
//  Copyright © 2020 TomHe. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var CategoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()

    }
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        //Identifier here has to correspond to the name we
        //gave for the cell in Main.storyboard
        
        let Category = CategoryArray[indexPath.row]
        
        cell.textLabel?.text = Category.name
        
        return cell
    }
    
    //MARK: - TablewView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        //optional binding if anything was selected
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = CategoryArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context(Category): \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do {
            CategoryArray = try context.fetch(request)
        } catch {
            print("Error in fetching Category data from Core Data: \(error)")
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newItem = Category(context: self.context)
            newItem.name = textField.text!
            
            self.CategoryArray.append(newItem)
            self.saveItems()
        }
        
        //Allow user to enter text on alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}
