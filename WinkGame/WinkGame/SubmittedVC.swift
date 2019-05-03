//
//  SubmittedVC.swift
//  WinkGame
//
//  Created by Waddah Al Drobi on 2019-04-24.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SubmittedVC: UIViewController {

    @IBOutlet weak var numSubmitted: UILabel!
    var isCorrect = false
    var isCreator = false
    var serverNum = 0
    var playerName = ""
    
    // need number of submissions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alert(isCorrect: isCorrect)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    let ref = Database.database().reference()
    func alert (isCorrect: Bool) {
        // Create the alert controller
        let title = isCorrect ? "Correct" : "Wrong"
        let alertController = UIAlertController(title: title , message: "You've submitted", preferredStyle: .alert)
        
        
        // Create the actions
        let endAction = UIAlertAction(title: "End", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            print("End Pressed")
            
        }
        if isCreator {
            let playAgainAction = UIAlertAction(title: "Another Round", style: UIAlertAction.Style.default) {
                UIAlertAction in
                print("Play Again Pressed")
                
                self.reloadDatabase(completion:{
                    self.popViewControllerss(popViews: 2)
                 })
            }

            
            alertController.addAction(playAgainAction)
            alertController.addAction(endAction) 
        }
        
        else {
            let playAgainAction = UIAlertAction(title: "Play Again", style: UIAlertAction.Style.default) {
                UIAlertAction in
                print("Play pressed")
                
                self.reloadDatabase(completion:{
                    self.popViewControllerss(popViews: 2)
                })
            }
            
            alertController.addAction(playAgainAction)
            alertController.addAction(endAction)
        }
        
        // Add the actions
        
        
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func reloadDatabase(completion: @escaping ()->Void){
        if isCreator{
            ref.child("servers/\(self.serverNum)/playersTypes").removeValue()
            ref.child("servers/\(self.serverNum)/players").removeValue()
            ref.child("servers/\(self.serverNum)/numPlayers").setValue(1)
            ref.child("servers/\(self.serverNum)/gameInProgress").setValue(false)
        }
        
        else {
            ref.child("servers/\(self.serverNum)/numPlayers").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as! Int
                self.ref.child("servers/\(self.serverNum)/numPlayers").setValue(value+1)
                
            })
            ref.child("servers/\(self.serverNum)/players").childByAutoId().setValue(self.playerName)
        }
            
        completion()
    }
    
    
    func popViewControllerss(popViews: Int, animated: Bool = true) {
        if self.navigationController!.viewControllers.count > popViews
        {
            let vc = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - popViews - 1]
            self.navigationController?.popToViewController(vc, animated: animated)
        }
    }


}
