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
    
    var ref = Database.database().reference()
    var name = ""
    var serverNum = 0
    var playerNames = [String]()
    var namesDict = [String: String]()
    var namesAssigned = [String:Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.playerPicker.delegate = self
        self.playerPicker.dataSource = self
        
        serverNumberLabel.text = "Server Number: " + String(serverNum)
        serverNumberLabel.text = name + ", you are a: "
        
        
        // Server Name
        ref.child("servers/\(serverNum)/serverName").observe(.value, with: { snap in
            if snap.value is NSNull {
                // Child not found
            } else {
                DispatchQueue.main.async {
                    self.serverNameLabel.text = snap.value as? String ?? "<Name>"
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
        
        getValueFromDatabase(completion:{
            
            print("Done", self.playerNames)
            self.playerPicker.reloadAllComponents()
            
        })
    }
    
    func getValueFromDatabase(completion: @escaping ()->Void){
        
        ref = Database.database().reference(withPath: "servers/\(serverNum)/players")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
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
        print("Winker is:", playerNames[playerPicker.selectedRow(inComponent: 0)])
        isCorrectPrediction = namesAssigned[playerNames[playerPicker.selectedRow(inComponent: 0)]] == 2
        self.alert(isCorrect: isCorrectPrediction)
    }
    
    func alert (isCorrect: Bool) {
        // Create the alert controller
        let title = isCorrect ? "Correct" : "Wrong"
        let alertController = UIAlertController(title: title , message: "You've submitted", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("OK Pressed")
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            print("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
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
