//
//  CurrentGames.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-11-05.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FacebookCore
import FacebookShare
import FBSDKCoreKit
import FBSDKShareKit

class CurrentGames: ButtonBarPagerTabStripViewController, SavedLocalGamesDelegate, CurrentFacebookGamesDelegate, GameRequestDialogDelegate {
    
    var forfeitedGameRequestID : Int64!
    var savedLocalGames : SavedLocalGames!
    var currentFacebookGames : CurrentFacebookGames!
    
    override func viewDidLoad() {
        // Change selected bar color
        // TODO: Is all this UI logic required here?
        settings.style.buttonBarBackgroundColor = Style.mainColorDarkGreen
        settings.style.buttonBarItemBackgroundColor = Style.mainColorDarkGreen
        settings.style.selectedBarBackgroundColor = Style.mainColorWhite
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = Style.mainColorBlack
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.isHidden = false
            oldCell?.label.textColor = Style.mainColorBlack
            oldCell?.imageView.isHidden = true
            oldCell?.imageView.image = oldCell?.imageView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            oldCell?.imageView.tintColor = Style.mainColorBlack

            newCell?.label.isHidden = true
            newCell?.label.textColor = Style.mainColorWhite
            newCell?.imageView.isHidden = false
            newCell?.imageView.image = newCell?.imageView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            newCell?.imageView.tintColor = Style.mainColorWhite
        }
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Added this just to make sure the button bar cell width is correct
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/2, height: self.buttonBarView.frame.height)
    }
    
    // Added this to make sure the view looks correct
    // CANNOT call super.viewWillAppear as that ruins this for some reason
    override func viewWillAppear(_ animated: Bool) {
        self.reloadPagerTabStripView()
    }
    
    // Define the view controllers for the pagerTabStripController
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        currentFacebookGames = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currentFacebookGames") as! CurrentFacebookGames)
        savedLocalGames = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "savedLocalGames") as! SavedLocalGames)
        savedLocalGames.delegate = self
        currentFacebookGames.delegate = self
        return [savedLocalGames, currentFacebookGames]
    }
    
    // MARK: Prompt and associated actions
    
    func promptForSelectedGame(game: Game, isMultiplayer: Bool) {
        let prompt = UIAlertController(title: "What would you like to do?", message: "Please choose an action for the chosen game", preferredStyle: .alert)
        
        let playAction = UIAlertAction(title: "Play", style: .default) { (action) in
            self.playGame(game: game, isMultiplayer: isMultiplayer)
        }
        prompt.addAction(playAction)
        
        let viewAction = UIAlertAction(title: "View", style: .default) { (action) in
            self.viewGame(game: game)
        }
        prompt.addAction(viewAction)
        
        let forfeitAction = UIAlertAction(title: isMultiplayer ? "Forfeit" : "Delete", style: .destructive) { (action) in
            self.forfeitGame(game: game, isMultiplayer: isMultiplayer)
        }
        prompt.addAction(forfeitAction)
        
        self.present(prompt, animated: true, completion: nil)
    }
    
    func playGame(game: Game, isMultiplayer: Bool) {
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
        Board.isMultiplayer = isMultiplayer
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let board : Board = mainStoryboard.instantiateViewController(withIdentifier: "Board") as! Board
        board.level = game.level
        self.present(board, animated: true, completion: nil)
    }
    
    func viewGame(game: Game) {
        // TODO: Allow for just viewing of game
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
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let board : Board = mainStoryboard.instantiateViewController(withIdentifier: "Board") as! Board
        board.level = game.level
        self.present(board, animated: true, completion: nil)
    }
    
    func forfeitGame(game: Game, isMultiplayer: Bool) {
        // Figure out which player is forfeiting
        // TODO: See if there's an easier or better way to figure out this logic
        var toPlayer : Player = Player()
        var fromPlayer : Player = Player()
        if game.lastMove == "X" {
            toPlayer = game.player1
            fromPlayer = game.player2
        } else {
            toPlayer = game.player2
            fromPlayer = game.player1
        }
        
        if isMultiplayer {
            // Set forfeited game
            self.forfeitedGameRequestID = game.requestID
            
            // Set forfeit message and game accordingly
            let messageText = "\(fromPlayer.playerName) has forfeit the game. You win!"
            let gameString = Game.createGameString()
            
            // Create game request content for the forfeit call
            let gameRequestContent = GameRequestContent()
            gameRequestContent.recipients = [String(toPlayer.playerFBID)]
            gameRequestContent.message = messageText
            gameRequestContent.data = gameString
            gameRequestContent.title = "Forfeit"
            gameRequestContent.actionType = GameRequestActionType.none
            
            GameRequestDialog.init(content: gameRequestContent, delegate: self).show()
        }
        // TODO: Handle deleting local game
    }
    
    // MARK: Game Request Dialog Delegate
    
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
        connection.add(GraphRequest(graphPath: "/\(String(describing: self.forfeitedGameRequestID))", httpMethod: .delete)) {connection, result, error in
            if (result != nil) {
                print("\(String(describing: result))")
            } else {
                print("\(String(describing: error))")
            }
        }
        connection.start()
    }
}
