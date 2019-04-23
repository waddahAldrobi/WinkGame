//
//  GameCreated.swift
//  WinkGame
//
//  Created by Waddah Al Drobi on 2019-04-22.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GameCreated: UIViewController {
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var serverName: UITextField!
    @IBOutlet weak var playerNickName: UITextField!
    @IBOutlet weak var numJoined: UILabel!
    @IBOutlet weak var namesJoined: UITextView!
    
    var serverNum = 0
    var joinedNum = 1
    
    // Back exits the game
    //Should cancel other players out too
    override func viewDidLoad() {
        super.viewDidLoad()
        codeLabel.text = String(serverNum)
        numJoined.text = String(joinedNum)
        
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
                    self.namesJoined.text = names
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
                    self.numJoined.text = String(snap.value as! Int)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func createGame(_ sender: Any) {
        let ref = Database.database().reference()
        ref.child("servers/\(serverNum)/serverName").setValue(serverName.text)
        ref.child("servers/\(serverNum)/players").childByAutoId().setValue(playerNickName.text)
        
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
