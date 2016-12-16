//
//  GameScene.swift
//  Space Phish
//
//  Created by Gregory Howlett-Gomez on 8/16/16.
//  Copyright (c) 2016 Breakware. All rights reserved.
//
//  Music Assets from musopen.org
// CREDIT FOR THE SONGS!!!!!!!!!

import SpriteKit
import GameplayKit
import Social
import AVFoundation

enum GameState {
    case showingLogo
    case showingCredits
    case instructions
    case playing
    case paused
    case gameover
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var gamescenedelegate: GameViewController?
    var lasttouch = CGPoint(x: 0, y: 0)
    var scorelabel: SKLabelNode!
    var pausebutton: SKSpriteNode!
    var instructions: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var resetbutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var logo: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var sharebutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var screenshot: UIImage!
    var audioplayer = AVAudioPlayer()
    var endingplayer = AVAudioPlayer()
    var playbutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var ratebutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var adsbutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var submitbutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var leaderbutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var corescore: Int64!
    var creditbutton: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var credits1: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var credits2: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var credits3: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var credits4: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var credits5: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var credits6: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    var adsresponse: SKLabelNode = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
    
    var minutesalive = 0
    var secondsalive = 0 {
        didSet {
            scorelabel.text = "\(minutesalive) minutes, \(secondsalive) seconds"
        }
    }
    
    var Gamestate = GameState.showingLogo
    
    override func didMove(to view: SKView) {
        // render initial functions
        createspace()
        createplayer()
        createscore()
        createlogo()
        createbutton(playbutton, position: CGPoint(x: frame.width / 4,y: frame.height / 2), text: "Play", name: "playbutton")
        createbutton(leaderbutton, position: CGPoint(x: frame.width * 1 / 4, y: frame.height * 3 / 10), text: "Leaderboards", name: "leaderbutton")
        createbutton(creditbutton, position: CGPoint(x: frame.width * 3 / 4, y: frame.height / 2), text: "Credits", name: "creditbutton")
        createbutton(adsbutton, position: CGPoint(x: frame.width * 3 / 4, y: frame.height * 3 / 10), text: "Remove Ads", name: "adsbutton")
        
        // refers to self for collisions
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let newtouch = touch.location(in: self)
            lasttouch.x = newtouch.x
            lasttouch.y = newtouch.y
        }
        
        let touchednode = self.atPoint(lasttouch)
        
