//
//  ViewController.swift
//  WinkGame
//
//  Created by Waddah Al Drobi on 2019-04-22.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createGame"{
            let ref = Database.database().reference()
            let server = self.generateRandomNumber(numDigits: 5)
            let vc = segue.destination as! GameCreated
            vc.serverNum = server
            ref.child("servers").childByAutoId().setValue(server)
            ref.child("servers/\(server)/numPlayers").setValue(1)
            
        }
    }
    
    
    func generateRandomNumber(numDigits: Int) -> Int{
        var place = 1
        var finalNumber = 0
        for _ in 0 ..< numDigits{
            place *= 10
            let randomNumber = arc4random_uniform(10)
            finalNumber += Int(randomNumber) * place
        }
        return finalNumber
    }

}

