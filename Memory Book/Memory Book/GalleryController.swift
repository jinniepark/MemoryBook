//
//  GalleryController.swift
//  Memory Book
//
//  Created by Jinnie Park on 4/22/18.
//  Copyright © 2018 Brady Zhang. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SQLite3

import MobileCoreServices

class GalleryController: UIViewController {
    var lat: String!
    var long: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(lat)
        print(long)
    }
}
