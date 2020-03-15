//
//  FacebookFriend.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2018-06-09.
//  Copyright © 2018 Varun Batta. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FacebookFriend: UITableViewCell {

    @IBOutlet var profilePictureView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    class func instanceFromNib() -> FacebookFriend {
        return UINib(nibName: "FacebookFriend", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FacebookFriend
    }
    
    func setProfile(pictureID: Int64, name: String) {
//        profilePictureView = FBProfilePictureView()
//        profilePictureView.profileID = String(pictureID)
//        profilePictureView.setNeedsImageUpdate()
        let url = NSURL(string: "https://graph.facebook.com/\(pictureID)/picture?width=48&height=48");
        let data = NSData(contentsOf: url! as URL) //make sure your image in this url does exist, otherwise unwrap in a if let check
        profilePictureView.image = UIImage(data: data! as Data)
        
        nameLabel.text = name
    }

}
