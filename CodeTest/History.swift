//
//  History.swift
//  CodeTest
//
//  Created by alexfu on 3/11/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import Foundation
import CoreData

@objc(History)
class History: NSManagedObject {

    class func newRecordInContext(context: NSManagedObjectContext) -> History {
        let tempRecord = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: context) as! History
        
        tempRecord.resetFieldsToDefaults()
        return tempRecord
    }
    
    class func allRecordInContext(context: NSManagedObjectContext) throws -> [History] {
        let fr = NSFetchRequest(entityName: "History")
        return try! context.executeFetchRequest(fr) as! [History]
    }
    
    class func NotExist(context: NSManagedObjectContext,searchText:String) throws -> Bool{
        let fetchRequest = NSFetchRequest(entityName: "History")

        fetchRequest.predicate = NSPredicate(format: "query == %@", searchText)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "query", ascending: true)]
        let temp=try! context.executeFetchRequest(fetchRequest) as! [History]
        if (temp.count>0) {
            return false
        }
        else {
            return true
        }
        
    }

    
    func resetFieldsToDefaults() {
        query = ""
    }


}
