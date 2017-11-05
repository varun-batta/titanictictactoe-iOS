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
    static var multiplayer = false
    var caller = ""
    var instructions = false
//    static var player1 : String = "Player 1"
//    static var player2 : String = "Player 2"
//    static var player1ID : Int = 0
//    static var player2ID : Int = 0
    static var player1 : Player = Player()
    static var player2 : Player = Player()
    var level : Int = 1
    var mainMenu : MainMenu!
    
    @IBOutlet var background: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pleaseSelectLevelLabel: UILabel!
    @IBOutlet var level1Button: UIButton!
    @IBOutlet var level2Button: UIButton!
    @IBOutlet var level3Button: UIButton!
    @IBOutlet var level4Button: UIButton!
    @IBOutlet var savedGamesButton: UIButton!
    @IBOutlet var mainMenuButton: UIButton!
    @IBOutlet var inviteFriendsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Multiplayer vs. non-Multiplayer views
        if (LevelMenu.multiplayer) {
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
            inviteFriendsButton.isEnabled = false
        }
        
        // UI Setup
        background.backgroundColor = Style.mainColorGreen;
        titleLabel.textColor = Style.mainColorBlack;
        pleaseSelectLevelLabel.textColor = Style.mainColorBlack;
        level1Button.backgroundColor = Style.mainColorBlack;
        level1Button.setTitleColor(Style.mainColorWhite, for: .normal);
        level2Button.backgroundColor = Style.mainColorBlack;
        level2Button.setTitleColor(Style.mainColorWhite, for: .normal);
        level3Button.backgroundColor = Style.mainColorBlack;
        level3Button.setTitleColor(Style.mainColorWhite, for: .normal);
        level4Button.backgroundColor = Style.mainColorBlack;
        level4Button.setTitleColor(Style.mainColorWhite, for: .normal);
        savedGamesButton.backgroundColor = Style.mainColorBlack;
        savedGamesButton.setTitleColor(Style.mainColorWhite, for: .normal);
        mainMenuButton.backgroundColor = Style.mainColorBlack;
        mainMenuButton.setTitleColor(Style.mainColorWhite, for: .normal);
        inviteFriendsButton.backgroundColor = Style.mainColorBlack;
        inviteFriendsButton.setTitleColor(Style.mainColorWhite, for: .normal);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func inviteFriends() {
        let inviteDialog : FBSDKAppInviteDialog = FBSDKAppInviteDialog()
        
        if inviteDialog.canShow() {
            let appLinkURL : NSURL = NSURL(string: "https://fb.me/358256697952376")!
            
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
            
            if !LevelMenu.multiplayer {
                let alert = UIAlertController(title: "Player Names", message: "Please Enter the Player Names:", preferredStyle: UIAlertControllerStyle.alert)
            
                alert.addTextField(configurationHandler: {(textField) in textField.placeholder = "Player 1" })
                alert.addTextField(configurationHandler: {(textField) in textField.placeholder = "Player 2" })
            
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let player1TextField = alert!.textFields![0]
                    LevelMenu.player1.playerName = player1TextField.text!
                    let player2TextField = alert!.textFields![1]
                    LevelMenu.player2.playerName = player2TextField.text!
                
                    let extras = [self.level, LevelMenu.player1, LevelMenu.player2] as [Any]
                
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
                LevelMenu.player1.playerName = player1TextField.text!
                let player2TextField = alert!.textFields![1]
                LevelMenu.player2.playerName = player2TextField.text!
                
                let extras = [self.level, LevelMenu.player1, LevelMenu.player2] as [Any]
                
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
//            Board.player1 = extras[1] as! String
//            Board.player2 = extras[2] as! String
//            if (LevelMenu.multiplayer) {
//                Board.player1ID = Int64(extras[3] as! String)!
//                Board.player2ID = Int64(extras[4] as! String)!
//            }
            Board.player1 = extras[1] as! Player
            Board.player2 = extras[2] as! Player
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
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me", parameters: ["fields" : "id, name"])) { httpResponse, result in
                    switch result {
                    case .success(let response):
                        let player1FullName = response.dictionaryValue?["name"] as! String
                        let player1FullNameArr = player1FullName.characters.split(separator: " ")
                        LevelMenu.player1.playerName = String(player1FullNameArr[0])
                        let player1IDString = response.dictionaryValue?["id"] as! String
                        LevelMenu.player1.playerFBID = Int64(player1IDString)!
                        let connection2 = GraphRequestConnection()
                        connection2.add(GraphRequest(graphPath: "/?id=\(recipients[0])", parameters: ["fields" : "id, name"])) { httpResponse, result in
                            switch result {
                            case .success(let response):
                                let player2FullName = response.dictionaryValue?["name"] as! String
                                let player2FullNameArr = player2FullName.characters.split(separator: " ")
                                LevelMenu.player2.playerName = String(player2FullNameArr[0])
                                LevelMenu.player2.playerFBID = Int64(response.dictionaryValue?["id"] as! String)!
                                let extras = [self.level, LevelMenu.player1, LevelMenu.player2] as [Any]
                                self.performSegue(withIdentifier: "ToGame", sender: extras)
                            case .failed(let error):
                                print("Error! \(error)")
                            }
                        }
                        connection2.start()
                    case .failed(let error):
                        print("Error! \(error)")
                    }
                }
                connection.start()
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
    
    //MARK: FBSDKAppInviteDialogDelegate
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        let resultObject = NSDictionary(dictionary: results)
        
        for key in resultObject {
            print(key)
        }
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Error took place in appInviteDialog \(error)")
    }
}
