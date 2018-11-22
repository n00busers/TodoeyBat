//
//  ViewController.swift
//  Todoey
//
//  Created by Batmanlai Turbat on 8/24/18.
//  Copyright © 2018 Batmanlai Turbat. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController{

    //MARK - Create Items
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    //MARK - Tableview each of cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        // same as above one line code
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // delete selected item from table
        
//        context.delete(itemArray[indexPath.row])  // first delete from database
//        itemArray.remove(at: indexPath.row)        // second delete from table
    }
    
    //MARK - Add new Items
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){ (action) in
            
            // what will happen once the user clicks the Add Item button on our UIAlert
            print(textField.text!)
           
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Items in the list"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert, animated:  true, completion: nil)
    }
    
    //MARK - Model Manupulation Method
    //Save function
    func saveItems() {

        do {
           try context.save()
        } catch{
           print("Error saving context \(context)")
        }
        self.tableView.reloadData()
    }
    
    //Load function
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        let Categorypredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
       
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Categorypredicate, addtionalPredicate])
        }else{
            request.predicate = Categorypredicate
        }
            do {
                itemArray = try context.fetch(request)
            } catch {
               print("Error fetching data from context \(error)")
            }
        tableView.reloadData()
        }
}

 //MARK - SearchBar
extension ToDoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
         request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    //MARK - clear or press X to show default table.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            //hide keyboard after clean word from searchbar
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


