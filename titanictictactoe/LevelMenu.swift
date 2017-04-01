//
//  LevelMenu.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-14.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

import FacebookLogin
import FacebookShare
import FacebookCore
import FBSDKShareKit

class LevelMenu: UIViewController, FBSDKGameRequestDialogDelegate {
    var multiplayer = false
    var caller = ""
    var instructions = false
    var player1 : String = "Player 1"
    var player2 : String = "Player 2"
    var level : Int = 1
    var mainMenu : MainMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleLabel = self.view.viewWithTag(301) as! UILabel
        let savedGamesButton = self.view.viewWithTag(307) as! UIButton
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .userFriends ])
        loginButton.frame = CGRect(origin: CGPoint(x: self.view.frame.width * 0.1, y: self.view.frame.height / 1.7), size: CGSize(width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.05))
        if (multiplayer) {
            titleLabel.text = "WiFi Game"
            savedGamesButton.setTitle("Current Games", for: .normal)
            self.view.addSubview(loginButton)
        } else {
            titleLabel.text = "Pass-by-Pass Game"
            savedGamesButton.setTitle("Saved Games", for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func levelSelect(_ sender: UIButton) {
        switch sender.tag {
        case 303:
            self.level = 1
            
            if !multiplayer {
                let alert = UIAlertController(title: "Player Names", message: "Please Enter the Player Names:", preferredStyle: UIAlertControllerStyle.alert)
            
                alert.addTextField(configurationHandler: {(textField) in textField.placeholder = "Player 1" })
                alert.addTextField(configurationHandler: {(textField) in textField.placeholder = "Player 2" })
            
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let player1TextField = alert!.textFields![0]
                    self.player1 = player1TextField.text!
                    let player2TextField = alert!.textFields![1]
                    self.player2 = player2TextField.text!
                
                    let extras = [self.level, self.player1, self.player2] as [Any]
                
                    self.performSegue(withIdentifier: "ToGame", sender: extras)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let gameRequest = FBSDKGameRequestContent()
                gameRequest.message = "New Match"
                gameRequest.actionType = .turn
//                let gameRequestDialog = FBSDKGameRequestDialog()
                FBSDKGameRequestDialog.show(with: gameRequest, delegate: self)
            }
            
            break
        case 304:
            self.level = 2
            
            let alert = UIAlertController(title: "Player Names", message: "Please Enter the Player Names:", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addTextField(configurationHandler: {(textField) in textField.placeholder = "Player 1" })
            alert.addTextField(configurationHandler: {(textField) in textField.placeholder = "Player 2" })
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let player1TextField = alert!.textFields![0]
                self.player1 = player1TextField.text!
                let player2TextField = alert!.textFields![1]
                self.player2 = player2TextField.text!
                
                let extras = [self.level, self.player1, self.player2] as [Any]
                
                self.performSegue(withIdentifier: "ToGame", sender: extras)
            }))
            self.present(alert, animated: true, completion: nil)
            
            break
        case 308:
            self.dismiss(animated: true, completion: nil)
            break
        default:
            return
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToGame" {
            let board = segue.destination as! Board
//            let levelSelect = sender as! Int
//            board.level = levelSelect
            let extras = sender as! [Any]
            board.level = extras[0] as! Int
            Board.player1 = extras[1] as! String
            Board.player2 = extras[2] as! String
            board.levelMenu = self
            board.mainMenu = self.mainMenu
        }
        // Pass the selected object to the new view controller.
    }
    
    //MARK: FBSDKGameRequestDialogDelegate
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        if results["to"] == nil {
            let alert = UIAlertController(title: "No friends selected!", message: "You haven't selected any friends to play against. Please select just ONE friend.", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let recipients = results["to"] as! NSArray
            if recipients.count > 1 {
                let alert = UIAlertController(title: "Too many friends selected!", message: "You have selected too many friends to play against. Please select just ONE friend.", preferredStyle: UIAlertControllerStyle.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Good!")
            }
        }
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didFailWithError error: Error!) {
        print("didFailWithError", error)
    }

    func gameRequestDialogDidCancel(_ gameRequestDialog: FBSDKGameRequestDialog!) {
        print("didCancel")
    }
}
