//
//  CurrentFacebookGames.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2020-Mar-26.
//  Copyright © 2020 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FBSDKLoginKit


protocol CurrentFacebookGamesDelegate: AnyObject {
    func promptForSelectedGame(game: Game, isMultiplayer: Bool)
}


class CurrentFacebookGames: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    @IBOutlet var currentFacebookGamesTableView: UITableView!
    
    weak var delegate: CurrentFacebookGamesDelegate?
    
    var currentGames : [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global().async {
            let dispatchGroup = DispatchGroup()
            
            // Sign in to Facebook if not already signed in
            if (AccessToken.current == nil) {
                LoginManager().logIn(permissions: ["public_profile", "email", "user_friends"])
            }
            
            // Get all current game IDs to request game data
            dispatchGroup.enter()
            let currentGamesRequestIDsRequest : GraphRequest = GraphRequest.init(graphPath: "me/apprequests", parameters: ["fields": "data,paging"])
            var currentGamesRequestsIDs : [Int64] = []
            let connection = GraphRequestConnection()
            connection.add(currentGamesRequestIDsRequest, completionHandler: {_, response, error in
                if error != nil {
                    NSLog(error.debugDescription)
                    return
                }
                
                if let response = response as? [String:Any] {
                    for currentGameData in response["data"] as! [[String:String]] {
                        let gameData = currentGameData["data"]
                        if gameData != nil {
                            currentGamesRequestsIDs.append(Int64(currentGameData["id"]!.components(separatedBy: "_")[0])!)
                        }
                    }
                }
                dispatchGroup.leave()
            })
            connection.start()
            dispatchGroup.wait()
            
            // Get current games data
            for requestID in currentGamesRequestsIDs {
                dispatchGroup.enter()
                let connection2 = GraphRequestConnection()
                let currentGameDataRequest = GraphRequest.init(graphPath: "/" + String(requestID), parameters: ["fields": "id,action_type,application,created_time,data,from,message,object,to"])
                connection2.add(currentGameDataRequest, completionHandler: {_, response, error in
                    if error != nil {
                        NSLog(error.debugDescription)
                        return
                    }
                    
                    if let response = response as? [String:Any] {
                        let responseMessage = response["message"] as! String
                        if !(responseMessage == "New Match" || responseMessage.contains("forfeit")) {
                            // Game data cannot be a new match (meaning the current match is finished and they want to start a new one) or forfeit to be valid
                            let game : Game = Game()
                            game.initWithGameRequest(request: response)

                            let opponent : Player = Player();
                            opponent.initWithPlayerData(playerData: response["from"] as! [String:String], turn: game.lastMove == "X" ? "X" : "O")
                            
                            let me : Player = Player();
                            me.initWithPlayerData(playerData: response["to"] as! [String:String], turn: game.lastMove == "X" ? "O" : "X")

                            if game.lastMove == "X" {
                                game.player1 = opponent;
                                game.player2 = me;
                            } else {
                                game.player1 = me;
                                game.player2 = opponent;
                            }
                            
                            self.currentGames.append(game)
                            
                            // Remove the requestIDs that are taken care of
                            currentGamesRequestsIDs.remove(at: currentGamesRequestsIDs.firstIndex(of: requestID)!)
                        }
                    }
                    
                    dispatchGroup.leave()
                })
                connection2.start()
                dispatchGroup.wait()
            }
            
            // Delete the remaining request IDs
            for requestID in currentGamesRequestsIDs {
                dispatchGroup.enter()
                let connection3 = GraphRequestConnection()
                let deleteCurrentGameRequest = GraphRequest.init(graphPath: "/" + String(requestID), httpMethod: HTTPMethod.delete)
                connection3.add(deleteCurrentGameRequest, completionHandler: {_, response, error in
                    if error != nil {
                        NSLog(error.debugDescription)
                        return
                    }
                })
            }
            
            DispatchQueue.main.async {
                // Finally, display the active current games
                self.currentFacebookGamesTableView.dataSource = self
                self.currentFacebookGamesTableView.delegate = self
                self.currentFacebookGamesTableView.reloadData()
            }
        }
        
        // TODO: Update view as necessary on refresh
    }
    
    // MARK: Indicator Info Provider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Facebook Games", image: UIImage(named: "Facebook F-logo"))
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get current facebook game and create cell
        let facebookGame = self.currentGames[indexPath.row]
        let cell = FacebookGame.instanceFromNib()
        cell.setFacebookGame(facebookGame: facebookGame)
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Get selected facebook game and prompt accordingly
        let facebookGame = self.currentGames[indexPath.row]
        self.delegate?.promptForSelectedGame(game: facebookGame, isMultiplayer: true)
    }
}
