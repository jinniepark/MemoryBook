//
//  CollectionController.swift
//  Memory Book
//
//  Created by Brady Zhang on 4/25/18.
//  Copyright © 2018 Brady Zhang. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import CoreData
import SQLite3
import MobileCoreServices

class CollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    var db: OpaquePointer?
    var pinID: Int32?
    var imageList: [UIImage] = []
    var encodeList: [String] = []
    var currentCellImage : UIImage?
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var deletePinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("CoreDatabase.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }

        let queryString = "SELECT photo FROM Photo WHERE pinID=" + String(self.pinID!)
        print(queryString)
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }

        while(sqlite3_step(stmt) == SQLITE_ROW){
            let imageStr = String(cString: sqlite3_column_text(stmt, 0))
            encodeList.append(imageStr)
            let dataDecoded : Data = Data(base64Encoded: imageStr, options: .ignoreUnknownCharacters)!
            let decodedImage = UIImage(data: dataDecoded)!
            imageList.append(decodedImage)
        }
    }
   
    override func viewWillLayoutSubviews() {
        [super.viewWillLayoutSubviews];
        self.collectionView.frame = self.view.bounds;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        cell.image.image = imageList[indexPath.row]
        currentCellImage = imageList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction( title : "Share", style: UIAlertActionStyle.default, handler: { action in

        
            let cellImage = self.imageList[indexPath.row]
        let imageToShare = [ cellImage ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction( title : "Delete", style: UIAlertActionStyle.default, handler: { action in
            
            let imageString : String! = self.encodeList[indexPath.item]
            let deleteQuery = "DELETE FROM Photo WHERE photo='" + String(imageString!) + "'"
            //print(self.imageList)
            //print(self.encodeList)
            self.encodeList.remove(at: indexPath.item)
           // print(self.encodeList)
            print(self.imageList)
            self.imageList.remove(at: indexPath.item)
            print(self.imageList)
            var deleteStmt: OpaquePointer?
            if sqlite3_prepare(self.db, deleteQuery, -1, &deleteStmt, nil) == SQLITE_OK {
                if sqlite3_step(deleteStmt) == SQLITE_DONE {
                    print("Successfully deleted photos.")

                    let alert = UIAlertController(title: "Success!", message: "Photo was deleted!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { action in
                        self.collectionView.reloadData()
}))
                    self.present(alert, animated: true, completion: nil)

                } else {
                    print("Could not delete photos.")
                }
            } else {
                print("Photo DELETE statement could not be prepared")
            }
        }))
        self.present(alert, animated: true, completion: nil)

    }
 
    @IBAction func deletePin(_ sender: Any) {
        let alert = UIAlertController(title: "Notice", message: "Are you sure you want to delete the pin?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
//            NSLog("The \"OK\" alert occured.")
//        }))
        alert.addAction(UIAlertAction( title : "Continue", style: UIAlertActionStyle.default, handler: { action in
        //alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        //self.present(alert, animated: true, completion: nil)
        let deleteQuery = "DELETE FROM Photo WHERE pinID=" + String(self.pinID!)
        var deleteStmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, deleteQuery, -1, &deleteStmt, nil) == SQLITE_OK {
            if sqlite3_step(deleteStmt) == SQLITE_DONE {
                print("Successfully deleted photos.")
            } else {
                print("Could not delete photos.")
            }
        } else {
            print("Photo DELETE statement could not be prepared")
        }
        
        //let deleteQuery2 = "DELETE FROM Pin WHERE id=" + String(self.pinID!)
        let deleteQuery2 = "DELETE FROM Pin WHERE id IN (SELECT id FROM Pin WHERE longitude IN (SELECT longitude FROM Pin WHERE id=" + String(self.pinID!) + ") AND latitude IN (SELECT latitude FROM PIN WHERE id=" + String(self.pinID!) + "))"
        print(deleteQuery2)
        var deleteStmt2: OpaquePointer?
            if sqlite3_prepare_v2(self.db, deleteQuery2, -1, &deleteStmt2, nil) == SQLITE_OK {
            if sqlite3_step(deleteStmt2) == SQLITE_DONE {
                print("Successfully deleted pin.")
            } else {
                print("Could not delete pin.")
            }
        } else {
            print("Pin DELETE statement could not be prepared")
        }
            self.performSegue(withIdentifier: "deletePin", sender: nil)

    }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

}

