//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Batmanlai Turbat on 8/25/18.
//  Copyright © 2018 Batmanlai Turbat. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItem()
    }

    //MARK - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    //MARK - Data Manipulation Methods
    
    func saveItem() {
        do {
            try context.save()
        } catch{
            print("Error saving context \(context)")
        }
        self.tableView.reloadData()
    }
    
    func loadItem(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching from DATA \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = itemArray[indexPath.row]
        }
    }
   
    //MARK - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        
        //Alert
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add item", style: .default){(action) in
            let newItem = Category(context: self.context)
            newItem.name = textField.text!
            self.itemArray.append(newItem)
            self.saveItem()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .default){(actionCancel) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
}
