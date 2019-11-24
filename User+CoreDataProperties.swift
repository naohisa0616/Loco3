//
//  User+CoreDataProperties.swift
//  
//
//  Created by 宮崎直久 on 2019/11/18.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var attribute: NSObject?

}
