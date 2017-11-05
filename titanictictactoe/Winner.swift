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
    
    @IBOutlet var background: UIView!
    @IBOutlet var playerWinsLabel: UILabel!
    @IBOutlet var congratsLabel: UILabel!
    @IBOutlet var mainMenuButton: UIButton!
    @IBOutlet var viewGameButton: UIButton!
    @IBOutlet var newGameButton: UIButton!
    @IBOutlet var newWifiGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if winnerName != nil {
            if winnerName == "Tie" {
                playerWinsLabel.text = "It's a Tie!"
                congratsLabel.isHidden = true
            } else {
                playerWinsLabel.text = winnerName + " WINS!!!"
            }
        }
        
        // UI Setup
        background.backgroundColor = Style.mainColorGreen;
        playerWinsLabel.textColor = Style.mainColorBlack;
        congratsLabel.textColor = Style.mainColorBlack;
        mainMenuButton.backgroundColor = Style.mainColorBlack;
        mainMenuButton.setTitleColor(Style.mainColorWhite, for: .normal);
        viewGameButton.backgroundColor = Style.mainColorBlack;
        viewGameButton.setTitleColor(Style.mainColorWhite, for: .normal);
        newGameButton.backgroundColor = Style.mainColorBlack;
        newGameButton.setTitleColor(Style.mainColorWhite, for: .normal);
        newWifiGameButton.backgroundColor = Style.mainColorBlack;
        newWifiGameButton.setTitleColor(Style.mainColorWhite, for: .normal);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func bottomPanelListener(_ sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        switch (sender.tag) {
        case 504:
            print("Dismissing levelMenu")
            if (self.mainMenu == nil) {
                let mainMenu = main.instantiateViewController(withIdentifier: "MainMenu")
                self.present(mainMenu, animated: true, completion: nil)
            } else {
                self.mainMenu.dismiss(animated: true, completion: nil)
            }
            break
        case 505:
            print("Dismissing Winner.self")
            self.dismiss(animated: true, completion: nil)
            break
        case 506:
            print("Dismissing board")
            if (self.levelMenu == nil) {
                let levelMenu = main.instantiateViewController(withIdentifier: "LevelMenu")
                self.present(levelMenu, animated: true, completion: nil)
            } else {
                self.levelMenu.dismiss(animated: true, completion: nil)
            }
            break
        case 507:
            print("Dismissing board")
            if (self.levelMenu == nil) {
                let levelMenu = main.instantiateViewController(withIdentifier: "LevelMenu") as! LevelMenu
                self.present(levelMenu, animated: true, completion: nil)
            } else {
                self.levelMenu.dismiss(animated: true, completion: nil)
            }
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
