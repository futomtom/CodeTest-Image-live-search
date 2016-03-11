//
//  HistoryVC.swift
//  CodeTest
//
//  Created by alexfu on 3/11/16.
//  Copyright © 2016 alexfu. All rights reserved.
//
    import UIKit
    import CoreData
    
    import JSQCoreDataKit

    
    class HistoryVC: UITableViewController, NSFetchedResultsControllerDelegate {
        
        var stack: CoreDataStack!
        
        var frc: NSFetchedResultsController?
        
      //  var history: History!
        
        
        // MARK: View lifecycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.allowsSelection = false
            setupFRC()
        }
        
        func fetchRequest(context: NSManagedObjectContext) -> FetchRequest<History> {
            let e = entity(name: "History", context: context)
            let fetch = FetchRequest<History>(entity: e)
            fetch.predicate = NSPredicate(value: true)
            fetch.sortDescriptors = [NSSortDescriptor(key: "query", ascending: true)]

            
            return fetch
        }
        
        func setupFRC() {
            let request = fetchRequest(self.stack.mainContext)
            
            self.frc = NSFetchedResultsController(fetchRequest: request,
                managedObjectContext: self.stack.mainContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            
            self.frc?.delegate = self
            
            fetchData()
        }
        
        func fetchData() {
            do {
                try self.frc?.performFetch()
                tableView.reloadData()
            } catch {
                assertionFailure("Failed to fetch: \(error)")
            }
        }
        
        
        // MARK: Table view data source
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.frc?.fetchedObjects?.count ?? 0
        }
        
        func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
            let history = self.frc?.objectAtIndexPath(indexPath) as! History
            cell.textLabel?.text = history.query
                   }
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            configureCell(cell, atIndexPath: indexPath)
            return cell
        }
        
        override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Search"
        }
        
        
        // MARK: Table view delegate
        
        override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
        }
        
        func controllerWillChangeContent(controller: NSFetchedResultsController) {
            self.tableView.beginUpdates()
        }
        
        func controllerDidChangeContent(controller: NSFetchedResultsController) {
            tableView.endUpdates()
        }

        }
   
