//
//  RoomController.swift
//  EnterFace
//
//  Created by Kevin Wang on 10/24/20.
//  Copyright © 2020 Kevin Wang. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
class RoomController: UIViewController {
    var roomCap = 0
    var qr = "";
    var roomNam = ""
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var roomName: UILabel!
    
    @IBOutlet weak var roomImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        roomNam = UserDefaults.standard.string(forKey: "name") ?? "none"
        roomName.text = roomNam
        if (roomNam == "Gym") {
            image.image = UIImage(named: "Gym")
        }
        else if(roomNam == "Auditorium") {
            image.image = UIImage(named: "Auditorium")
        }
        else {
            image.image = UIImage(named: "Room")
        }
    }
    @IBAction func leavePressed(_ sender: Any) {
        
        let userDefaults = UserDefaults.standard
        roomCap = userDefaults.integer(forKey: "cap") ?? -5
        roomNam = userDefaults.string(forKey: "name") ?? "none"
        qr = userDefaults.string(forKey: "qr") ?? "error"
        roomName.text = roomNam
        var ref = Database.database().reference().child(qr)
        ref.child("capacity").setValue(roomCap)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "roomToHome", sender: self)
        
    }
}
