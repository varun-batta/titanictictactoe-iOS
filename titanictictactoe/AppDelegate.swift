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
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKCoreKit.ApplicationDelegate.shared.application(app, open: url, options: options)
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
        AppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // TODO: Move this to a separate set of Facebook API Call functions
    func getListOfOpponents(request_ids_list : [String]) {
        var gamesCount = request_ids_list.count
        var start = 0
        if (request_ids_list.contains("user_friends")) {
            gamesCount -= 1
            start += 1
        }
        if (request_ids_list.contains("public_profile")) {
            gamesCount -= 1
            start += 1
        }
        var games = [Game](repeating: Game(), count: gamesCount)
        let myGroup = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "com.varunbatta.opponentNamesWorker")
        for i in start..<request_ids_list.count {
            concurrentQueue.async(group: myGroup) {
                myGroup.enter()
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/\(request_ids_list[i])", parameters: ["fields" : "id, action_type, application, created_time, data, from, message, object, to"])) { connection, result, error in
                    if (result != nil) {
                        let response = result as! [String: Any]
                        if (response["data"] != nil) {
                            let game : Game = Game()
                            game.initWithGameRequest(request: response)
                            games[i] = game
                        } else {
                            AppDelegate.deleteGameRequest(request_id: request_ids_list[i])
                        }
                        if ((response["message"] as! String).lowercased().contains("forfeit")) {
                            AppDelegate.deleteGameRequest(request_id: request_ids_list[i])
                        }
                    } else {
                        print("Error! \(String(describing: error))")
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
    
    // TODO: Move this to one global file for all API calls & better document what it is for!!
    static func deleteGameRequest(request_id: String) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/\(request_id)", httpMethod: .delete)) {connection, result, error in
            if (result != nil) {
                print("\(String(describing: result))")
            } else {
                print("\(String(describing: error))")
            }
        }
        connection.start()
    }
}

