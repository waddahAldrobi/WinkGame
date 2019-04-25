//
//  SubmittedVC.swift
//  WinkGame
//
//  Created by Waddah Al Drobi on 2019-04-24.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit

class SubmittedVC: UIViewController {

    @IBOutlet weak var numSubmitted: UILabel!
    var namesAssigned = [String:Int]()
    var isCorrect = false
    var isCreator = false
    
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
    
    func alert (isCorrect: Bool) {
        // Create the alert controller
        let title = isCorrect ? "Correct" : "Wrong"
        let alertController = UIAlertController(title: title , message: "You've submitted", preferredStyle: .alert)
        
        // Create the actions
        let endAction = UIAlertAction(title: "End", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("End Pressed")
            
        }
        if isCreator {
            let playAgainAction = UIAlertAction(title: "Play Again", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                print("Play Again Pressed")
            }
            
            alertController.addAction(playAgainAction)
        }
        
        // Add the actions
        
        alertController.addAction(endAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }

}
