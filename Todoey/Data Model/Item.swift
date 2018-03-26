//
//  Item.swift
//  Todoey
//
//  Created by BB on 22/3/18.
//  Copyright © 2018 Yong. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?

    
    var parentCatagory = LinkingObjects(fromType: Category.self, property: "items")
}
