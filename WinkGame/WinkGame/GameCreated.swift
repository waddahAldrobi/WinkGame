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
    var playerNames = [String]()
    // Back exits the game
    // Should cancel other players out too
    override func viewDidLoad() {
        super.viewDidLoad()
        codeLabel.text = String(serverNum)
        numJoined.text = String(joinedNum)
        
        self.navigationItem.hidesBackButton = true
        
        
        let ref = Database.database().reference()
        
        // Names of players who have joined
        ref.child("servers/\(serverNum)/players").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
                self.namesJoined.text = ""
            } else {
                let dict = (snap.value as! NSDictionary) as? [String: String]
                if dict != nil {
                    var names = ""
                    self.playerNames = []
                    for (_, value) in dict!{
                        self.playerNames.append(value)
                        names += String(value) + "\n"
                    }
                    DispatchQueue.main.async {
                        self.namesJoined.text = names
                    }
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
                    self.joinedNum = snap.value as! Int
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        let exitButton = UIBarButtonItem(title: "Exit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(exitButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = exitButton
    }
    
    @IBAction func createGame(_ sender: Any) {
        
        
        if self.playerNickName.text!.count == 0{
            self.alert(emtpy: true)
        }
        else if self.playerNames.contains(self.playerNickName.text!){
            self.alert(emtpy: false)
        }
        else{
            playerNames.append(playerNickName.text ?? "Creator" )
            
            var types = [Int]()
            var assignedTypes = [String : Int]()
            // 0 is normal, 1 is Cop, 2 is Winker
            if joinedNum >= 2 {
                types.append(1)
                types.append(2)
                for _ in 0 ..< joinedNum-2{
                    types.append(0)
                }
            }
            // Shuffles and assigns
            types = types.shuffled()
            
            for (index, element) in playerNames.enumerated() {
                assignedTypes[element] = types[index]
            }
            
            print("assi:", assignedTypes)
            
            
            let ref = Database.database().reference()
            ref.child("servers/\(serverNum)/serverName").setValue(serverName.text)
            ref.child("servers/\(serverNum)/players").childByAutoId().setValue(playerNickName.text)
            ref.child("servers/\(serverNum)/playersTypes").setValue(assignedTypes)
            ref.child("servers/\(serverNum)/gameInProgress").setValue(true)
            ref.child("servers/\(serverNum)/numSubmitted").setValue(0)
        }
        
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "startFromCreate"{
            let vc = segue.destination as! GameVC
            vc.serverNum = serverNum
            vc.name = playerNickName.text!
            vc.isCreator = true
        }
    }
    
    
    func alert (emtpy: Bool) {
        // Create the alert controller
        var title = ""
        if emtpy { title = "Nickname can't be empty" }
        else { title = "Nickname Alreay in Use" }
        
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
    
    @objc func exitButtonTapped(_ sender: UIBarButtonItem)
    {
        let ref = Database.database().reference()
        ref.child("servers/\(self.serverNum)").removeValue()
        self.navigationController?.popViewController(animated: true)
    }
 

}
