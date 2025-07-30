//
//  SceneDelegate.swift
//  UIKitTeamPrjApp
//
//  Created by catharina J on 7/27/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        
        let tabOneNav = UINavigationController(rootViewController: HomeViewController())  // 홈(임시 파일 생성
        tabOneNav.tabBarItem = UITabBarItem(title: "BGMate", image: UIImage(systemName: "house"), tag: 0)
//
//        let tabTwoNav = UINavigationController(rootViewController: TabTwoViewController())  // 전체 리스트
//        tabTwoNav.tabBarItem = UITabBarItem(title: "Tab02", image: UIImage(systemName: "map.fill"), tag: 1)
      
        let tabThreeNav = UINavigationController(rootViewController: SearchViewController())  // 검색
        tabThreeNav.tabBarItem = UITabBarItem(title: "SEARCH", image: UIImage(systemName: "magnifyingglass"), tag: 2)
//
//        let tabFourNav = UINavigationController(rootViewController: CreatePlaylistViewController())  //프로필
//        tabFourNav.tabBarItem = UITabBarItem(title: "Tab04", image: UIImage(systemName: "map"), tag: 3)

        let tabBarController = UITabBarController()
//        tabBarController.viewControllers = [tabOneNav, tabTwoNav, tabThreeNav, tabFourNav]
        tabBarController.viewControllers = [tabOneNav, tabThreeNav]
        
        window.rootViewController = tabBarController
        
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }


}

