//
//  RoomController.swift
//  EnterFace
//
//  Created by Kevin Wang on 10/24/20.
//  Copyright © 2020 Kevin Wang. All rights reserved.
//

import Foundation
import UIKit

class RoomController: UIViewController {
    
    @IBOutlet weak var roomName: UILabel!
    
    @IBOutlet weak var roomImage: UIImageView!
    @IBAction func leavePressed(_ sender: Any) {
        performSegue(withIdentifier: "roomToHome", sender: self)
    }
}