        switch Gamestate {
        case .showingLogo:
            if touchednode.name == "playbutton" {
               Gamestate = GameState.instructions
               createinstructions()
               logo.removeFromParent()
               makeplayingmusic()
               playbutton.removeFromParent()
               adsbutton.removeFromParent()
               leaderbutton.removeFromParent()
               creditbutton.removeFromParent()
               print(gamescenedelegate?.didbuyads as Any)
            }
            
            if touchednode.name == "adsbutton" {
                    gamescenedelegate?.showActions()
            }
            
            if touchednode.name == "leaderbutton" {
                gamescenedelegate?.showleaderboards()
            }
            
            if touchednode.name == "creditbutton" {
                Gamestate = GameState.showingCredits
                removeopening()
                createcredits()
            }
            
        case .showingCredits:
            Gamestate = GameState.showingLogo
            removecredits()
            adoptopening()
            
        case .instructions:
            Gamestate = GameState.playing
            createmeteors()
            createpausebutton()
            instructions.removeFromParent()
            
        case .playing:
        
        if touchednode.name == "Pausebutton" {
            pausegame()
            break
        }
        
        guard player != nil else {return}
        
        // find difference between player position and touch position
        let xoffset = lasttouch.x - player.position.x
        let yoffset = lasttouch.y - player.position.y
        
        // determine if fish faces left or right
        if lasttouch.x < player.position.x {
            player.texture = SKTexture(imageNamed: "playercharacterf")
            let playertexture = SKTexture(imageNamed: "playercharacterf")
            player.physicsBody = SKPhysicsBody(texture: playertexture, size: player.size)
        } else {
            player.texture = SKTexture(imageNamed: "playercharacter")
            let playertexture = SKTexture(imageNamed: "playercharacter")
            player.physicsBody = SKPhysicsBody(texture: playertexture, size: player.size)
        }
        
        // create normalized vector
        let norm = sqrt((xoffset * xoffset) + (yoffset * yoffset))
        let normforce = CGVector(dx: xoffset / norm, dy: yoffset / norm)
        
        //multiply normalized impulse by factor to enhance game experience
        let framearea = frame.height * frame.width
        let force = CGVector(dx: framearea * normforce.dx / 500, dy: framearea * normforce.dy / 500)
        player.physicsBody?.applyForce(force)
            
        case .gameover:
            
            if touchednode.name == "resetbutton" {
               endingplayer.stop()
               self.gamescenedelegate?.resetgame()
            
            }
            
            if touchednode.name == "shareButton" {
                self.gamescenedelegate?.takescreenshot()
                self.gamescenedelegate?.sharingiscaring()
            }

            if touchednode.name == "submitbutton" {
                gamescenedelegate?.submitscore()
                gamescenedelegate?.showleaderboards()
            }
            
            if touchednode.name == "rateButton" {
                UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/us/app/space-phish/id1152757541?mt=8")!)
            }
        case .paused:
            
            if touchednode.name == "Pausebutton" {
                Gamestate = .playing
                pausebutton.texture = SKTexture(imageNamed: "Pausebutton")
                self.isPaused = false
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if (player.position.x < player.size.width / 2 ) {
            player.position.x = player.size.width / 2
        }
        
        if player.position.x > (frame.width - (player.size.width / 2)) {
            player.position.x = frame.width - (player.size.width / 2)
        }
        
        if player.position.y < player.size.height / 2 {
            player.position.y = player.size.height / 2
        }
        
        if player.position.y > (frame.height - (player.size.height / 2)) {
            player.position.y = frame.height - (player.size.height / 2)
        }
    }
    
    // MARK: Create player, background and meteors
    
    func createplayer() {
        //create player node
        let playertexture = SKTexture(imageNamed: "playercharacter")
        player = SKSpriteNode(texture: playertexture)
        player.size.height = frame.height / 15
        player.size.width = frame.height * 7 / 75
        player.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        player.zPosition = 15
        player.position = CGPoint(x: frame.width / 2, y: frame.height * 13 / 15)
        player.name = "player"
        
        // create player physics node
        player.physicsBody = SKPhysicsBody(texture: playertexture, size: player.size)
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody!.mass = 1
        
        addChild(player)
    }
    
    func createspace() {
        // create space
        let background = SKSpriteNode(imageNamed: "Background")
        background.size.width = frame.width
        background.size.height = frame.height
        background.zPosition = -50
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: 0, y: 0)

        addChild(background)
    }
    
    func createmeteors() {
        let meteortexture = SKTexture(imageNamed: "meteor")
        
        for i in 0 ... 4 {
        
            // initialize meteors
            let meteor = SKSpriteNode(texture: meteortexture)
            meteor.size.width = frame.width / 5
            meteor.size.height = frame.width / 5
            meteor.anchorPoint = CGPoint(x: 0.5,y: 0.5)
            meteor.zPosition = 10
            meteor.position = CGPoint(x: (frame.width / 10) + (CGFloat(i) * (frame.width / 5)), y: frame.width / 10 + 0)
    
            //make meteors move upwards
            let rand = GKRandomDistribution(lowestValue: 200, highestValue: 500)
            let moveup = SKAction.moveTo(y: frame.height, duration: Double(rand.nextInt()) / 75)
            let movedown = SKAction.moveTo(y: frame.width / 10, duration: 0)
            let moveloop = SKAction.sequence([moveup, movedown])
            let moveforever = SKAction.repeatForever(moveloop)
            
            meteor.run(moveforever)
            
            // make meteors spin around
            let texture0 = SKTexture(imageNamed: "meteor")
            let texture1 = SKTexture(imageNamed: "meteor1")
            let texture2 = SKTexture(imageNamed: "meteor2")
            let texture3 = SKTexture(imageNamed: "meteor3")
            let texture4 = SKTexture(imageNamed: "meteor4")
            let texture5 = SKTexture(imageNamed: "meteor5")
            let texture6 = SKTexture(imageNamed: "meteor6")
            let texture7 = SKTexture(imageNamed: "meteor7")
            let spin = SKAction.animate(with: [texture0, texture1, texture2, texture3, texture4, texture5, texture6, texture7], timePerFrame: 0.1)
            let spinforever = SKAction.repeatForever(spin)
            
            meteor.run(spinforever)
            
            // add physics to meteors
            meteor.physicsBody = SKPhysicsBody(circleOfRadius: (meteor.size.width / 2) - 1)
            meteor.physicsBody?.isDynamic = false
            meteor.physicsBody!.contactTestBitMask = meteor.physicsBody!.collisionBitMask
            
            addChild(meteor)
        }
    }
    
