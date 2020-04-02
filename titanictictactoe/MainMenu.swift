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
    @IBOutlet var level1Button: UIButton!
    @IBOutlet var level2Button: UIButton!
    @IBOutlet var level3Button: UIButton!
    @IBOutlet var level4Button: UIButton!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var currentGamesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 201:
            let alert = UIAlertController(title: "Sorry!", message: "Instructions not available", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            break
        case 303:
            let level = 1
            let extras = [level] as [Any]
            self.performSegue(withIdentifier: "SelectPlayers", sender: extras)
            break
        case 304:
            let level = 2
            let extras = [level] as [Any]
            self.performSegue(withIdentifier: "SelectPlayers", sender: extras)
            break
        case 307:
            self.performSegue(withIdentifier: "ViewCurrentGames", sender: [])
        default:
            let alert = UIAlertController(title: "Sorry!", message: sender.titleLabel!.text! + " not available", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectPlayers") {
            let playerSelector = segue.destination as! PlayerSelector
            let extras = sender as! [Any]
            playerSelector.level = extras[0] as! Int
        }
    }
}
