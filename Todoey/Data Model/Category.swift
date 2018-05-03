//
//  Category.swift
//  Todoey
//
//  Created by Hongjun Kan on 5/2/18.
//  Copyright © 2018 Jenny Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
