//
//  MainMenu.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-14.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

class MainMenu: UIViewController {
    var caller = "MainMenu"
    
    @IBOutlet var background: UIView!
    @IBOutlet var mainMenuLabel: UILabel!
    @IBOutlet var instructionsButton: UIButton!
    @IBOutlet var passByPassGameButton: UIButton!
    @IBOutlet var wifiGameButton: UIButton!
    @IBOutlet var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Setup
        background.backgroundColor = Style.mainColorGreen;
        mainMenuLabel.textColor = Style.mainColorBlack;
        instructionsButton.backgroundColor = Style.mainColorBlack;
        instructionsButton.setTitleColor(Style.mainColorWhite, for: .normal);
//        passByPassGameButton.backgroundColor = Style.mainColorBlack;
//        passByPassGameButton.setTitleColor(Style.mainColorWhite, for: .normal);
//        wifiGameButton.backgroundColor = Style.mainColorBlack;
//        wifiGameButton.setTitleColor(Style.mainColorWhite, for: .normal);
        welcomeLabel.textColor = Style.mainColorBlack;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 201:
            let alert = UIAlertController(title: "Sorry!", message: "Instructions not available", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            break
        case 202:
            let multiplayer = false
            let instructions = false
            let extras = [multiplayer, caller, instructions] as [Any]
            self.performSegue(withIdentifier: "GameTypeSelection", sender: extras)
            break
        case 203:
            let multiplayer = true
            let instructions = false
            let extras = [multiplayer, caller, instructions] as [Any]
            self.performSegue(withIdentifier: "GameTypeSelection", sender: extras)
            break
        default:
            return
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GameTypeSelection") {
            let levelMenu = segue.destination as! LevelMenu
            let extras = sender as! [Any]
            LevelMenu.multiplayer = extras[0] as! Bool
            levelMenu.caller = extras[1] as! String
            levelMenu.instructions = extras[2] as! Bool
            levelMenu.mainMenu = self
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