    // MARK: Did begin contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        // determine if player hit meteor: if so, remove player
        if contact.bodyA.node?.name == "player" || contact.bodyB.node?.name == "player" {
            Gamestate = GameState.gameover
            player.removeFromParent()
            changescorelabel()
            createbutton(resetbutton, position: CGPoint(x: frame.width / 4, y: frame.height / 2), text: "Reset", name: "resetbutton")
            createbutton(sharebutton, position: CGPoint(x: frame.width * 3 / 4, y: frame.height / 2), text: "Share", name: "shareButton")
            makeendingmusic()
            createbutton(submitbutton, position: CGPoint(x: frame.width * 3 / 4, y: frame.height * 3 / 10), text: "Submit Score", name: "submitbutton")
            createbutton(ratebutton, position: CGPoint(x: frame.width * 1 / 4, y: frame.height * 3 / 10), text: "Rate", name: "rateButton")
            createcorescore()
            gamescenedelegate!.score = corescore
        }
    }
    
    // MARK: Creating and editing non-interactive labels + pause button
    
    func createlogo() {
        logo = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
        logo.fontSize = frame.width / 10
        logo.color = UIColor.white
        logo.position = CGPoint(x: frame.width / 2, y: frame.height * 2 / 3)
        logo.zPosition = 100
        logo.text = "SPACE PHISH"
        
        addChild(logo)
    }
    
    func createscore() {
        scorelabel = SKLabelNode(fontNamed: "Comic Sans MS")
        scorelabel.fontColor = UIColor.white
        scorelabel.position = CGPoint(x: frame.width * (1 / 2), y : frame.width * (1 / 5))
        scorelabel.zPosition = 50
        scorelabel.fontSize = frame.width / 30
        scorelabel.text = "0 minutes, 0 seconds"
        
        addChild(scorelabel)
        
        let wait = SKAction.wait(forDuration: 1)
        let actionrun = SKAction.run(
            {if self.Gamestate == GameState.playing {
                self.secondsalive += 1
                
                if self.secondsalive == 60 {
                    self.minutesalive += 1
                    self.secondsalive = 0
                }
                }})
        let counter = SKAction.sequence([wait, actionrun])
        let timer = SKAction.repeatForever(counter)
        scorelabel.run(timer)
    }
    
    func createpausebutton() {
        let paused = SKTexture(imageNamed: "Pausebutton")
        pausebutton = SKSpriteNode(texture: paused)
        pausebutton.size.height = frame.height / 20
        pausebutton.size.width = frame.height / 20
        pausebutton.anchorPoint = CGPoint(x: 0, y: 0)
        pausebutton.position = CGPoint(x: frame.width / 20, y: frame.height * 9 / 10)
        pausebutton.zPosition = 10
        pausebutton.name = "Pausebutton"
        
        addChild(pausebutton)
    }
    
    func createinstructions() {
        instructions = SKLabelNode(fontNamed: "Comic Sans MS-Bold")
        instructions.fontSize = frame.width / 30
        instructions.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        instructions.color = UIColor.white
        instructions.text = "Touch the screen where you want the fish to move."
        
        addChild(instructions)
    }
    
    func changescorelabel() {
        scorelabel.position = CGPoint(x: frame.width / 2, y: frame.height * 2 / 3)
        scorelabel.fontSize = frame.width / 30
        scorelabel.text = "Congratulations, you survived for \(minutesalive) minutes and \(secondsalive) seconds!"
    }
    
    // MARK: music
    
    func makeplayingmusic() {
        let musicURL = Bundle.main.url(forResource: "Wagner-cut", withExtension: "mp3")
        
        guard let playerURL = musicURL else {
            print("error in url")
            return
        }
        do {
        audioplayer = try AVAudioPlayer(contentsOf: playerURL)
        audioplayer.numberOfLoops = -1
        audioplayer.prepareToPlay()
        audioplayer.play()
        } catch let error as NSError {
            print(error.description)
        }
        }
    
    func makeendingmusic() {
        audioplayer.stop()
        
        let musicURL = Bundle.main.url(forResource: "Tschaikovsky", withExtension: "mp3")
        
        guard let playerURL = musicURL else {
            print("error in url")
            return
        }
        do {
            endingplayer = try AVAudioPlayer(contentsOf: playerURL)
            endingplayer.numberOfLoops = 0
            endingplayer.prepareToPlay()
            endingplayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    // MARK: Pause and corescore
    
    func pausegame() {
        pausebutton.texture = SKTexture(imageNamed: "Runbutton")
        Gamestate = .paused
        self.isPaused = true
    }
    
    func createcorescore() {
        corescore = Int64(minutesalive) * 60 + Int64(secondsalive)
    }
    
    // MARK: createbutton and killChild
    
    func createbutton(_ button: SKLabelNode, position: CGPoint,text: String,name: String) {
        button.fontSize = frame.width / 20
        button.position = position
        button.zPosition = 100
        button.color = UIColor.white
        button.text = text
        button.name = name
        
        if button.parent != nil {
            button.removeFromParent()
        }
        
        addChild(button)
    }
    
    func killChild(_ button: SKNode) {
        if button.parent != nil {
            button.removeFromParent()
        } else {
            return
        }
    }
    
    // MARK: Dealing with credits
    
    func createcredits() {
        createbutton(credits1, position: CGPoint(x: frame.width / 2, y: frame.height * 1 / 3), text: "Ending Song: Excerpt from Symphony No. 6 in B Minor,", name: "credits1")
        createbutton(credits2, position: CGPoint(x: frame.width / 2, y: (frame.height * 1 / 3) - (frame.width / 40)), text: "op 87, 'Pathetique' IV - Finale Adagio Lamentoso", name: "credits2")
        createbutton(credits3, position: CGPoint(x: frame.width / 2, y: (frame.height * 1 / 3) - (frame.width / 20)), text: "Composed by Pytor Ilyich Tchaikovsky and performed by the Musopen Symphony", name: "credits3")
        credits1.fontSize = frame.width / 40
        credits2.fontSize = frame.width / 40
        credits3.fontSize = frame.width / 40
        createbutton(credits4, position: CGPoint(x: frame.width / 2, y: frame.height / 2), text: "Playing Song: Excerpt from Fantasie from Die Walkure", name: "credits 4")
        createbutton(credits5, position: CGPoint(x: frame.width / 2, y: (frame.height / 2 ) - (frame.width / 40)), text: "Composed by Richard Wagner and performed by the United States Marine Band", name: "credits5")
        credits4.fontSize = frame.width / 40
        credits5.fontSize = frame.width / 40
        createbutton(credits6, position: CGPoint(x: frame.width / 2, y: frame.height * 3 / 5), text: "All Music Obtained from musopen.org", name: "credits6")
        credits6.fontSize = frame.width / 40
    }
    
    func removecredits() {
        credits1.removeFromParent()
        credits2.removeFromParent()
        credits3.removeFromParent()
        credits4.removeFromParent()
        credits5.removeFromParent()
        credits6.removeFromParent()
    }
    
    func adoptopening() {
        addChild(playbutton)
        addChild(leaderbutton)
        addChild(creditbutton)
        addChild(adsbutton)
    }
    
    func removeopening() {
        killChild(playbutton)
        killChild(leaderbutton)
        killChild(creditbutton)
        killChild(adsbutton)
    }
}

