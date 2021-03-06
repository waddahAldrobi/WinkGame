//
//  GameVC.swift
//  WinkGame
//
//  Created by Waddah Al Drobi on 2019-04-24.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit
import FirebaseDatabase


class GameVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var playerPicker: UIPickerView!
    @IBOutlet weak var serverNumberLabel: UILabel!
    @IBOutlet weak var serverNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var submissionConfirmation: UILabel!
    
    
    var ref = Database.database().reference()
    var name = ""
    var serverNum = 0
    var playerNames = [String]()
    var namesDict = [String: String]()
    var namesAssigned = [String:Int]()
    var isCreator = false
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.playerPicker.delegate = self
        self.playerPicker.dataSource = self
        submitButton.isHidden = false
        
        serverNumberLabel.text = "Server Number: " + String(serverNum)
        nameLabel.text = name + ", you are a: "
        
        submissionConfirmation.isHidden = true
        
        
        // Server Name
        ref.child("servers/\(serverNum)/serverName").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else {
                DispatchQueue.main.async {
                    let serverName = snap.value as? String ?? "<Name>"
                    self.serverNameLabel.text = "The " + serverName + " Group"
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Number of submissions
        ref.child("servers/\(serverNum)/numSubmitted").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else if self.playerNames.count > 0{
                let value = snap.value as? Int ?? 0
                print("value:", value)
                print("players:", self.playerNames.count)
                if value == self.playerNames.count {
                    self.performSegue(withIdentifier: "submitted", sender: nil)
                }

            }
        }) { (error) in
            print(error.localizedDescription)
        }
        

        
        // Player Types
        ref.child("servers/\(serverNum)/playersTypes").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else {
                let dict = (snap.value as! NSDictionary) as! [String: Int]
                self.namesAssigned = dict
                var strType = ""
                
                switch dict[self.name] {
                    case 0: strType = "Normal"
                    case 1: strType = "Cop"
                    case 2: strType = "Winker"
                case .none:
                    print("Error 3")
                case .some(_):
                    print("Error 4")
                }
                
                DispatchQueue.main.async {
                    self.type.text = strType
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playerNames = []
        getValueFromDatabase(completion:{
            
            print("Done", self.playerNames)
            self.playerPicker.reloadAllComponents()
            
        })
    }
    
    func getValueFromDatabase(completion: @escaping ()->Void){
        
        ref.child("servers/\(serverNum)/players").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { return }
            
            let dict = (snapshot.value as! NSDictionary) as! [String: String]
            self.namesDict = dict
            for (_, value) in dict{
                self.playerNames.append(value)
            }
                
                completion()
            
        })
    }
    
        
    // PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Column count: use one column
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Row count: rows equals array length.
        return playerNames.count
    }
        
    func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
            
            // Return a string from the array for this row.
            return playerNames[row]
        }
    
    var isCorrectPrediction = false
    
    
    @IBAction func submitButton(_ sender: Any) {
        isCorrectPrediction = namesAssigned[playerNames[playerPicker.selectedRow(inComponent: 0)]] == 2
        submitButton.isHidden = true
        self.alert()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "submitted"{
            let vc = segue.destination as! SubmittedVC
//            vc.namesAssigned = namesAssigned
            vc.isCorrect = isCorrectPrediction
            vc.isCreator = isCreator
            vc.serverNum = serverNum
            vc.playerName = name
        }
    }
    
    
    func alert () {
        // Create the alert controller
        let title = "Are you sure that " + playerNames[playerPicker.selectedRow(inComponent: 0)] + " is the winker?"
        let alertController = UIAlertController(title: title , message: "", preferredStyle: .alert)
        
        // Create the actions
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            self.submissionConfirmation.isHidden = false
            // Number of Players label
            self.ref.child("servers/\(self.serverNum)/numSubmitted").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = (snapshot.value as? Int ?? 0) + 1
                self.ref.child("servers/\(self.serverNum)/numSubmitted").setValue(value)
                
            })
            
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        
        
        
        
        // Add the actions
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }

}
