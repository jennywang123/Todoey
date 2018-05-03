//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hongjun Kan on 5/2/18.
//  Copyright © 2018 Jenny Wang. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategory()
        
        tableView.separatorStyle = .none
        
    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        //let encoder = PropertyListEncoder()
        
        do {
            try realm.write {
                realm.add(category)
            }
            //            let data = try encoder.encode(itemArray)
            //            try data.write(to: dataFilePath!)
        } catch {
            print("Error saving category, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategory() {
        
        categories = realm.objects(Category.self)
        //        if let data = try? Data(contentsOf: dataFilePath!) {
        //            let decoder = PropertyListDecoder()
        //            do {
        //            itemArray = try decoder.decode([Item].self, from: data)
        //            } catch {
        //                print("Error decoding item array, \(error)")
        //            }
        //        }
        
//        let request : NSFetchRequest<Category> = Category.fetchRequest()
//        do {
//            categoryArray = try context.fetch(request)
//        }catch {
//            print ("Error loading categories \(error)")
//        }
//        
         tableView.reloadData()
    }
    
    //Mark: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        //      Update our data model
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
                //            let data = try encoder.encode(itemArray)
                //            try data.write(to: dataFilePath!)
            } catch {
                print("Error deleting category, \(error)")
            }

            //tableView.reloadData()
        }
    }
    
    //MARK: - Add New Categories
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) {action in
            // what will happen once the user clicks the Add Item button on our alert
            
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
            
            
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            
        }
        
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    

    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC =  segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
}


