//
//  CoreDataManager.swift
//  Movie Flix
//
//  Created by Apple on 29/05/20.
//  Copyright © 2020 Pratik Patil. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    static let sharedInstance = CoreDataManager()
    let context = AppDelegate().persistentContainer.viewContext
    
    
    func deleteAllRecords(entityName : String) {
        //delete all data
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func saveNowPlayingRecords(user:NowPlayingResults) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "MovieDetails", into: self.context) as! MovieDetails
        entity.movieTitle = user.title
        entity.releaseDate = user.release_date
        if let voteAvg = user.vote_average{
            entity.voteAverage = String(voteAvg)
        }
        if let id = user.id{
            entity.id = String(id)
        }
        entity.movieDescription = user.overview
        entity.posterImageString = user.poster_path
        do{
            try self.context.save()
        }
        catch let error as NSError{
            print(error.userInfo)
        }
        print("saved is :\(entity.movieTitle)")
        
    }
    
    func saveTopRatedRecords(user:TopRatedResults) {
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "TopRatedMovieDetails", into: self.context) as! TopRatedMovieDetails
        entity.movieTitle = user.title
        entity.releaseDate = user.release_date
        if let voteAvg = user.vote_average{
            entity.voteAverage = String(voteAvg)
        }
        if let id = user.id{
            entity.id = String(id)
        }
        entity.movieDescription = user.overview
        entity.posterImageString = user.poster_path
        do{
            try self.context.save()
        }
        catch let error as NSError{
            print(error.userInfo)
        }
    }
    func getnowPlayingRecords() -> [MovieDetails]{
        let request = NSFetchRequest<MovieDetails>.init(entityName: "MovieDetails")
        let result = try!self.context.fetch(request)
        return result
    }
    func getTopRatedRecords() -> [TopRatedMovieDetails]{
        let request = NSFetchRequest<TopRatedMovieDetails>.init(entityName: "TopRatedMovieDetails")
        let result = try!self.context.fetch(request)
        return result
    }
    func deleteOperatedRecords(record : TopRatedMovieDetails){
        context.delete(record)
    }
    func deleteNowPlayingRecord(record : MovieDetails){
        context.delete(record)
    }
    func saveAllData(){
        try! self.context.save()
    }
}
