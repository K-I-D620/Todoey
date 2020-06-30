//
//  Item.swift
//  Todoey
//
//  Created by TomHe on 20/06/2020.
//  Copyright © 2020 TomHe. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    @objc dynamic var colorItem : String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") //reverse relationship
}
