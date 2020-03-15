//
//  FacebookGameSelected.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2018-06-09.
//  Copyright © 2018 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FBSDKLoginKit

protocol FacebookGameSelectedDelegate: AnyObject {
    func beginGame(player1: Player, player2: Player)
}

class FacebookGameSelected: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    weak var delegate: FacebookGameSelectedDelegate?
    
    @IBOutlet var inviteFriendsLabel: UILabel!
    @IBOutlet var friendsTableView: UITableView!
    
    var player1 : Player = Player()
    var player2 : Player = Player()
    var friendsFBIDs : [Int64] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global().async {
            let dispatchGroup = DispatchGroup()
            
            // Sign in to Facebook if not already signed in
            if (AccessToken.current == nil) {
                LoginManager().logIn(permissions: ["public_profile", "email", "user_friends"])
            }
            
            dispatchGroup.enter()
            // Get current player ID and name
            let player1Request : GraphRequest = GraphRequest.init(graphPath: "me", parameters: ["fields": "id,name"])
            let connection = GraphRequestConnection()
            connection.add(player1Request, completionHandler: {_, response, error in
                if error != nil {
                    NSLog(error.debugDescription)
                    return
                }
                
                if let response = response as? [String:Any] {
                    self.player1.playerName = response["name"] as! String
                    self.player1.playerFBID = Int64(response["id"] as! String)!
                }
                dispatchGroup.leave()
            })
            connection.start()
            dispatchGroup.wait()
            
            dispatchGroup.enter()
            // Get friends
            let connection2 = GraphRequestConnection()
            let player1FriendsRequest = GraphRequest.init(graphPath: String(self.player1.playerFBID) + "/friends", parameters: ["fields": "id,name"])
            connection2.add(player1FriendsRequest, completionHandler: {_, response, error in
                if error != nil {
                    NSLog(error.debugDescription)
                    return
                }
                
                if let response = response as? [String:Any] {
                    for friend in response["data"] as! [[String:Any]] {
                        self.friendsFBIDs.append(Int64(friend["id"] as! String)!)
                    }
                }
                dispatchGroup.leave()
            })
            connection2.start()
            dispatchGroup.wait()
            
            DispatchQueue.main.async {
                // Finally, display all friends for selection using table view data source
                self.friendsTableView.dataSource = self
                self.friendsTableView.delegate = self
                self.friendsTableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Play over Facebook", image: UIImage(named: "Facebook F-logo"))
    }
    
    // MARK: FriendListTableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsFBIDs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get friend information
        let friendFBID = self.friendsFBIDs[indexPath.row]
        let player2Request = GraphRequest.init(graphPath: "/?id=" + String(friendFBID), parameters: ["fields": "id,name"])
        
        // Create an empty cell to hold the friend information
        let cell = FacebookFriend.instanceFromNib()
        
        // Populate cell with data from player2Request
        let connection = GraphRequestConnection()
        connection.add(player2Request, completionHandler: {_, response, error in
            if error != nil {
                NSLog(error.debugDescription)
                return
            }
            
            if let response = response as? [String:Any] {
                cell.setProfile(pictureID: Int64(response["id"] as! String)!, name: response["name"] as! String)
            }
            return
        })
        connection.start()
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get player2 information from selected row
        let selectedPlayerCell = tableView.cellForRow(at: indexPath) as! FacebookFriend
        let player2Name = selectedPlayerCell.nameLabel.text!
        
        // Start game based on selection
        player1.initForLocalGame(playerName: player1.playerName, turn: "X")
        player2.initForLocalGame(playerName: player2Name, turn: "O")
        
        self.delegate!.beginGame(player1: player1, player2: player2)
    }

}
