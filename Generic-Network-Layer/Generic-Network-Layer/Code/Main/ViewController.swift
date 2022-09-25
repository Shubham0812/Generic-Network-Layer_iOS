//
//  ViewController.swift
//  Generic-Network-Layer
//
//  Created by Shubham on 01/09/21.
//

import UIKit

class ViewController: UIViewController {
    
    /// PS:- Just for demo purposes, do not use it directly in a VC, you can create a service that uses the network Manager.
    var networkManager = NetworkManager(apiService: APIRequestManager())
    
    // MARK:- lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.getPosts() {(result) in
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    if let result = data {
                        result.forEach({print($0.title)})
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Shit just went down \(error.customDescription)")
                }
            }
        }
        
        networkManager.parameters = Post(userId: 1, title: "foo", body: "bar")
        
        networkManager.addPost(onCompletion: {(result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    if let result = data {
                        print(result)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Shit just went down \(error.customDescription)")
                }
            }
        })
    }
}

