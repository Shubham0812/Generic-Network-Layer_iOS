//
//  ViewController.swift
//  Generic-Network-Layer
//
//  Created by Shubham on 01/09/21.
//

import UIKit

class ViewController: UIViewController {

    /// PS:- Just for demo purposes, do not use it directly in a VC, you can create a service that uses the network Manager.
    let networkManager = NetworkManager()

    // MARK:- lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        networkManager.getPosts() { result, error in
            print(result?.count ?? 0 as Int)
        }
        networkManager.addPost() { result, error in
            print(result as Any)
        }
    }
}

