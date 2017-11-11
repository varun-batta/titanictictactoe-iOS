//
//  CurrentGames.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-11-05.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

class CurrentGames: UIViewController {

    @IBOutlet var background: UIView!
    @IBOutlet var pleaseSelectGameLabel: UILabel!
    
    var currentGames : [Game] = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.background.backgroundColor = Style.mainColorGreen
        self.prepareCurrentGamesButtons()
//        NotificationCenter.default.addObserver(self, selector: #selector(prepareCurrentGamesButtons(notification:)), name: NSNotification.Name(rawValue: "currentGamesReady"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        self.fixButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func prepareCurrentGamesButtons() {
        for i in 0..<self.currentGames.count {
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
            button.addTarget(self, action: #selector(beginGame), for: UIControlEvents.touchUpInside)
            self.background.addSubview(button)
        }
        let button = UIButton()
        let buttonText = "Level Menu"
        button.setTitle(buttonText, for: .normal)
        button.setTitleColor(Style.mainColorWhite, for: .normal)
        button.backgroundColor = Style.mainColorBlack
        button.addTarget(self, action: #selector(dismissView), for: UIControlEvents.touchUpInside)
        self.background.addSubview(button)
    }
    
    func beginGame(sender: UIButton) {
        let game = self.currentGames[sender.tag]
        BasicBoard.wincheck = game.data
        if (game.lastMove == "X") {
            BasicBoard.currentTurn = "O"
        } else {
            BasicBoard.currentTurn = "X"
        }
        Board.player1 = game.player1
        Board.player2 = game.player2
        LevelMenu.multiplayer = true
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let board : Board = mainStoryboard.instantiateViewController(withIdentifier: "Board") as! Board
        board.level = game.level
        self.present(board, animated: true, completion: nil)
    }
    
    func dismissView(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fixButtons() {
        let subviews : [UIView] = self.background.subviews
        var y = pleaseSelectGameLabel.frame.origin.y + pleaseSelectGameLabel.frame.height + 10
        let width = self.background.frame.size.width*0.9
        for subview : UIView in subviews {
            if (subview.isKind(of: UIButton.self)) {
                let button : UIButton = subview as! UIButton
                button.frame = CGRect(x: 41.0, y: y, width: width, height: 34.0)
                y += 44
            }
        }
    }
}
