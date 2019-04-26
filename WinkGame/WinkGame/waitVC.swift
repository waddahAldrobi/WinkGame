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
    var playerNames = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        serverNumber.text = String(serverNum)
        playerNickname.text = nickname
        
        self.navigationController?.navigationItem.hidesBackButton = true
        let exitButton = UIBarButtonItem(title: "Exit", style: UIBarButtonItem.Style.done, target: nil, action: nil)
        self.navigationController?.navigationItem.leftBarButtonItem = exitButton
        
        let ref = Database.database().reference()
        
        
        // Names of players who have joined
        ref.child("servers/\(serverNum)/players").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else {
                let dict = (snap.value as! NSDictionary) as! [String: String]
                self.playerNames.removeAll()
                var names = ""
                for (key, value) in dict{
                    names += String(value) + "\n"
                    self.playerNames[value] = key
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
        
        ref.child("servers/\(serverNum)/gameInProgress").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else {
                if (snap.value as! Bool) == true{
                    self.performSegue(withIdentifier: "startFromJoin", sender: nil)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        self.navigationItem.hidesBackButton = true
        let exitButton = UIBarButtonItem(title: "Exit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(exitButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = exitButton
    }
    
    @objc func exitButtonTapped(_ sender: UIBarButtonItem)
    {
        print("servers/\(serverNum )/players/\(playerNames[nickname]!)")
        let ref = Database.database().reference()
        ref.child("servers/\(serverNum )/players/\(playerNames[nickname]!)").removeValue()
        ref.child("servers/\(serverNum)/numPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            ref.child("servers/\(self.serverNum)/numPlayers").setValue(value-1)
            
        })
        self.navigationController?.popViewController(animated: true)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "startFromJoin"{
            let vc = segue.destination as! GameVC
            vc.serverNum = serverNum
            vc.name = playerNickname.text!
        }
    }
 

}
