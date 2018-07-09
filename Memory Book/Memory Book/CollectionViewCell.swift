//
//  CollectionViewCell.swift
//  Memory Book
//
//  Created by Brady Zhang on 4/25/18.
//  Copyright © 2018 Brady Zhang. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
    func displayContent(displayImage: UIImage) {
        self.image.image = displayImage
//        let singleTap = UITapGestureRecognizer(target: self, action: #selector("tapDetected"))
//        image.isUserInteractionEnabled = true
//        image.addGestureRecognizer(singleTap)
    }
    
//    @objc func tapDetected() {
//        let image = UIImage(named: "Image")
//        
//        // set up activity view controller
//        let imageToShare = [ image! ]
//        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//        
//        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
//        
//        // present the view controller
//        self.present(activityViewController, animated: true, completion: nil)
//    }
}
