//
//  CurrentGames.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-11-05.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import FBSDKCoreKit
import FBSDKShareKit
import GameKit

class CurrentGames: UIViewController, GameRequestDialogDelegate {
    
    @IBOutlet var background: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pleaseSelectGameLabel: UILabel!
    
    var currentGames : [Game] = [Game]()
    var savedGames : [Game] = [Game]()
    var chosenGameRequestID : Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (LevelMenu.multiplayer) {
            titleLabel.text = "Current Games"
        } else {
            titleLabel.text = "Saved Games"
        }
        
        // UI
        self.background.backgroundColor = Style.mainColorGreen
        self.titleLabel.textColor = Style.mainColorBlack
        self.pleaseSelectGameLabel.textColor = Style.mainColorBlack
        
        if (LevelMenu.multiplayer) {
            self.prepareCurrentGamesButtons()
        } else {
            self.prepareSavedGamesButtons()
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(prepareCurrentGamesButtons(notification:)), name: NSNotification.Name(rawValue: "currentGamesReady"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        self.fixButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareSavedGamesButtons() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.fetchSavedGames() {(savedGames, error) -> Void in
            if (error != nil) {
                print("\(String(describing: error))")
            } else {
                let count = savedGames!.count
                for i in 0..<count {
                    let button = UIButton()
                    let savedGame : GKSavedGame = savedGames![i]
                    self.createGameFromData(savedGame: savedGame)
                    let buttonText = savedGame.name
                    button.setTitle(buttonText, for: .normal)
                    button.setTitleColor(Style.mainColorWhite, for: .normal)
                    button.backgroundColor = Style.mainColorBlack
                    button.tag = i
                    button.addTarget(self, action: #selector(self.promptForSavedGames), for: UIControl.Event.touchUpInside)
                    self.background.addSubview(button)
                }
            }
        }
        let button = UIButton()
        let buttonText = "Level Menu"
        button.setTitle(buttonText, for: .normal)
        button.setTitleColor(Style.mainColorWhite, for: .normal)
        button.backgroundColor = Style.mainColorBlack
        button.addTarget(self, action: #selector(dismissView), for: UIControl.Event.touchUpInside)
        self.background.addSubview(button)
    }
    
    func createGameFromData(savedGame : GKSavedGame) {
        savedGame.loadData() { (data, error) -> Void in
            if (error != nil) {
                print("\(String(describing: error))")
            } else {
                let gameString = String.init(data: data!, encoding: .utf8)
                let game = Game()
                game.initWithSavedGame(savedGameData: gameString!, savedGameName: savedGame.name!)
                self.savedGames.append(game)
            }
        }
    }
    
    @objc func promptForSavedGames(sender: UIButton) {
//        let prompt = UIAlertController(title: "What would you like to do?", message: "Please choose an action for the chosen game", preferredStyle: .alert)
//
//        let playAction = UIAlertAction(title: "Play", style: .default) { (action) in
//            self.beginGame(game: self.savedGames[sender.tag])
//        }
//        prompt.addAction(playAction)
//
//        let forfeitAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
//            self.forfeitGame(game: self.savedGames[sender.tag])
//        }
//        prompt.addAction(forfeitAction)
//        self.present(prompt, animated: true, completion: nil)
        self.beginGame(game: self.savedGames[sender.tag], multiplayer: false)
    }

    func prepareCurrentGamesButtons() {
        for i in 0..<self.currentGames.count {
            if (self.currentGames[i].lastMove != "") {
                let button = UIButton()
                var fromPlayer = Player()
                if (self.currentGames[i].lastMove == "X") {
                    fromPlayer = self.currentGames[i].player1
                } else if (self.currentGames[i].lastMove == "O"){
                    fromPlayer = self.currentGames[i].player2
                }
                let buttonText = "\(fromPlayer.playerName) - Level \(self.currentGames[i].level)"
                button.setTitle(buttonText, for: .normal)
                button.setTitleColor(Style.mainColorWhite, for: .normal)
                button.backgroundColor = Style.mainColorBlack
                button.tag = i
                button.addTarget(self, action: #selector(promptForCurrentGame), for: UIControl.Event.touchUpInside)
                self.background.addSubview(button)
            }
        }
        let button = UIButton()
        let buttonText = "Level Menu"
        button.setTitle(buttonText, for: .normal)
        button.setTitleColor(Style.mainColorWhite, for: .normal)
        button.backgroundColor = Style.mainColorBlack
        button.addTarget(self, action: #selector(dismissView), for: UIControl.Event.touchUpInside)
        self.background.addSubview(button)
    }
    
    @objc func promptForCurrentGame(sender: UIButton) {
        let prompt = UIAlertController(title: "What would you like to do?", message: "Please choose an action for the chosen game", preferredStyle: .alert)
        
        let playAction = UIAlertAction(title: "Play", style: .default) { (action) in
            self.beginGame(game: self.currentGames[sender.tag], multiplayer: true)
        }
        prompt.addAction(playAction)
        
        let forfeitAction = UIAlertAction(title: "Forfeit", style: .destructive) { (action) in
            self.forfeitGame(game: self.currentGames[sender.tag])
        }
        prompt.addAction(forfeitAction)
        self.present(prompt, animated: true, completion: nil)
    }
    
    func beginGame(game: Game, multiplayer: Bool) {
        BasicBoard.wincheck = game.data
        if (game.lastMove == "X") {
            BasicBoard.currentTurn = "O"
        } else {
            BasicBoard.currentTurn = "X"
        }
        BasicBoard.firstTurn = false
        Board.player1 = game.player1
        Board.player2 = game.player2
        Board.gameID  = game.requestID
        LevelMenu.multiplayer = multiplayer
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let board : Board = mainStoryboard.instantiateViewController(withIdentifier: "Board") as! Board
        board.level = game.level
        self.present(board, animated: true, completion: nil)
    }
    
    func forfeitGame(game: Game) {
        self.chosenGameRequestID = game.requestID;
        
        var toPlayer : Player = Player()
        var fromPlayer : Player = Player()
        if game.lastMove == "X" {
            toPlayer = game.player1
            fromPlayer = game.player2
        } else {
            toPlayer = game.player2
            fromPlayer = game.player1
        }
        let messageText = "\(fromPlayer.playerName) has forfeit the game. You win!"
        let gameString = self.createGameString()
        
        let gameRequestContent = GameRequestContent()
        gameRequestContent.recipients = [String(toPlayer.playerFBID)]
        gameRequestContent.message = messageText
        gameRequestContent.data = gameString
        gameRequestContent.title = "Forfeit"
        gameRequestContent.actionType = GameRequestActionType.none
        
        GameRequestDialog.init(content: gameRequestContent, delegate: self).show()
    }
    
    func gameRequestDialogDidCancel(_ gameRequestDialog: GameRequestDialog) {
        //Fall back as if no move was made
    }
    
    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didFailWithError error: Error) {
        print("Error! \(String(describing: error))")
        //Fall back as if no move was made
    }
    
    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didCompleteWithResults results: [String : Any]) {
        self.deleteGameRequest()
        print("Success! \(String(describing: results))")
    }
    
    func deleteGameRequest() {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/\(self.chosenGameRequestID)", httpMethod: .delete)) {connection, result, error in
            if (result != nil) {
                print("\(String(describing: result))")
            } else {
                print("\(String(describing: error))")
            }
        }
        connection.start()
    }
    
    func createGameString() -> String {
        var game = ""
        for i in 0..<10 {
            for j in 0..<9 {
                game += BasicBoard.wincheck[i][j] + ","
            }
            game += ";"
        }
        return game
    }
    
    @objc func dismissView(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fixButtons() {
        let subviews : [UIView] = self.background.subviews
        var y = pleaseSelectGameLabel.frame.origin.y + pleaseSelectGameLabel.frame.height + 10
        let width = self.background.frame.size.width*0.8
        for subview : UIView in subviews {
            if (subview.isKind(of: UIButton.self)) {
                let button : UIButton = subview as! UIButton
                button.frame = CGRect(x: (self.background.frame.size.width - width)/2, y: y, width: width, height: 34.0)
                y += 44
            }
        }
    }
}
