//
//  FBViewController.h
//  Space Phish
//
//  Created by Gregory Howlett-Gomez on 8/27/16.
//  Copyright © 2016 Breakware. All rights reserved.
//

#ifndef FBViewController_h
#define FBViewController_h

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <UIKit/UIKit.h>

@interface FBSDKSharePhoto (Phishy)

-(void) setimage: (UIImage*) screenshot;

-(void) setminutes: (CGFloat) minutes andseconds: (CGFloat) seconds;

@end

#endif /* FBViewController_h */
