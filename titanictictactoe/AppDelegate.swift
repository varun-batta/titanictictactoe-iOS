//
//  AppDelegate.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-09.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

import FacebookCore
import FacebookShare
import FBSDKShareKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])

        let urlString = url.absoluteString.removingPercentEncoding!
        let targetURL = urlString.components(separatedBy: "#")[1]
        let request_ids_with_key = targetURL.components(separatedBy: "&")[1]
        let request_ids = request_ids_with_key.components(separatedBy: "=")[1]
        let request_ids_list = (request_ids.replacingOccurrences(of: "%2C", with: ",")).components(separatedBy: ",")
        
        if (request_ids_list.count > 0) {
            self.getListOfOpponents(request_ids_list: request_ids_list)
        }
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let start = main.instantiateInitialViewController()
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = start
        self.window?.makeKeyAndVisible()
        
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getListOfOpponents(request_ids_list : [String]) {
//        var opponentNames = [String](repeating: "", count: request_ids_list.count)
//        let accessToken = FBSDKAccessToken.current().tokenString
        var games = [Game](repeating: Game(), count: request_ids_list.count)
        let myGroup = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "com.varunbatta.opponentNamesWorker")
        for i in 0...request_ids_list.count - 1 {
            concurrentQueue.async(group: myGroup) {
                myGroup.enter()
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/\(request_ids_list[i])", parameters: ["fields" : "id, action_type, application, created_time, data, from, message, object, to"])) { httpResponse, result in
                    switch(result) {
                    case .success(let response):
                        print("\(response)")
                        if (response.dictionaryValue!["data"] != nil) {
                            let game : Game = Game()
                            game.initWithGameRequest(request: response)
                            games[i] = game
//                            let from : [String: String] = response.dictionaryValue?["from"] as! [String: String]
//                            let name = from["name"]
//                            opponentNames[i] = name!
                        } else {
                            self.deleteGameRequest(request_id: request_ids_list[i])
                        }
//                        print("\(name)")
                    case .failed(let error):
                        print("Error! \(error)")
                    }
                    myGroup.leave()
                }
                connection.start()
            }
        }
        myGroup.notify(queue: DispatchQueue.main) {
            let gamesReady : Notification = Notification(name: Notification.Name(rawValue: "gamesReady"), object: games)
            NotificationCenter.default.post(gamesReady)
        }
    }
    
    func deleteGameRequest(request_id: String) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/\(request_id)", httpMethod: .DELETE)) {httpResponse, result in
            switch(result) {
            case .success(let response):
                print("\(response)")
            case .failed(let error):
                print("\(error)")
            }
        }
        connection.start()
    }
}

