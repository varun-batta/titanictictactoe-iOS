//
//  Winner.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-20.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

class Winner: UIViewController {

    var winnerName : String!
    var mainMenu : MainMenu!
    var levelMenu : LevelMenu!
    var board : Board!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let winnerLabel : UILabel = self.view.viewWithTag(502) as! UILabel
        let congratsLabel : UILabel = self.view.viewWithTag(503) as! UILabel
        if winnerName != nil {
            if winnerName == "Tie" {
                winnerLabel.text = "It's a Tie!"
                congratsLabel.isHidden = true
            } else {
                winnerLabel.text = winnerName + " WINS!!!"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func bottomPanelListener(_ sender: UIButton) {
        switch (sender.tag) {
        case 504:
            print("Dismissing levelMenu")
            mainMenu.dismiss(animated: true, completion: nil)
            break
        case 505:
            print("Dismissing Winner.self")
            self.dismiss(animated: true, completion: nil)
            break
        case 506:
            print("Dismissing board")
            levelMenu.dismiss(animated: true, completion: nil)
            break
        case 507:
            print("Dismissing board")
            levelMenu.dismiss(animated: true, completion: nil)
            break
        default:
            return
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
