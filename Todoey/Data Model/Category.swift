//
//  Category.swift
//  Todoey
//
//  Created by BB on 22/3/18.
//  Copyright © 2018 Yong. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()  //relationship, one category can have multiple list of items
}
