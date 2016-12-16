//
//  GameViewController.swift
//  Space Phish
//
//  Created by Gregory Howlett-Gomez on 8/23/16.
//  Copyright (c) 2016 Breakware. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds
import StoreKit
import GameKit

class GameViewController: UIViewController, GADInterstitialDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, GKGameCenterControllerDelegate, UINavigationControllerDelegate  {
    
    var scene = GameScene(fileNamed: "GameScene")
    var appdelegate: AppDelegate!
    var interstitial: GADInterstitial!
    var failcounter = 0
    var productid: Array<String?> = []
    var productsarray: Array<SKProduct?> = []
    var transactioninprogress = false
    var didbuyads = false
    var score: Int64!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

            // Configure the view
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene!.scaleMode = .resizeFill
        
            /* Set the delegates */
            scene?.gamescenedelegate = self
            
            skView.presentScene(scene)
            print(didbuyads)
        
        if (SKPaymentQueue.canMakePayments()) {
           SKPaymentQueue.default().restoreCompletedTransactions()
        }
        print(didbuyads)

        SKPaymentQueue.default().add(self)
        
        if didbuyads == false {
            productid.append("SpacePhishAdFree0")
            requestProductInfo()
           createAndLoadInterstitial()
            print(didbuyads)
        }
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Sharing and resetting
    
    func sharingiscaring() {
        let setInitialText = "#SpacePhish"
        let sharingscreen = UIActivityViewController(activityItems: [scene!.screenshot,setInitialText], applicationActivities: [])
        self.present(sharingscreen, animated: true, completion: nil)
    }
    
    func resetgame() {
        if (self.interstitial.isReady) && (failcounter >= 3) && (didbuyads == false) {
            failcounter = 0
            self.interstitial.present(fromRootViewController: self)
            createAndLoadInterstitial()
            actualreset()
        } else {
            if failcounter == 3 {
                failcounter = 0
            } else {
                failcounter += 1
            }
            print(failcounter)
            print(didbuyads)
            actualreset()
        }
    }
    
    func actualreset() {
        let Scene = GameScene(fileNamed: "GameScene")
        
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        Scene!.scaleMode = .resizeFill
        
        /* Set the delegates */
        Scene?.gamescenedelegate = self
        
        scene = Scene
        
        skView.presentScene(scene)
    }
    
    func takescreenshot() {
        let window = UIApplication.shared.delegate!.window!!
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        scene?.screenshot = image
    }
    
    // MARK: Ads

    func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9300531541820203/2934045574")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = ["1e4a1cb65994c274fd67aeb52969e06d"]
        interstitial.load(request)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        createAndLoadInterstitial()
        actualreset()
    }
    
    // MARK: In App purchases
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifier = NSSet(array: productid)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifier as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsarray.append(product as SKProduct)
            }
            
        } else {
            print("There are no products")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print("THERE are invalid products")
        }
    }
    
    func showActions() {
        if transactioninprogress {
            return
        }
        
        let buyercontroller = UIAlertController(title: "Remove Ads?", message: "Pay $0.99 to Remove Ads", preferredStyle: UIAlertControllerStyle.actionSheet)
        let buyAction = UIAlertAction(title: "Buy", style: UIAlertActionStyle.default) { (action) -> Void in
            let payment = SKPayment(product: self.productsarray[0]! as SKProduct)
            SKPaymentQueue.default().add(payment)
            self.transactioninprogress = true
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        buyercontroller.addAction(buyAction)
        buyercontroller.addAction(cancelAction)
        
        present(buyercontroller, animated: true, completion: nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased, SKPaymentTransactionState.restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactioninprogress = false
                self.didbuyads = true
                
                
            case SKPaymentTransactionState.failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactioninprogress = false
                
            default:
                break
            }
        }
    }
    
    // MARK: Leaderboards
    
    func submitscore () {
        let leaderboardID = "grp.SpacePhish1"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = score
        
        GKScore.report([sScore], withCompletionHandler: { (error: Error?) -> Void in
        })
    }
    
    func showleaderboards() {
        let gcvc = GKGameCenterViewController()
        gcvc.gameCenterDelegate = self
        gcvc.viewState = GKGameCenterViewControllerState.leaderboards
        gcvc.leaderboardIdentifier = "grp.SpacePhish1"
        self.present(gcvc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        let vc = self.view.window?.rootViewController
        vc!.dismiss(animated: true, completion: nil)
    }

}
