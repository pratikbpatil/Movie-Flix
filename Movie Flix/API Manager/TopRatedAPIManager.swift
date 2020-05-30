//
//  TopRatedAPIManager.swift
//  Movie Flix
//
//  Created by Apple on 26/05/20.
//  Copyright © 2020 Pratik Patil. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class TopRatedAPIManager {
    
    weak var vc : TopRatedViewController?
    var topRatedArray = [TopRatedResults]()
    let context = AppDelegate().persistentContainer.viewContext
    func topRatedListAPI(completion: @escaping (Bool, String?,[TopRatedResults]?) -> ()){
        
        AF.request(topRatedURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).response { (response) in
            if let data = response.data{
                do {
                    let model = try JSONDecoder().decode(TopRatedBase.self, from: data)
                    if let data = model.results{
                        CoreDataManager.sharedInstance.deleteAllRecords(entityName: "TopRatedMovieDetails")
                        self.topRatedArray.removeAll()
                        self.topRatedArray.append(contentsOf: data)
                        for user in self.topRatedArray{
                            CoreDataManager.sharedInstance.saveTopRatedRecords(user:user)
                        }
                        print(self.topRatedArray)
                    }
                    DispatchQueue.main.async {
                        self.vc?.collectionViewOutlet.reloadData()
                    }
                    completion(true,"",self.topRatedArray)
                }catch let err{
                    print("error is :\(err.localizedDescription)")
                    completion(false,"error",nil)
                }
            }
        }
    }
    
}
