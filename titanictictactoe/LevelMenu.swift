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

class LevelMenu: UIViewController, FBSDKGameRequestDialogDelegate, FBSDKAppInviteDialogDelegate {
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
        let inviteFriendsButton : UIButton = self.view.viewWithTag(309) as! UIButton

        // Multiplayer vs. non-Multiplayer views
        if (multiplayer) {
            let loginButton = LoginButton(readPermissions: [ .publicProfile, .userFriends ])
            
            // Constraints for loginButton
            loginButton.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 0.8, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -20)
            let centerXConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
            
            titleLabel.text = "WiFi Game"
            savedGamesButton.setTitle("Current Games", for: .normal)
            self.view.addSubview(loginButton)
            inviteFriendsButton.addTarget(self, action: #selector(self.inviteFriends), for: UIControlEvents.touchUpInside)
            
            // Adding constraints for loginButton
            self.view.addConstraint(widthConstraint)
            self.view.addConstraint(bottomConstraint)
            self.view.addConstraint(centerXConstraint)

        } else {
            titleLabel.text = "Pass-by-Pass Game"
            savedGamesButton.setTitle("Saved Games", for: .normal)
            inviteFriendsButton.isHidden = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func inviteFriends() {
        let inviteDialog : FBSDKAppInviteDialog = FBSDKAppInviteDialog()
        
        if inviteDialog.canShow() {
            let appLinkURL : NSURL = NSURL(string: "https://fb.me.272886266489420")!
            
            let inviteContent : FBSDKAppInviteContent = FBSDKAppInviteContent()
            inviteContent.appLinkURL = appLinkURL as URL!
            
            inviteDialog.content = inviteContent
            inviteDialog.delegate = self
            inviteDialog.show()
        }
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
//                var gameRequest = GameRequest(title: "New Match", message: "Let's play Titanic Tic Tac Toe!")
//                gameRequest.actionType = .turn
//                do {
//                    try GameRequest.Dialog.show(gameRequest, completion: nil)
//                } catch is exception {
//                    print("Exception thrown")
//                }
                let gameRequest = FBSDKGameRequestContent()
                gameRequest.message = "New Match"
                gameRequest.actionType = .turn
                gameRequest.filters = .appUsers
                
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
            if extras.count > 3 {
                board.recipientID = extras[3] as! String
            }
            board.levelMenu = self
            board.mainMenu = self.mainMenu
            board.multiplayer = self.multiplayer
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
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me")) { httpResponse, result in
                    switch result {
                    case .success(let response):
                        print("Graph Request Succeeded: \(response.dictionaryValue?["name"])")
                        self.player1 = response.dictionaryValue?["name"] as! String
                        print("Graph Request Recipients \(recipients)")
                        let connection2 = GraphRequestConnection()
                        connection2.add(GraphRequest(graphPath: "/\(recipients[0])")) { httpResponse, result in
                            switch result {
                            case .success(let response):
                                print("Graph Request Succeeded: \(response.dictionaryValue?["name"])")
                                self.player2 = response.dictionaryValue?["name"] as! String
                                
                                let extras = [self.level, self.player1, self.player2, recipients[0]] as [Any]
                                self.performSegue(withIdentifier: "ToGame", sender: extras)
                            case .failed(let error):
                                print("Graph Request Failed: \(error)")
                            }
                        }
                        connection2.start()
                    case .failed(let error):
                        print("Graph Request Failed: \(error)")
                    }
                }
                connection.start()
                print("Good!")
            }
        }
    }
    
    func getNames() {
        
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didFailWithError error: Error!) {
        print("didFailWithError", error)
    }

    func gameRequestDialogDidCancel(_ gameRequestDialog: FBSDKGameRequestDialog!) {
        print("didCancel")
    }
    
    //MARK: FBSDKAppInviteDialogDelegate
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        let resultObject = NSDictionary(dictionary: results)
        
        for key in resultObject {
            print(key)
        }
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Error tool place in appInviteDialog \(error)")
    }
}
