//
//  LocalGame.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2020-Mar-27.
//  Copyright © 2020 Varun Batta. All rights reserved.
//

import UIKit

class LocalGame: UITableViewCell {

    @IBOutlet var player1NameLabel: UILabel!
    @IBOutlet var player2NameLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    
    class func instanceFromNib() -> LocalGame {
        return UINib(nibName: "LocalGame", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LocalGame
    }
    
    func setLocalGame(localGame: Game) {
        // Set player 1 info
        player1NameLabel.text = "\(localGame.player1.playerName) (\(localGame.player1.turn))"
        
        // Set player 2 info
        player2NameLabel.text = "\(localGame.player2.playerName) (\(localGame.player2.turn))"
        
        // Set level label
        levelLabel.text = "Level \(localGame.level)"
    }
    
}
