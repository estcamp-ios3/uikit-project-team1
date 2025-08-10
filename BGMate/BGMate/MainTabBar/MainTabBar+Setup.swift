//
//  MainTabBar+Setup.swift
//  BGMate
//
//  Created by Yesung Yoon on 8/5/25.
//

import UIKit

extension MainTabBarController {
    
    // MARK: - 초기 설정
    
    // MARK: - 탭바 구성
    
    func setupTabBar() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "BGMate", image: UIImage(systemName: "house"), tag: 0)
        
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem = UITabBarItem(title: "LIBRARY", image: UIImage(systemName: "square.stack"), tag: 1)
        
        self.viewControllers = [homeVC, searchVC]
    }
    
    // MARK: - 미니플레이어 배치/델리게이트
    func setupMiniPlayer() {
        // 미니플레이어 뷰 추가 (child로 추가하지 않음)
        view.addSubview(miniPlayerVC.view)
        
        // 미니플레이어 델리게이트 설정
        miniPlayerVC.delegate = self
        
        // 오토레이아웃 제약 (항상 탭바 위에!)
        miniPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            miniPlayerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniPlayerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniPlayerVC.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            miniPlayerVC.view.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
}
