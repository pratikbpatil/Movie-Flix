//
//  NowPlayingViewController.swift
//  Movie Flix
//
//  Created by Apple on 26/05/20.
//  Copyright © 2020 Pratik Patil. All rights reserved.
//

import UIKit
import CoreData

class NowPlayingViewController: UIViewController {
    
    var viewModelNowPlaying = NowPlayingAPIManager()
    var imgPoster : UIImage?
    var localDataArray = [MovieDetails]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var filterArray: [MovieDetails] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(NowPlayingViewController.handleRefresh),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    
    
    @IBOutlet var collectionViewOutlet: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.localDataArray.removeAll()
        self.collectionViewOutlet.delegate = self
        self.collectionViewOutlet.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionViewOutlet.setCollectionViewLayout(layout, animated: true)
        self.collectionViewOutlet.register(UINib(nibName: "ListingOfMoviesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        viewModelNowPlaying.vc = self
        self.getDataNowPlaying()
        // for pull to refresh functionality
        self.collectionViewOutlet.addSubview(self.refreshControl)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setSearchBar()
    }
    
    func getDataNowPlaying(){
        // self.localDataArray.removeAll()
        viewModelNowPlaying.nowPlayingListAPI { (success, error, nowPlayingArray) in
            if success{
                // Core data
                let result = CoreDataManager.sharedInstance.getnowPlayingRecords()
                self.localDataArray = result
                print("Local data array count is : \(self.localDataArray.count)")
            }
            else{
                print(error)
            }
        }
    }
    
    func setSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        if #available(iOS 11.0, *) {
            print("iOS Version => 11.0")
            navigationItem.searchController = searchController
            searchController.searchBar.tintColor = UIColor.white
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        else{
            print("iOS Version lower than 11.0")
        }
        
        searchController.searchBar.tintColor = UIColor.black
        searchController.hidesNavigationBarDuringPresentation = false
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes
            .updateValue(UIColor.black, forKey: NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue))
        searchController.searchBar.barTintColor = UIColor(red: 229/255, green: 58/255, blue: 50/255, alpha: 1)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        self.getDataNowPlaying()
        refreshControl.endRefreshing()
    }
    
}

extension NowPlayingViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(self.searchController.isActive){
            return filterArray.count
        }
        else{
            return localDataArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ListingOfMoviesCollectionViewCell = collectionViewOutlet.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ListingOfMoviesCollectionViewCell
        if(self.searchController.isActive){
            if self.filterArray.count != 0{
                
                let obj = filterArray[indexPath.item]
                cell.lblMovieTitle.text = obj.movieTitle
                cell.lblMovieDescription.text = obj.movieDescription
                cell.btnDelete.isHidden = true
                cell.btnDelete.addTarget(self, action: #selector(selectbtnDeleteTapped(sender:)), for: .touchUpInside)
                let imageURL = baseUrlForListImage + (obj.posterImageString ?? "")
                DispatchQueue.main.async() {
                    let url = URL(string: imageURL)
                    let data = try? Data(contentsOf: url!)
                    if let imageData = data { let image = UIImage(data: imageData)
                        cell.imgMovie.image = image
                    }
                }
            }
        }
        else{
            let obj = localDataArray[indexPath.item]
            cell.lblMovieTitle.text = obj.movieTitle
            cell.lblMovieDescription.text = obj.movieDescription
            
            cell.btnDelete.isHidden = false
            
            cell.btnDelete.addTarget(self, action: #selector(selectbtnDeleteTapped(sender:)), for: .touchUpInside)
            let imageURL = baseUrlForListImage + (obj.posterImageString ?? "")
            DispatchQueue.main.async() {
                let url = URL(string: imageURL)
                let data = try? Data(contentsOf: url!)
                if let imageData = data { let image = UIImage(data: imageData)
                    cell.imgMovie.image = image
                }
            }
        }
        return cell
    }
    
    @objc func selectbtnDeleteTapped(sender:UIButton){
        let buttonPosition : CGPoint = sender.convert(sender.bounds.origin, to: self.collectionViewOutlet)
        if let index = self.collectionViewOutlet.indexPathForItem(at: buttonPosition){
            print("button tapped index = \(index)")
            // deleting perticular item
            if(self.searchController.isActive){
                if self.filterArray.count != 0{
                    
                    CoreDataManager.sharedInstance.deleteNowPlayingRecord(record: filterArray[index.row])
                    
                    filterArray.remove(at: index.row)
                }
            }
            else{
                
                CoreDataManager.sharedInstance.deleteNowPlayingRecord(record: localDataArray[index.row])
                localDataArray.remove(at: index.row)
            }
            
            CoreDataManager.sharedInstance.saveAllData()
            self.collectionViewOutlet.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        let widthPerItem = collectionView.frame.width
        let height = widthPerItem * 1.7
        return CGSize(width:widthPerItem, height:160.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "MovieDetailsViewController") as! MovieDetailsViewController
        
        if(self.searchController.isActive){
            if self.filterArray.count != 0{
                let obj = filterArray[indexPath.item]
                vc.imgPosterString = baseUrlForListImage + (obj.posterImageString ?? "")
                vc.movieTitle = obj.movieTitle ?? ""
                vc.overviewString = obj.movieDescription ?? ""
                vc.movieReleaseDate = obj.releaseDate ?? ""
                vc.avgVote = obj.voteAverage ?? ""
            }
        }
        else{
            let obj = localDataArray[indexPath.item]
            vc.imgPosterString = baseUrlForListImage + (obj.posterImageString ?? "")
            vc.movieTitle = obj.movieTitle ?? ""
            vc.overviewString = obj.movieDescription ?? ""
            vc.movieReleaseDate = obj.releaseDate ?? ""
            vc.avgVote = obj.voteAverage ?? ""
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NowPlayingViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterArray.removeAll(keepingCapacity: false)
        let array = localDataArray.filter ( { $0.movieTitle!.range(of: searchController.searchBar.text!, options: .caseInsensitive) != nil})
        self.filterArray = array
        self.collectionViewOutlet.reloadData()
    }
}
