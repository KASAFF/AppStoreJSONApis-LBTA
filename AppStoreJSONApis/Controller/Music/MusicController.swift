//
//  MusicController.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 18.12.2022.
//

import UIKit




class MusicController: BaseListController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    
    fileprivate let footerId = "footerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        collectionView.register(TrackCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(MusicLoadingFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerId)
        
        fetchData()
    }
    var results = [Result]() // blank empty array
    
    fileprivate let searchTerm = "taylor"
    
    fileprivate func fetchData() {
        let urlString = "https://itunes.apple.com/search?term=\(searchTerm)=a&offset=0&limit=20"
        Service.shared.fetchGenericJSONData(urlString: urlString) { (searchResult: SearchResult?, err) in
            if let err = err {
                print("Failed to paginate data:", err)
                return
            }
            
            self.results = searchResult?.results ?? []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
        
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        let height: CGFloat = isDonePaginating ? 0 : 100
        return .init(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    var isPaginating = false
    var isDonePaginating = false
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TrackCell
        let track = results[indexPath.item]
        cell.nameLabel.text = track.trackName
        cell.subtitleLabel.text = "\(track.artistName ?? "") • \(track.collectionName ?? "")"
        cell.imageView.sd_setImage(with: URL(string: track.artworkUrl100))
        
        //
        if indexPath.item == results.count - 1 && !isPaginating {
            print("Fetch more data")
            
            isPaginating = true
            
            let urlString = "https://itunes.apple.com/search?term=\(searchTerm)=a&offset=\(results.count)&limit=20"
            Service.shared.fetchGenericJSONData(urlString: urlString) { (searchResult: SearchResult?, err) in
                if let err = err {
                    print("Failed to paginate data:", err)
                    return
                }
                
                if searchResult?.results.count == 0 {
                    self.isDonePaginating = true
                }
                
                sleep(2)
                
                self.results += searchResult?.results ?? []
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                self.isPaginating = false
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 100)
    }
    
}
