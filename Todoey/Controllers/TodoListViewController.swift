//
//  ViewController.swift
//  Todoey
//
//  Created by Hongjun Kan on 4/30/18.
//  Copyright © 2018 Jenny Wang. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
        
    }
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    //let defaults = UserDefaults.standard
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
        

//        searchBar.delegate = self
        
//        let newItem = Item()
//        newItem.title = "Find Mike"
//        //newItem.done = true
//        itemArray.append(newItem)
//        
//        let newItem2 = Item()
//        newItem2.title = "Buy Eggos"
//        itemArray.append(newItem2)
//        
//        let newItem3 = Item()
//        newItem3.title = "Destroy Demogorgon"
//        itemArray.append(newItem3)
        
        //loadItems()
        // Do any additional setup after loading the view, typically from a nib.
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray =  items
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name

 
        guard let colourHex = selectedCategory?.colour else {fatalError()}
        
        updateNavBar(withHexCode: colourHex)
            

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation congtroller does not exist.")}

       guard let navBarColour = UIColor(hexString: colourHexCode) else {fatalError()}
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour


    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:CGFloat(indexPath.row) / (CGFloat(todoItems!.count))
            ) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            // Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none

        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        
//        else
//        {
//            cell.textLabel?.text = "No Items Added"
//        }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//
//        saveItems()
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                item.done = !item.done
                }
            } catch {
                print ("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {action in
            // what will happen once the user clicks the Add Item button on our alert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print ("Error saving new items, \(error)")
                }

            }
            
            self.tableView.reloadData()
            
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            

        }
        
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //Mark: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        //      Update our data model
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
                //            let data = try encoder.encode(itemArray)
                //            try data.write(to: dataFilePath!)
            } catch {
                print("Error deleting item, \(error)")
            }
            
            //tableView.reloadData()
        }
    }
}

//MARK - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
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

