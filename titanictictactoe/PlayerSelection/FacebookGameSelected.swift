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
    func beginGame(player1: Player, player2: Player, isMultiplayer: Bool)
}

class FacebookGameSelected: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider, LoginButtonDelegate {
    
    weak var delegate: FacebookGameSelectedDelegate?
    
    @IBOutlet var inviteFriendsLabel: UILabel!
    @IBOutlet var friendsTableView: UITableView!
    @IBOutlet var fbLoginButtonView: UIView!
    
    var player1 : Player = Player()
    var player2 : Player = Player()
    var friends : [Player] = []
    
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
                
                if let response = response as? [String:String] {
                    self.player1.initWithPlayerData(playerData: response, turn: "X")
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
                    for friendData in response["data"] as! [[String:String]] {
                        let friend = Player()
                        friend.initWithPlayerData(playerData: friendData, turn: "O")
                        self.friends.append(friend)
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
                
                // Assign LoginButton Delegate
                let loginButton = FBLoginButton()
                self.fbLoginButtonView.addSubview(loginButton)
                loginButton.translatesAutoresizingMaskIntoConstraints = false
                loginButton.centerXAnchor.constraint(equalTo: self.fbLoginButtonView.centerXAnchor).isActive = true
                loginButton.centerYAnchor.constraint(equalTo: self.fbLoginButtonView.centerYAnchor).isActive = true
                loginButton.delegate = self
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
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get friend information
        let facebookFriend = self.friends[indexPath.row]
        
        // Create a cell to hold the friend information
        let cell = FacebookFriend.instanceFromNib()
        cell.setFacebookFriendProfile(facebookFriend: facebookFriend)
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get player2 information from selected row
        let selectedPlayerCell = tableView.cellForRow(at: indexPath) as! FacebookFriend
        let player2 = selectedPlayerCell.facebookFriend!
        
        self.delegate!.beginGame(player1: player1, player2: player2, isMultiplayer: true)
    }
    
    // MARK: FBLoginButtonDelegate
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            NSLog(error.debugDescription)
            return
        }
        else if result!.isCancelled {
            // TODO: Report Error if Login Issues
        }
        else {
            // TODO: Add friends to the tableview
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //  TODO: Handle Logout
    }
}
