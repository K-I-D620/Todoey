//
//  Category.swift
//  Todoey
//
//  Created by TomHe on 20/06/2020.
//  Copyright © 2020 TomHe. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String =  ""
    @objc dynamic var colorCategory : String = ""
    let items = List<Item>() //forward relationship
}
