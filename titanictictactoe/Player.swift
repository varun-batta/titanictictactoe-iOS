//
//  Player.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-11-03.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

class Player: NSObject {
    var playerName : String
    var playerFBID : Int64
    var turn : String
    
    override init() {
        self.playerName = ""
        self.playerFBID = -1
        self.turn = ""
    }
    
    func initForLocalGame(playerName: String, turn: String) {
        self.playerName = playerName
        self.turn = turn
    }
    
    func initForSavedGameName(playerName: String, turn: String) {
        self.playerName = playerName
        self.turn = turn
    }
    
    func initWithPlayerData(playerData: [String:String], turn: String) {
        self.playerName = playerData["name"]!
        let playerID = playerData["id"]!
        self.playerFBID = Int64(playerID)!
        self.turn = turn
    }
}
