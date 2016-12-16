//
//  AppDelegate.swift
//  Space Phish
//
//  Created by Gregory Howlett-Gomez on 8/23/16.
//  Copyright © 2016 Breakware. All rights reserved.
//

import UIKit
import GameKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {

    var window: UIWindow?
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        authenticateplayer()
        if let viewcontroller = application.keyWindow?.rootViewController as? GameViewController {
            viewcontroller.appdelegate = self
        }
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let viewcontroller = application.keyWindow?.rootViewController as? GameViewController {
            viewcontroller.scene!.view!.isPaused = true
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        if let viewcontroller = application.keyWindow?.rootViewController as? GameViewController {
            viewcontroller.scene!.view!.isPaused = false
            if viewcontroller.scene!.Gamestate == GameState.playing {
                viewcontroller.scene!.pausegame()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func authenticateplayer() {
        let player: GKLocalPlayer = GKLocalPlayer.localPlayer()
        let viewcontroller = window!.rootViewController
        
        player.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                viewcontroller!.present(ViewController!, animated: true, completion: nil)
            } else if (player.isAuthenticated) {
                self.gcEnabled = true
                
            } else {
                self.gcEnabled = false
            }
            
        }
        
    }
    
}




