//
//  Game.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-11-03.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FacebookCore

class Game: NSObject {
    var player1 : Player
    var player2 : Player
    var data : [[String]]
    var lastMove : String
    var lastMoveRow : Int
    var lastMoveColumn : Int
    var level : Int
    var requestID : Int64
    
    override init() {
        self.player1 = Player()
        self.player2 = Player()
        self.data = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        self.lastMove = ""
        self.lastMoveRow = -1
        self.lastMoveColumn = -1
        self.level = 0
        self.requestID = 0
    }
    
    func initWithGameRequest(request: GraphResponse) {
        let data = request.dictionaryValue?["data"] as! String
        initData(data: data)
        if (self.data[9][0] != "") {
            self.lastMoveRow = Int(self.data[9][0])!
        }
        if (self.data[9][1] != "") {
            self.lastMoveColumn = Int(self.data[9][1])!
        }
        if (self.data[9][2] != "") {
            self.lastMove = self.data[9][2]
        }
        if (self.data[9][3] != "") {
            self.level = Int(self.data[9][3])!
        }
        self.requestID = Int64(request.dictionaryValue?["id"] as! String)!
        
        let from = request.dictionaryValue?["from"] as! [String:String]
        let to = request.dictionaryValue?["to"] as! [String:String]
        if (self.lastMove == "X") {
            self.player1.initWithPlayerData(playerData: from, turn: "X")
            self.player2.initWithPlayerData(playerData: to, turn: "O")
        } else {
            self.player1.initWithPlayerData(playerData: to, turn: "X")
            self.player2.initWithPlayerData(playerData: from, turn: "O")
        }
    }
    
    func initWithSavedGame(savedGameData: String, savedGameName: String) {
        initData(data: savedGameData)
        if (self.data[9][0] != "") {
            self.lastMoveRow = Int(self.data[9][0])!
        }
        if (self.data[9][1] != "") {
            self.lastMoveColumn = Int(self.data[9][1])!
        }
        if (self.data[9][2] != "") {
            self.lastMove = self.data[9][2]
        }
        if (self.data[9][3] != "") {
            self.level = Int(self.data[9][3])!
        }
        
        self.player1.initForSavedGameName(playerName: String(savedGameName.split(separator: " ")[0]), turn: "X")
        self.player2.initForSavedGameName(playerName: String(savedGameName.split(separator: " ")[2]), turn: "O")
    }
    
    func initData(data: String) {
        var row = 0
        var column = 0
        for i in data.characters.indices {
            let char = data[i]
            if (char == ";") {
                row += 1
                column = 0
            } else if (char == ",") {
                column += 1
            } else {
                self.data[row][column] = String(char)
            }
        }
    }
}
