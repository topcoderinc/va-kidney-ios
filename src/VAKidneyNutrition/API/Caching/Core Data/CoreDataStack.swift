//
//  CoreDataStack.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 12/21/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import CoreData

/**
 * Utility that supports Core Data stack
 *
 * - author: TCCODER
 * - version: 1.0
 */
public final class CoreDataStack {

    /// shared instanace
    static let shared: CoreDataStack = CoreDataStack(modelName: "VAKidneyNutrition")

    /// Represents the model name property.
    public let modelName: String

    /// Represents the context property.
    public let context: NSManagedObjectContext

    /// view context
    lazy var viewContext: NSManagedObjectContext = {
        return self.context
    }()

    /**
     Initialize new instance with model name and concurrency type.

     - parameter modelName: the model name parameter.

     - returns: The new created instance.
     */
    public init(modelName: String) {
        self.modelName = modelName;
        self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent(modelName + ".sqlite")
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!

        let model = NSManagedObjectModel(contentsOf: modelURL)!
        self.context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.context.mergePolicy = NSOverwriteMergePolicy
        var error: NSError?
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try self.context.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil
                , at: storeURL, options: options)
        } catch let error1 as NSError {
            error = error1
        }
        if let error = error {
            NSLog("Fatal error occurred while creating persistence stack: \(error)")
        }
    }

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appirio.mobile.Interlochen_Media" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
}

