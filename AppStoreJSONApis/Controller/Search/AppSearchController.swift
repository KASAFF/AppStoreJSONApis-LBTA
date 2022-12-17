//
//  AppsSearchControllerCollectionViewController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 13.12.2022.
//

import UIKit
import SDWebImage

class AppSearchController: BaseListController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    fileprivate let cellId = "id1234"
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate let enterSearchTermLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter search term above..."
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let appId = String(appResults[indexPath.item].trackId)
        let appDetailController = AppDetailController(appId: appId)
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.addSubview(enterSearchTermLabel)
        enterSearchTermLabel.fillSuperview(padding: .init(top: 100, left: 50, bottom: 0, right: 50))
        
        setupSearchBar()
        
        //fetchITunesApps()
        
    }
    
    fileprivate func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    var timer: Timer?

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {        
        // introduce some delay before performing the search
        // Thtottling the search
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            Service.shared.fetchApps(seachTerm: searchText) { res, err in
                if let err = err {
                    print("Failed to fetch apps:", err)
                    return
                }
                self.appResults = res?.results ?? []
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                self.timer?.invalidate()
            }
        })
    }
        
        fileprivate func fetchITunesApps() {
            Service.shared.fetchApps(seachTerm: "Twitter") { res, err in
                if let err = err {
                    print("Failed to fetch apps:", err)
                    return
                }
                self.appResults = res?.results ?? []
            }
        }
        
        
    
    
    fileprivate var appResults = [Result]()
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 350)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        enterSearchTermLabel.isHidden = appResults.count != 0
        return appResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchResultCell
        cell.appResult = appResults[indexPath.item]
        
        
        return cell
    }
        

    

}
