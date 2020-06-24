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
    var isPlayerAI : Bool
    var turn : String
    
    override init() {
        self.playerName = ""
        self.playerFBID = -1
        self.isPlayerAI = false
        self.turn = ""
    }
    
    func initPlayer(playerName: String, turn: String) {
        self.playerName = playerName
        self.turn = turn
    }
    
    func initAI(turn: String) {
        self.playerName = "AI"
        self.turn = turn
        self.isPlayerAI = true
    }
    
    func initWithPlayerData(playerData: [String:String], turn: String) {
        self.playerName = playerData["name"]!
        let playerID = playerData["id"]!
        self.playerFBID = Int64(playerID)!
        self.turn = turn
    }
}
