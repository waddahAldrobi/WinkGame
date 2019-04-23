//
//  waitVC.swift
//  WinkGame
//
//  Created by Waddah Al Drobi on 2019-04-23.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit
import FirebaseDatabase

// Must add exit or cancel with -1

class waitVC: UIViewController {
    @IBOutlet weak var serverNumber: UILabel!
    @IBOutlet weak var playerNickname: UILabel!
    @IBOutlet weak var numPlayers: UILabel!
    @IBOutlet weak var playersJoined: UITextView!
    
    var serverNum = 0
    var nickname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        serverNumber.text = String(serverNum)
        playerNickname.text = nickname
        
        let ref = Database.database().reference()
        
        
        // Names of players who have joined
        ref.child("servers/\(serverNum)/players").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else {
                let dict = (snap.value as! NSDictionary) as! [String: String]
                var names = ""
                for (_, value) in dict{
                    names += String(value) + "\n"
                }
                DispatchQueue.main.async {
                    self.playersJoined.text = names
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        // Number of Players label
        ref.child("servers/\(serverNum)/numPlayers").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else {
                DispatchQueue.main.async {
                    self.numPlayers.text = String(snap.value as! Int)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
