//
//  NovelContentViewController.swift
//  NovelReader
//
//  Created by Rex Lin on 2020/6/29.
//  Copyright © 2020 Rex. All rights reserved.
//

import UIKit

class NovelContentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var contentCollectionView:UICollectionView?
    private var cellSize:CGSize = CGSize.zero
    ///預先載入
    var preloadLimit:Int = 3
    
    var visibleTextAreaSize:CGSize {
        return CGSize.init(width: cellSize.width-30, height: cellSize.height-20)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
    }
    
    func initContentCollection(frame:CGRect,scrollDirection:UICollectionView.ScrollDirection) {
        let cellWidth:CGFloat = frame.size.width
        let cellHeight:CGFloat = frame.size.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = scrollDirection
        cellSize = CGSize(width: cellWidth, height: cellHeight)//cell item 大小
        layout.itemSize = cellSize
        
        contentCollectionView = UICollectionView.init(frame: frame, collectionViewLayout: layout)
        contentCollectionView?.delegate = self
        contentCollectionView?.dataSource = self
        contentCollectionView?.backgroundColor = .white
        contentCollectionView?.showsVerticalScrollIndicator = false
        contentCollectionView?.showsHorizontalScrollIndicator = false
        
        if scrollDirection == .horizontal {
            contentCollectionView?.isPagingEnabled = true
        } else {
            contentCollectionView?.isPagingEnabled = false
        }
        
        contentCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        registCellNibs(identifiers: ["NovelContentCell"])
        view.addSubview(contentCollectionView!)
        view.sendSubviewToBack(contentCollectionView!)
    }
    
    func registCellNibs(identifiers:[String]) {
        for identifier in identifiers {
            let nib = UINib.init(nibName: identifier, bundle: nil)
            contentCollectionView?.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }

    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    ///檢查目前的Cell數量是否能夠繼續讀取下一頁
    func isNextPageAvailable(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> Bool {
        let visibleItems = collectionView.indexPathsForVisibleItems
        if let first = visibleItems.first?.row {
            let total = collectionView.numberOfItems(inSection: indexPath.section)
            let visable = collectionView.visibleCells.count
            if (total - (visable+first)) < preloadLimit && total != 0 {
                return true
            }
        }
        return false
    }
    
    /**
     滾動到指定頁面
     - Parameter row: 需要的頁數
     - Parameter animation: 是否要有滾動的動畫
     */
    func scrollToItem(row:Int, animated:Bool) {
        if let scrollDirection = scrollDirection {
            if scrollDirection == .horizontal {
                contentCollectionView?.scrollToItem(at: IndexPath.init(row: row, section: 0), at: .left, animated: animated)
            } else {
                contentCollectionView?.scrollToItem(at: IndexPath.init(row: row, section: 0), at: .top, animated: animated)
            }
        }
    }
    
    ///直式或橫式
    var scrollDirection:UICollectionView.ScrollDirection? {
        if let layout = contentCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.scrollDirection
        }
        return nil
    }
    
    ///刷新網格列表
    func reloadData(finished: (()->Void)?=nil) {
        DispatchQueue.main.async {
            self.contentCollectionView?.reloadData()
            if finished != nil {
                finished!()
            }
        }
    }
    
    /**
     下一頁按鈕功能
     - Parameter collectionView: 當前的網格列表
     - Parameter indexPath: 列表索引值
     */
    func prevPageAction(collectionView: UICollectionView, indexPath: IndexPath) {
        
    }
    
    /**
    上一頁按鈕功能
    - Parameter collectionView: 當前的網格列表
    - Parameter indexPath: 列表索引值
    */
    func nextPageAction(collectionView: UICollectionView, indexPath: IndexPath) {
        
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let scrollDirection = scrollDirection {
            var pageSize = scrollView.frame.size.width
            var scrollOffset = scrollView.contentOffset.x
            if scrollDirection == .vertical {
                pageSize = scrollView.frame.size.height
                scrollOffset = scrollView.contentOffset.y
            }
            let currentPage:CGFloat = ((scrollOffset - pageSize / 2) / pageSize) + 1;
            var didChangePage:Bool = false
            if scrollDirection == .horizontal {
                //判斷完整換頁
                if (Double(currentPage)*10).truncatingRemainder(dividingBy: 2.0) == 1 {
                    didChangePage = true
                } else {
                    didChangePage = false
                }
            } else {
                //判斷完整換頁
                if (Double(currentPage)*10).truncatingRemainder(dividingBy: 2.0) == 1 {
                    didChangePage = true
                } else {
                    didChangePage = false
                }
            }
                        
            if didChangePage {
                changePageAction()
            }
        }
    }
    
    ///計算頁數
    func changePageAction() {
        guard let scrollDirection = scrollDirection, let scrollView = contentCollectionView else {
            return
        }
        
        var offset = scrollView.contentOffset.y
        var baseSize = scrollView.frame.size.height
        
        if scrollDirection == .horizontal {
            offset = scrollView.contentOffset.x
            baseSize = scrollView.frame.size.width
        }
        
        let page = lround(Double(offset/baseSize))
        
        if page >= 0 {
            setPageIndex(currentPage: Int(page))
        } else {
            setPageIndex(currentPage: 0)
        }
    }
    
    func setPageIndex(currentPage:Int) {
        
    }
    
    ///變更網格滾動列表方向
    func resetScrollDirection(scrollDirection:UICollectionView.ScrollDirection) {
        if let collectionView = contentCollectionView {
            let frame = collectionView.frame
            contentCollectionView?.removeFromSuperview()
            initContentCollection(frame: frame, scrollDirection: scrollDirection)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
