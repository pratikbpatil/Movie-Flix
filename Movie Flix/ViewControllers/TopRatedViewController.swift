//
//  TopRatedViewController.swift
//  Movie Flix
//
//  Created by Apple on 26/05/20.
//  Copyright © 2020 Pratik Patil. All rights reserved.
//

import UIKit
import CoreData


class TopRatedViewController: UIViewController {
    
    var viewModelTopRated = TopRatedAPIManager()
    var imgPoster : UIImage?
    var localTopRatedArray = [TopRatedMovieDetails]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var filterArray: [TopRatedMovieDetails] = []
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet var collectionViewOutlet: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewOutlet.delegate = self
        self.collectionViewOutlet.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionViewOutlet.setCollectionViewLayout(layout, animated: true)
        self.collectionViewOutlet.register(UINib(nibName: "ListingOfMoviesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        viewModelTopRated.vc = self
        self.getDataTopRated()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        collectionViewOutlet.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setSearchBar()
    }
    
    
    
    @objc func refresh (_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        self.getDataTopRated()
    }
    
    
    func getDataTopRated(){
        viewModelTopRated.topRatedListAPI() { (success, error, nowPlayingArray) in
            if success{
                // Core data
                let result = CoreDataManager.sharedInstance.getTopRatedRecords()
                self.localTopRatedArray = result
                print("Local data Top Rated array count is : \(self.localTopRatedArray.count)")
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
        self.getDataTopRated()
        refreshControl.endRefreshing()
    }
    
    
}

extension TopRatedViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.searchController.isActive){
            return filterArray.count
        }
        else{
            return localTopRatedArray.count
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
            let obj = localTopRatedArray[indexPath.item]
            cell.lblMovieTitle.text = obj.movieTitle
            cell.lblMovieDescription.text = obj.movieDescription
            cell.btnDelete.addTarget(self, action: #selector(selectbtnDeleteTapped(sender:)), for: .touchUpInside)
            cell.btnDelete.isHidden = false
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
                    CoreDataManager.sharedInstance.deleteOperatedRecords(record: filterArray[index.row])
                    filterArray.remove(at: index.row)
                }
            }
            else{
                CoreDataManager.sharedInstance.deleteOperatedRecords(record: localTopRatedArray[index.row])
                localTopRatedArray.remove(at: index.row)
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
                vc.avgVote = obj.voteAverage ?? ""
                vc.movieReleaseDate = obj.releaseDate ?? ""
            }
        }
        else{
            let obj = localTopRatedArray[indexPath.item]
            vc.imgPosterString = baseUrlForListImage + (obj.posterImageString ?? "")
            vc.movieTitle = obj.movieTitle ?? ""
            vc.overviewString = obj.movieDescription ?? ""
            vc.avgVote = obj.voteAverage ?? ""
            vc.movieReleaseDate = obj.releaseDate ?? ""
        }        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TopRatedViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterArray.removeAll(keepingCapacity: false)
        let array = localTopRatedArray.filter ( { $0.movieTitle!.range(of: searchController.searchBar.text!, options: .caseInsensitive) != nil})
        self.filterArray = array
        self.collectionViewOutlet.reloadData()
    }
}

