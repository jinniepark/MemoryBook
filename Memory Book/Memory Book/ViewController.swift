//
//  ViewController.swift
//  Memory Book
//
//  Created by Brady Zhang on 4/6/18.
//  Copyright © 2018 Brady Zhang. All rights reserved.
//



import UIKit
import MapKit
import CoreMotion
import CoreLocation
import CoreData
import SQLite3

import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {

    // Manager variables
    lazy var motionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var db: OpaquePointer?
    var newMedia: Bool?
    var pinId: Int32!
    var lat: String!
    var long: String!

    //IBOutlet connections
    @IBOutlet weak var mapView: MKMapView!
    
    // Load map, recreate preexisting pins, get permission for location services
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for location services authorization from the user.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location
            self.mapView.delegate = self
            mapView.userLocation.title = ""

        }
        
        // Connect to database
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("CoreDatabase.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // Create SQLite3 Database Table for pins if it doesn't already exist.
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Pin (id INTEGER PRIMARY KEY AUTOINCREMENT, latitude REAL, longitude REAL)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        // Create SQLite3 Database Table for photos if it doesn't already exist.
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Photo (id INTEGER PRIMARY KEY AUTOINCREMENT, photo TEXT, PinID INTEGER, FOREIGN KEY (PinID) REFERENCES Pin(id))", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        // UNCOMMENT TO HAVE NO PREVIOUS PINS. COMMENT OUT TO RESET DATABASE TABLE EACH TIME.
        //resetDatabase()
        
        // Get all presaved pin locations
        let queryString = "SELECT * FROM Pin"
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        // Create annotations from presaved pin locations
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let annotation = MKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: sqlite3_column_double(stmt, 1),longitude: sqlite3_column_double(stmt, 2))
            annotation.coordinate = location
            print(String(sqlite3_column_int(stmt,1)))
            print(String(sqlite3_column_double(stmt, 1)))
            print(String(sqlite3_column_double(stmt, 2)))
            annotation.title = ""
            annotation.subtitle = ""
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewWillLayoutSubviews() {
    [super.viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;
    }

    // Function to reset all pins for testing
    func resetDatabase() {
        let deleteQuery1 = "DELETE FROM Photo";
        var deleteStmt1: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteQuery1, -1, &deleteStmt1, nil) == SQLITE_OK {
            if sqlite3_step(deleteStmt1) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        // Delete all rows from Pin
        let deleteQuery = "DELETE FROM Pin";
        var deleteStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteQuery, -1, &deleteStmt, nil) == SQLITE_OK {
            if sqlite3_step(deleteStmt) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
    }
    
    // Memory warnings
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Create pin and insert to database on shake
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print ("SHAKE GESTURE DETECTED")
            // Insert location as pin into database
            self.currentLocation = self.locationManager.location
            let currLatitude = String(Double(round(10000*currentLocation.coordinate.latitude)/10000))
            let currLongitude = String(Double(round(10000*currentLocation.coordinate.longitude)/10000))
            
            let queryString = "SELECT COUNT(1) FROM Pin WHERE latitude=" + currLatitude + " AND longitude=" + currLongitude
            print(queryString)
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            var count: Int32 = 0
            while(sqlite3_step(stmt) == SQLITE_ROW){
                count = sqlite3_column_int(stmt,0)
            }
            
            print(count)
            if count == 0 {
                var stmt1: OpaquePointer?
                let queryString = "INSERT INTO Pin (latitude, longitude) VALUES (" + currLatitude + "," + currLongitude + ")"
                print(queryString)
                
                // Prepare insert statement
                if sqlite3_prepare(db, queryString, -1, &stmt1, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                
                // Executing the query to insert values
                if sqlite3_step(stmt1) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting pin: \(errmsg)")
                    return
                }
                
                // Creating annotation from current Location
                let annotation = MKPointAnnotation()
                annotation.coordinate = currentLocation.coordinate
                print("Current latitude: " + currLatitude)
                print("Current longitude: " + currLongitude)
                annotation.title = ""
                annotation.subtitle = ""
                mapView.addAnnotation(annotation)

                // Display success alert (WILL NEED UNSUCCESSFUL ALERT IF LOCATION ALREADY WAS SAVED
                let alert = UIAlertController(title: "Success!", message: "Your current location was saved.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Whoops!", message: "This pin already exists.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
        
    
    // Try to see if user clicked on annotation (NOT CURRENTLY WORKING)
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        print("User selected annotation!")
       
        let latitude = (view.annotation?.coordinate.latitude ?? 0.00) //default: 0.00
        let longitude = (view.annotation?.coordinate.longitude ?? 0.00) //default: 0.00
        self.lat = String(Double(round(10000*latitude)/10000))
        self.long = String(Double(round(10000*longitude)/10000))
        
        let singleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.15
        self.mapView.addGestureRecognizer(longPressGesture)
        
        
    }
    
    @objc func singleTap(gesture: UITapGestureRecognizer) {
        print("User pressed annotation.")
        let queryString = "SELECT id FROM Pin WHERE latitude=" + (self.lat!) + " AND longitude=" + (self.long!)
        print(queryString)
        var stmt:OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            pinId = sqlite3_column_int(stmt,0)
        }
        self.performSegue(withIdentifier: "displayCollection", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayCollection" {
            let destVC = segue.destination as! UINavigationController
            // let nextVC = destVC.viewCon as! GalleryController
            let nextVC = destVC.topViewController as! CollectionController
            nextVC.pinID = pinId
        }
    }
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            print("long pressed")
            let queryString = "SELECT id FROM Pin WHERE latitude=" + (self.lat!) + " AND longitude=" + (self.long!)
            print(queryString)
            var stmt:OpaquePointer?
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            while(sqlite3_step(stmt) == SQLITE_ROW){
                pinId = sqlite3_column_int(stmt,0)
            }
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true,
                             completion: nil)
                newMedia = true
                
            }
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        let image : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData:Data = UIImageJPEGRepresentation(image, 0.8)!
        //let imageData:Data = UIImagePNGRepresentation(image)!

        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        
        
        var stmt: OpaquePointer?
        let queryString = "INSERT INTO Photo (photo, PinId) VALUES ('" + strBase64 + "'," + String(pinId) + ")"


        // Prepare insert statement
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        // Executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting photo: \(errmsg)")
            return
        }

        dismiss(animated:true, completion: nil)
        let alert = UIAlertController(title: "Success!", message: "Photo was saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

