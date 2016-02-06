//
//  AppDelegate.swift
//  Walk Safe
//
//  Created by Marcos Castaneda on 2/6/16.
//  Copyright © 2016 Marcos Castaneda. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Nav bar appearance
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "SinkinSans-500Medium", size: 14)!
            , NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor(white: 0.9, alpha: 1)
        UINavigationBar.appearance().translucent = false
        
        // Tab bar apperance
        UITabBar.appearance().barTintColor = UIColor(white: 0, alpha: 1)
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UITabBar.appearance().translucent = true
        
        // Table appearance
        UITableView.appearance().separatorColor = UIColor(white: 0.2, alpha: 1)
        UITableViewCell.appearance().separatorInset = UIEdgeInsetsZero
        
        // Bar button
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15)], forState: UIControlState.Normal)
        
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

