
//
//  PictureCollectionViewController.swift
//  CodeTest
//
//  Created by alexfu on 3/10/16.
//  Copyright © 2016 alexfu. All rights reserved.


import UIKit
import Kingfisher
import JSQCoreDataKit
import ReachabilitySwift
import SDCAlertView



class PictureCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet var searchButton: UIBarButtonItem!
    
    var searchController:UISearchController!
    var searchBar:UISearchBar!
    var refreshControl:UIRefreshControl!

    let kItemSpacing:CGFloat = 10.0
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)

    var pictures:[Picture]!
    var reachability: Reachability?
    
    let kPageSize = 20
    var currentPage:Int = 0
    var totalPages:Int!
    var isLoadingMore:Bool = false
    var cache:ImageCache!
    var Searchtext:String=""
    var coreDataStack: CoreDataStack!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Main"
        
        //Setup CollectionView
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clearColor()
        
       

        setupReachability(true)
        startNotifier()
        

        
        layout.minimumInteritemSpacing = kItemSpacing
        layout.minimumLineSpacing = kItemSpacing
        
        //Load initial elements
        pictures = [Picture]()
    
        
        //Add the refresh control
    /*
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshpictures", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
      */
        //Create Cache
        
        //Add Search
        addSearchController()
        cache=ImageCache(name: "codeTest")
        SetupCoreData()
    }
    
    func SetupCoreData(){
         let modelName = "SerachHistory"
        
         let modelBundle = NSBundle(identifier: "com.alexfu.CodeTest")!
        
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)
        
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                self.coreDataStack = s
                
                
            case .Failure(let err):
                assertionFailure("Error creating stack: \(err)")
            }
            
           
        }

    }
    
    
    func addSearchController() {
        //Initialize Search Controller
        
        self.searchController = ({
            
            let controller = UISearchController(searchResultsController: nil)
            controller.automaticallyAdjustsScrollViewInsets = false
            controller.searchResultsUpdater = self
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            
            controller.searchBar.delegate = self
            controller.searchBar.placeholder = "Search"
            controller.searchBar.showsScopeBar = false
            controller.searchBar.sizeToFit()
            controller.searchBar.returnKeyType = UIReturnKeyType.Search
            controller.searchBar.translucent = true
            
            self.searchBar = controller.searchBar
            self.definesPresentationContext = true
            
            return controller
        })()
    }
    
   

    
    func refreshpictures() {
        currentPage = 0
        }
    
    func didLoadpictures(pictures:[Picture]?, error:NSError?) {
        if error == nil && pictures != nil {
            if isLoadingMore {
                self.pictures = self.pictures + pictures!
            } else {
                self.pictures = pictures
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.reloadData()
            })
        }
        //TODO: Report error to the user.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.isLoadingMore = false
        })
    }
    
    //- MARK: Async Image loading
    
    
    //- MARK: Actions
    
    @IBAction func searchTapped(sender: AnyObject) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.titleView = self.searchBar
        self.searchBar.becomeFirstResponder()
    }
    
    deinit {
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache = nil
    }
    
    @IBAction func DisplayHistory(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController:HistoryVC = storyboard.instantiateViewControllerWithIdentifier("historyTableVC") as! HistoryVC
        
        viewController.stack = coreDataStack
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
  

}

// MARK: -
// MARK: UICollectionViewDataSource

extension PictureCollectionViewController: UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! imageCell
        let placeholderImg = UIImage(named: "placehold")
        let picture = self.pictures[indexPath.row]
        //cell.idText.text=picture.thumbUrl
        cell.imgView.kf_setImageWithURL(NSURL(string:picture.thumbUrl)!, placeholderImage:placeholderImg)
     
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController:PictureViewController = storyboard.instantiateViewControllerWithIdentifier("fullview") as! PictureViewController
        
        viewController.url = pictures[indexPath.item].imageUrl
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        // Start loading the next page, if there is more, when we reach the last cell
        if indexPath.row == self.pictures.count - 1 {
            self.isLoadingMore=true
            currentPage=currentPage+1
            if(reachability?.currentReachabilityStatus == .NotReachable)
            {
                return
            }
            ImgurService.Search(Searchtext,page:currentPage ,completion: didLoadpictures)
            print("load \(currentPage)")
            }
        }
    }
    




// MARK: -
// MARK: UICollectionViewDelegateFlowLayout

extension PictureCollectionViewController: UICollectionViewDelegateFlowLayout
{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let picture:Picture = self.pictures[indexPath.row]
        
   
            return CGSizeMake(100.0, 100.0)
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
}

// MARK: -
// MARK: UISearchBarDelegate

extension PictureCollectionViewController: UISearchBarDelegate
{
    func removeSearchBar() {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = self.searchButton
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        removeSearchBar()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        removeSearchBar()
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
       
        if let text = searchController.searchBar.text where searchController.searchBar.text!.characters.count > 0 {
            title=text
            
            do {
                let NotExist = try! History.NotExist(coreDataStack!.mainContext,searchText: text)
                if(NotExist)
                {
                let todayRecord = History.newRecordInContext((coreDataStack?.mainContext)!)
                todayRecord.query = text
                saveContext((coreDataStack?.mainContext)!)
                }
                }
            }
             //save to history
        }
}

// MARK: -
// MARK: UISearchResultsUpdating

extension PictureCollectionViewController: UISearchResultsUpdating
{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if(reachability?.currentReachabilityStatus == .NotReachable)
        {
          ShowNoInternetAlert()
          return
        }
        
        
        
        self.pictures.removeAll()
        //clear cache
      cache?.clearMemoryCache()
        currentPage=0
        
        
        if let text = searchController.searchBar.text where searchController.searchBar.text!.characters.count > 0 {
            currentPage+=1
            print("s=\(text)")
            ImgurService.Search(text,page:currentPage ,completion: didLoadpictures)
            Searchtext=text
        }
    }
    
    func ShowNoInternetAlert(){
        let alert = AlertController(title: "No Internet", message: "Internet Disconnected", preferredStyle: .Alert)
        alert.addAction(AlertAction(title: "Cancel", style: .Default))
        alert.addAction(AlertAction(title: "OK", style: .Preferred))
        alert.present()
    }
    

}

//Reachability
extension PictureCollectionViewController{
    
    
    
    func setupReachability(useClosures: Bool) {
        let hostName = "google.com"
        
        do {
            let reachability = try! Reachability(hostname: hostName)
            self.reachability = reachability
        } catch ReachabilityError.FailedToCreateWithAddress(let address) {
           
            return
        } catch {}
        
        if (useClosures) {
            reachability?.whenReachable = { reachability in
                self.updateLabelColourWhenReachable(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.updateLabelColourWhenNotReachable(reachability)
            }
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
           
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    func updateLabelColourWhenReachable(reachability: Reachability) {
        print("\(reachability.description) - \(reachability.currentReachabilityString)")
       
        
       
    }
    
    func updateLabelColourWhenNotReachable(reachability: Reachability) {
        print("\(reachability.description) - \(reachability.currentReachabilityString)")
       
       
        
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            updateLabelColourWhenReachable(reachability)
        } else {
            updateLabelColourWhenNotReachable(reachability)
        }
    }

}



