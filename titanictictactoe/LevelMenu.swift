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
import FBSDKCoreKit
import FBSDKLoginKit
import GameKit

// DEPRECATED!!!

class LevelMenu: UIViewController, GameRequestDialogDelegate {
    static var multiplayer = false
    var caller = ""
    var instructions = false
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
            let loginButton = FBLoginButton(permissions: [ .publicProfile, .userFriends ])
            
            // Constraints for loginButton
            loginButton.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.8, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: -20)
            let centerXConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0)
            
            titleLabel.text = "WiFi Game"
            savedGamesButton.setTitle("Current Games", for: .normal)
            savedGamesButton.addTarget(self, action: #selector(self.getCurrentGames), for: UIControl.Event.touchUpInside)
            self.view.addSubview(loginButton)
            
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
    
    @objc func getCurrentGames() {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me/apprequests", parameters: ["fields" : "data, paging" ])) { connection, result, error in
            if (result != nil) {
                let response = result as! [String: Any]
                print("\(response)")
                let currentGamesRequests = response["data"] as! [[String: String]]
                var currentGames : [Game] = [Game](repeating: Game(), count: currentGamesRequests.count)
                let myGroup = DispatchGroup()
                let concurrentQueue = DispatchQueue(label: "com.varunbatta.currentGamesWorker")
                for i in 0..<currentGamesRequests.count {
                    concurrentQueue.async(group: myGroup) {
                        if (currentGamesRequests[i]["data"] != nil) {
                            myGroup.enter()
                            let connection = GraphRequestConnection()
                            let requestID = currentGamesRequests[i]["id"]
                            let graphPath = requestID?.components(separatedBy: "_")[0]
                            connection.add(GraphRequest(graphPath: graphPath!, parameters: ["fields" : "id, action_type, application, created_time, data, from, message, object, to"])) { connection, result, error in
                                if (result != nil) {
                                    let response = result as! [String: Any]
                                    print("\(response)")
                                    if ((response["message"] as! String).lowercased().contains("forfeit")) {
                                        self.deleteGameRequest(request_id: graphPath!)
                                    } else {
                                        let currentGame : Game = currentGames[i]
                                        currentGame.initWithGameRequest(request: response)
                                        currentGames[i] = currentGame
                                    }
                                } else {
                                    print("\(String(describing: error))")
                                }
                                myGroup.leave()
                            }
                            connection.start()
                        } else {
                            self.deleteGameRequest(request_id: currentGamesRequests[i]["id"]!)
                        }
                    }
                }
                myGroup.notify(queue: DispatchQueue.main) {
//                    let currentGamesReady : Notification = Notification(name: Notification.Name(rawValue: "currentGamesReady"), object: currentGames)
//                    NotificationCenter.default.post(currentGamesReady)
                    let extras = [currentGames]
                    self.performSegue(withIdentifier: "toCurrentGames", sender: extras)
                }
            } else {
                print("\(String(describing: error))")
            }
        }
        connection.start()
    }
    
    func deleteGameRequest(request_id: String) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/\(request_id)", httpMethod: .delete)) {connection, result, error in
            if (result != nil) {
                print("\(String(describing: result))")
            } else {
                print("\(String(describing: error))")
            }
        }
        connection.start()
    }
    
    @IBAction func levelSelect(_ sender: UIButton) {
        BasicBoard.currentTurn = "X"
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        switch sender.tag {
        case 303:
            self.level = 1
            
            if !LevelMenu.multiplayer {
                let alert = UIAlertController(title: "Player Names", message: "Please Enter the Player Names:", preferredStyle: UIAlertController.Style.alert)
            
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
                if ((AccessToken.current) != nil) {
                    let gameRequest = GameRequestContent()
                    gameRequest.message = "New Match"
                    gameRequest.actionType = .turn
                    gameRequest.filters = .appUsers
                    GameRequestDialog.init(content: gameRequest, delegate: self).show()
                } else {
                    let warning = UIAlertController(title: "Not Connected", message: "You must login to Facebook before you can play a game over WiFi", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    warning.addAction(defaultAction)
                    self.present(warning, animated: true, completion: nil)
                }
            }
            
            break
        case 304:
            self.level = 2
            
            if !LevelMenu.multiplayer {
                let alert = UIAlertController(title: "Player Names", message: "Please Enter the Player Names:", preferredStyle: UIAlertController.Style.alert)
                
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
                if ((AccessToken.current) != nil) {
                    let gameRequest = GameRequestContent()
                    gameRequest.message = "New Match"
                    gameRequest.actionType = .turn
                    gameRequest.filters = .appUsers
                    GameRequestDialog.init(content: gameRequest, delegate: self).show()
                } else {
                    let warning = UIAlertController(title: "Not Connected", message: "You must login to Facebook before you can play a game over WiFi", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    warning.addAction(defaultAction)
                    self.present(warning, animated: true, completion: nil)
                }
            }
            
            break
        case 305:
            let warning = UIAlertController(title: "Sorry!", message: "The level you have selected is currently unavailable", preferredStyle: .alert)
            warning.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                warning.dismiss(animated: true, completion: nil)
            }))
            
            self.present(warning, animated: true, completion: nil)
            break
        case 306:
            let warning = UIAlertController(title: "Sorry!", message: "The level you have selected is currently unavailable", preferredStyle: .alert)
            warning.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                warning.dismiss(animated: true, completion: nil)
            }))
            
            self.present(warning, animated: true, completion: nil)
            break
        case 307:
            if (!LevelMenu.multiplayer) {
                self.performSegue(withIdentifier: "toSavedGames", sender: nil)
            }
        case 308:
            self.dismiss(animated: true, completion: nil)
            break
        default:
            return
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ToGame" {
//            let board = segue.destination as! Board
////            let levelSelect = sender as! Int
////            board.level = levelSelect
//            let extras = sender as! [Any]
//            board.level = extras[0] as! Int
////            Board.player1 = extras[1] as! String
////            Board.player2 = extras[2] as! String
////            if (LevelMenu.multiplayer) {
////                Board.player1ID = Int64(extras[3] as! String)!
////                Board.player2ID = Int64(extras[4] as! String)!
////            }
//            Board.player1 = extras[1] as! Player
//            Board.player2 = extras[2] as! Player
//            board.levelMenu = self
//            board.mainMenu = self.mainMenu
//        } else if segue.identifier == "toCurrentGames" {
//            let currentGames = segue.destination as! CurrentGames
//            let extras = sender as! [Any]
//            currentGames.currentGames = extras[0] as! [Game]
//        }
//        // Pass the selected object to the new view controller.
//    }
    
    //MARK: FBSDKGameRequestDialogDelegate
    
    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didCompleteWithResults results: [String : Any]) {
        if results["to"] == nil {
            let alert = UIAlertController(title: "No friends selected!", message: "You haven't selected any friends to play against. Please select just ONE friend.", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let recipients = results["to"] as! NSArray
            if recipients.count > 1 {
                let alert = UIAlertController(title: "Too many friends selected!", message: "You have selected too many friends to play against. Please select just ONE friend.", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me", parameters: ["fields" : "id, name"])) { connection, result, error in
                    if (result != nil) {
                        let response = result as? [String: Any]
                        let player1FullName = response?["name"] as! String
                        let player1FullNameArr = player1FullName.split(separator: " ")
                        LevelMenu.player1.playerName = String(player1FullNameArr[0])
                        let player1IDString = response?["id"] as! String
                        LevelMenu.player1.playerFBID = Int64(player1IDString)!
                        let connection2 = GraphRequestConnection()
                        connection2.add(GraphRequest(graphPath: "/?id=\(recipients[0])", parameters: ["fields" : "id, name"])) { connection2, result, error in
                            if (result != nil) {
                                let response = result as? [String: Any]
                                let player2FullName = response?["name"] as! String
                                let player2FullNameArr = player2FullName.split(separator: " ")
                                LevelMenu.player2.playerName = String(player2FullNameArr[0])
                                LevelMenu.player2.playerFBID = Int64(response?["id"] as! String)!
                                let extras = [self.level, LevelMenu.player1, LevelMenu.player2] as [Any]
                                self.performSegue(withIdentifier: "ToGame", sender: extras)
                            } else {
                                print("Error! \(String(describing: error))")
                            }
                        }
                        connection2.start()
                    } else {
                        print("Error! \(String(describing: error))")
                    }
                }
                connection.start()
                print("Good!")
            }
        }
    }
    
    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didFailWithError error: Error) {
        print("didFailWithError", error)
    }

    func gameRequestDialogDidCancel(_ gameRequestDialog: GameRequestDialog) {
        print("didCancel")
    }
}
