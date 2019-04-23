//
//  joinGame.swift
//  WinkGame
//
//  Created by Waddah Al Drobi on 2019-04-23.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit
import FirebaseDatabase

class joinGame: UIViewController {
    @IBOutlet weak var serverNum: UITextField!
    @IBOutlet weak var playerName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Must do name checking
    // Must do Alert for wrong server
    // If user hits back must exit and -1 num
    // Join Sends You to page where you wait and see users come in
    @IBAction func joinServer(_ sender: Any) {
        let ref = Database.database().reference()
        ref.child("servers/\(serverNum.text!)/players").childByAutoId().setValue(playerName.text)
        ref.child("servers/\(serverNum.text!)/numPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            ref.child("servers/\(self.serverNum.text!)/numPlayers").setValue(value+1)
            
        })
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "waitStart"{
            let vc = segue.destination as! waitVC
            vc.serverNum = Int(serverNum.text!)!
            vc.nickname = playerName.text!
            
        }
    }
 

}
