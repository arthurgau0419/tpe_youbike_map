//
//  AppDelegate+RegisterViews.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import URLNavigator

let navigator = Navigator()

extension AppDelegate {
    func registerViews() {
        
        navigator.register("loading") { (_, _, _) -> UIViewController? in
            return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "LoadingViewController")
        }
        
        navigator.handle("init_loading") { (url, parameter, context) -> Bool in
            let window = UIWindow(frame: UIScreen.main.bounds)
            let vc = navigator.viewController(for: "loading")
            window.rootViewController = vc
            window.makeKeyAndVisible()
            self.window = window
            return true
        }
        
        navigator.register("list") { (url, parameter, context) -> UIViewController? in
            return UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "ListViewController") as? ListViewController
        }
        
        navigator.register("map") { (url, parameter, context) -> UIViewController? in
            return UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        }
        
        navigator.handle("replace_tabbar") { (url, parameter, context) -> Bool in
            
            guard let stations = (context as? [String: Any])?["stations"] as? [UbikeStation] else {
                return false
            }
            
            let listVC = navigator.viewController(for: "list") as? ListViewController
            listVC?.viewModel = ListViewModel(stations: stations)
            listVC?.tabBarItem.title = "列表"
            
            let mapVC = navigator.viewController(for: "map") as? MapViewController
            mapVC?.viewModel = MapViewModel(stations: stations)
            mapVC?.tabBarItem.title = "地圖"
            
            let tabVC = UITabBarController()
            tabVC.viewControllers = [
                listVC,
                mapVC
                ]
                .compactMap { $0 }
            
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = tabVC
            window.makeKeyAndVisible()
            self.window = window
            return true
        }
        
        navigator.handle("select_map_item") { (url, parameter, context) -> Bool in            
            guard
                let id = context as? String,
                let tabVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
                let mapVC = tabVC.viewControllers?.first(where: { $0.isKind(of: MapViewController.self) }) as? MapViewController
                else { return false }
            tabVC.selectedViewController = mapVC
            mapVC.moveToMapItem(id: id)
            return true
        }
        
    }
}
