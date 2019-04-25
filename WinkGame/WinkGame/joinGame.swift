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
    var playerNames = [String]()
    var firstJoin = false
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Must do name checking
    // Must do Alert for wrong server
    // If user hits back must exit and -1 num
    // Join Sends You to page where you wait and see users come in
    @IBAction func joinServer(_ sender: Any) {
        
        // Names of players who have joined
        getNamesFromDatabase(completion:{
            print("playernames", self.playerNames)
            if self.playerNames.contains(self.playerName.text!){
                self.alert()
            }
            
            else{
                if !self.firstJoin { self.ref.child("servers/\(self.serverNum.text!)/players").childByAutoId().setValue(self.playerName.text) }
                self.ref.child("servers/\(self.serverNum.text!)/numPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as! Int
                self.ref.child("servers/\(self.serverNum.text!)/numPlayers").setValue(value+1)
                    
                })
                
                self.performSegue(withIdentifier: "waitStart", sender: nil)
            }
            
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
    
    func getNamesFromDatabase(completion: @escaping ()->Void){
        
        let ref2 = Database.database().reference(withPath: "servers/\(serverNum.text!)/players")
        
        ref2.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { self.ref.child("servers/\(self.serverNum.text!)/players").childByAutoId().setValue(self.playerName.text)
                self.firstJoin = true
            }
            else {
                let dict = (snapshot.value as! NSDictionary) as! [String: String]
                for (_, value) in dict{
                    self.playerNames.append(value)
                }
            }
            
            completion()
            
        })
    }
    
    func alert () {
        // Create the alert controller
        let title = "Nickname Alreay in Use"
        let alertController = UIAlertController(title: title , message: "Please use a different nickname", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("OK Pressed")
            
        }
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
 

}
