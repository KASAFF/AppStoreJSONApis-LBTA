//
//  AppsCompositionalView.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 18.12.2022.
//

import SwiftUI

class CompositionalController: UICollectionViewController {
    
    init() {
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, _ in
            if sectionNumber == 0 {
                return CompositionalController.topSection()
            } else {
                //second section
                let item =
                NSCollectionLayoutItem(layoutSize:
                        .init(widthDimension:
                                .fractionalWidth(1), heightDimension:
                                .fractionalHeight(1/3)))
                item.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 16)
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize:
                        .init(widthDimension: .fractionalWidth(0.8),
                              heightDimension: .absolute(300)),subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets.leading = 16
                
                let kind = UICollectionView.elementKindSectionHeader
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: kind, alignment: .topLeading)
                ]
                
                return section
            }
        }
        
        super.init(collectionViewLayout: layout)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CompositionalHeader
        if indexPath.section == 1 {
            header.label.text = topFree?.feed.title
        } else if indexPath.section == 2 {
            header.label.text = topPaid?.feed.title
        } else {
            header.label.text = topMusic?.feed.title
        }
        return header
        
    }
    static func topSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets.bottom = 16
        item.contentInsets.trailing = 16
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(300)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets.leading = 16
        return section
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class CompositionalHeader: UICollectionReusableView {
        
        let label = UILabel(text: "Editos's Choice Games", font: .boldSystemFont(ofSize: 32))
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(label)
            label.fillSuperview()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CompositionalHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(AppsHeaderCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(AppRowCell.self, forCellWithReuseIdentifier: "smallCellId")
        collectionView.backgroundColor = .systemBackground
        navigationItem.title = "Apps"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = .init(title: "Fetch Top Music", style: .plain, target: self, action: #selector(handleFetchTopFree))
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .primaryActionTriggered)
        //fetchApps()
        setupDiffableDatasource()
    }
    
    @objc fileprivate func handleRefresh() {
        collectionView.refreshControl?.endRefreshing()
        
        var snapshot = diffableDataSource.snapshot()
        snapshot.deleteSections([.music, .topSocial, .paid, .free])
        
        diffableDataSource.apply(snapshot)
    }
    
    @objc fileprivate func handleFetchTopFree() {
        Service.shared.fetchAppGroup(urlString: "https://rss.applemarketingtools.com/api/v2/us/music/most-played/25/albums.json") { appGroup, err in
            
            var snapshot = self.diffableDataSource.snapshot()
            
            snapshot.insertSections([.music], afterSection: .topSocial)
            
            snapshot.appendItems(appGroup?.feed.results ?? [], toSection: .music)
            
            self.diffableDataSource.apply(snapshot)
            self.topMusic = appGroup
        }
        
    }
    
    enum AppSection {
        case topSocial
        case free
        case paid
        case music
    }
    
    lazy var diffableDataSource: UICollectionViewDiffableDataSource<AppSection, AnyHashable> = .init(collectionView: self.collectionView) { collectionView, indexPath, object in
        
        if let object = object as? SocialApp {
            let cell =
            collectionView
                .dequeueReusableCell(withReuseIdentifier:
                "cellId", for: indexPath) as! AppsHeaderCell
            cell.app = object
            return cell
        } else if let object = object as? FeedResult {
            let cell =
            collectionView
                .dequeueReusableCell(withReuseIdentifier:
                "smallCellId", for: indexPath) as! AppRowCell
            cell.app = object
            
            cell.getButton.addTarget(self, action: #selector(self.deleteItem), for: .touchUpInside)
            return cell
            }
        
        return nil
    }
    
    @objc func deleteItem(button: UIView) {
        
        var superview = button.superview
        
        // i want to reach the parent cell of the get button
        while superview != nil {
            if let cell = superview as? UICollectionViewCell {
                guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
                guard let objectIClickedOnto = diffableDataSource.itemIdentifier(for: indexPath) else { return }
                var snapshot = diffableDataSource.snapshot()
                snapshot.deleteItems([objectIClickedOnto])
                diffableDataSource.apply(snapshot)
            }
            superview = superview?.superview
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       let object = diffableDataSource.itemIdentifier(for: indexPath)
        if let object = object as? SocialApp {
            let appDetailController = AppDetailController(appId: object.id)
            navigationController?.pushViewController(appDetailController, animated: true)
        } else if let object = object as? FeedResult {
            let appDetailController = AppDetailController(appId: object.id)
            navigationController?.pushViewController(appDetailController, animated: true)
        }
        
        
    }
    
    private func setupDiffableDatasource() {
        collectionView.dataSource = diffableDataSource
        
        
        diffableDataSource.supplementaryViewProvider = .some({ [self] collectionView, elementKind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: headerId, for: indexPath) as! CompositionalHeader
            
            let snapshot = self.diffableDataSource.snapshot()
            let object = diffableDataSource.itemIdentifier(for: indexPath)
            let section = snapshot.sectionIdentifier(containingItem: object!)
            
            if section == .paid {
                header.label.text = "Top Paid"
            } else if section == .music {
                header.label.text = "Top Music"
            } else {
                header.label.text = "Top Free"
            }
            return header
        })
        Service.shared.fetchSocialApps { socialApps, err in
            if let err = err {
                print(err,"error")
                return
            }
            Service.shared.fetchTopPaid { appGroup, err in
                
                Service.shared.fetchTopFree { freeApps, err in
                    var snapshot = self.diffableDataSource.snapshot()
                    //top social
                    snapshot.appendSections([.topSocial, .free, .paid])
                    snapshot.appendItems(socialApps ?? [], toSection: .topSocial)
                    //top paid
                    let objects = appGroup?.feed.results ?? []
                    snapshot.appendItems(objects, toSection: .paid)
                    
                    //free apps
                    
                    snapshot.appendItems(freeApps?.feed.results ?? [], toSection: .free)
                    
                    self.diffableDataSource.apply(snapshot)
                }
                
                
            }
            
            
        }

    }
    
    var socialApps = [SocialApp]()
    var groups = [AppGroup]()
    var topPaid: AppGroup?
    var topFree: AppGroup?
    var topMusic: AppGroup?
    
    fileprivate func fetchApps() {
        
        
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        Service.shared.fetchTopFree { appGroup, err in
            dispatchGroup.leave()
            self.topFree = appGroup
            
            
        }
        dispatchGroup.enter()
        Service.shared.fetchTopPaid { appGroup, err in
            dispatchGroup.leave()
            self.topPaid = appGroup
        }
        dispatchGroup.enter()
        Service.shared.fetchAppGroup(urlString: "https://rss.applemarketingtools.com/api/v2/us/music/most-played/25/albums.json") { appGroup, err in
            dispatchGroup.leave()
            self.topMusic = appGroup
        }
        dispatchGroup.enter()
        Service.shared.fetchSocialApps { apps, err in
            dispatchGroup.leave()
            self.socialApps = apps ?? []
        }
            
        dispatchGroup.notify(queue: .main) {
                    self.collectionView.reloadData()

               
            }
            
        }
            
    

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        0
    }
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 0 {
//            return socialApps.count
//        } else if section == 1 {
//           return topFree?.feed.results.count ?? 0
//        } else if section == 2 {
//            return topPaid?.feed.results.count ?? 0
//        } else {
//            return topMusic?.feed.results.count ?? 0
//        }
//
//        }
    
//
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let appId: String
//        if indexPath.section == 0 {
//            appId = socialApps[indexPath.item].id
//        } else if indexPath.section == 1  {
//            appId = topFree?.feed.results[indexPath.item].id ?? ""
//        } else if indexPath.section == 2 {
//            appId = topPaid?.feed.results[indexPath.item].id ?? ""
//        } else {
//            appId = topMusic?.feed.results[indexPath.item].id ?? ""
//        }
//        let appDetailController = AppDetailController(appId: appId)
//        navigationController?.pushViewController(appDetailController, animated: true)
//    }
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch indexPath.section {
//        case 0:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! AppsHeaderCell
//            let socialApp = self.socialApps[indexPath.item]
//            cell.titleLabel.text = socialApp.tagline
//            cell.companyLabel.text = socialApp.name
//            cell.imageView.sd_setImage(with: URL(string: socialApp.imageUrl))
//
//            return cell
//        default:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "smallCellId", for: indexPath) as! AppRowCell
//
//            var appGroup: AppGroup?
//            if indexPath.section == 1 {
//                appGroup = topFree
//            } else if indexPath.section == 2 {
//                appGroup = topPaid
//            } else {
//                appGroup = topMusic
//            }
//
//
//            cell.nameLabel.text = appGroup?.feed.results[indexPath.item].name
//            cell.companyLabel.text = appGroup?.feed.results[indexPath.item].artistName
//            cell.imageView.sd_setImage(with: URL(string: appGroup?.feed.results[indexPath.item].artworkUrl100 ?? ""))
//            return cell
//        }
//    }
    
}

struct AppsView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CompositionalController()
        return UINavigationController(rootViewController: controller)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
     
}

struct AppsCompositionalView_Previews: PreviewProvider {
    static var previews: some View {
        AppsView()
            .edgesIgnoringSafeArea(.all)
    }
}
