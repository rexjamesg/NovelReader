//
//  ViewController.swift
//  NovelReader
//
//  Created by Rex Lin on 2020/6/24.
//  Copyright © 2020 Rex. All rights reserved.
//

import UIKit

//TODO:
//  往右滑動預先讀取下一頁

// MARK: - ReadNovelViewController

class ReadNovelViewController: NovelContentViewController {
    private var viewModel = ReadNovelViewModel()
    private let novelCenterMenuView = NovelCenterMenuView()
    private var pageLabel = UILabel()
    // test
    var button: UIButton = .init()
    var isHorizontal: Bool = true

    var statusbarHeight: CGFloat {
        if let statusBarManager = view.window?.windowScene?.statusBarManager {
            return statusBarManager.statusBarFrame.height
        } else {
            //return view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            return UIApplication.shared.statusBarFrame.height
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentController(scrollDirection: .horizontal)
        viewModel.delegate = self
        viewModel.setTextSize(size: visibleTextAreaSize)
        setupNovelCenterMenuView()
        initPageLabel()
    }
    
    override func viewWillAppear(_: Bool) {
        viewModel.loadDefaultPage()
        setPageLabel()
    }
    
    // MARK: - UICollectionViewDataSource

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel.contentArray.count
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NovelContentCell", for: indexPath)
        if let cell = cell as? NovelContentCell {
            if viewModel.contentArray.count > indexPath.row {
                let pageItem = viewModel.contentArray[indexPath.row]
                cell.setContent(text: pageItem.content, fontSize: viewModel.fontSize, isNightMode: false)
            }

            cell.prevPageAction = { [weak self] in
                guard let self = self else { return }
                self.prevPageAction(collectionView: collectionView, indexPath: indexPath)
            }

            cell.nextPageAction = { [weak self] in
                guard let self = self else { return }
                self.nextPageAction(collectionView: collectionView, indexPath: indexPath)
            }

            cell.centerControlAction = { [weak self] in
                guard let self = self else { return }
                self.setPageSlider()
                self.novelCenterMenuView.isHidden = false
            }
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isNextPageAvailable(collectionView, didEndDisplaying: cell, forItemAt: indexPath) && !viewModel.isLoading {
            
        }
    }

    override func prevPageAction(collectionView _: UICollectionView, indexPath _: IndexPath) {
        if viewModel.currentIndex - 1 >= 0 {
            viewModel.currentIndex -= 1
            scrollToItem(row: viewModel.currentIndex, animated: true)
        } else {
            viewModel.loadPrevPage()
        }
        
        setPageLabel()
    }

    override func nextPageAction(collectionView _: UICollectionView, indexPath _: IndexPath) {
        if viewModel.currentIndex + 1 < viewModel.contentArray.count {
            viewModel.currentIndex += 1
            scrollToItem(row: viewModel.currentIndex, animated: true)
        } else {
            viewModel.loadNextChapter()
        }
        
        setPageLabel()
    }
    
    //滑動時，設定頁數
    override func didScrollPage(currentPage: Int) {
        super.didScrollPage(currentPage: currentPage)
        viewModel.setPageIndex(currentIndex: currentPage)
        setPageLabel()
    }
}

//MARK: - Private Methods
private extension ReadNovelViewController {
    
    func setupNovelCenterMenuView() {
        view.addSubview(novelCenterMenuView)
        novelCenterMenuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            novelCenterMenuView.topAnchor.constraint(equalTo: view.topAnchor),
            novelCenterMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            novelCenterMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            novelCenterMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        novelCenterMenuView.setScrollDirectionStyle(scrollDirection: viewModel.scrollDirection)
        novelCenterMenuView.isHidden = true
        novelCenterMenuView.setFontButtonSelectedStyle(tag: 1)
        novelCenterMenuView.baseCoverButton.addTarget(self, action: #selector(displayNovelCenterMenuViewAction), for: .touchUpInside)
        
        novelCenterMenuView.brightnessSlider.value = Float(UIScreen.main.brightness)
        novelCenterMenuView.brightnessSlider.addTarget(self, action: #selector(setBrightnessAction(sender:)), for: .valueChanged)
        
        novelCenterMenuView.fontSizeButtons.forEach { $0.addTarget(self, action: #selector(setFontSizeAction(sender:)), for: .touchUpInside)}
        
        novelCenterMenuView.horizontalScrollButton.addTarget(self, action: #selector(changeScrollDirectionAciton(sender:)), for: .touchUpInside)
        novelCenterMenuView.verticalScrollButton.addTarget(self, action: #selector(changeScrollDirectionAciton(sender:)), for: .touchUpInside)
        
        novelCenterMenuView.brightnessSlider.addTarget(self, action: #selector(brightnessSliderAction(sender:)), for: .touchUpInside)
        novelCenterMenuView.pageSlider.addTarget(self, action: #selector(pageSliderAction(sender:)), for: .touchUpInside)
        
        novelCenterMenuView.brightnessSlider.value = Float(UIScreen.main.brightness)
    }
    
    //Brightness only work in real device
    @objc func brightnessSliderAction(sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    
    @objc func pageSliderAction(sender: UISlider) {
        let page = round(sender.value)
        sender.value = page
        viewModel.currentIndex = Int(page)
        scrollToItem(row: viewModel.currentIndex, animated: true)
    }
    
    //設定內文捲動方式
    @objc func changeScrollDirectionAciton(sender: UIButton) {
        let scrollDirection: UICollectionView.ScrollDirection = sender.tag == 0 ? .horizontal:.vertical
        novelCenterMenuView.setScrollDirectionStyle(scrollDirection: scrollDirection)
        viewModel.scrollDirection = scrollDirection
        contentCollectionView?.removeFromSuperview()
        setContentController(scrollDirection: scrollDirection)
    }
    
    //關閉控制選單
    @objc func displayNovelCenterMenuViewAction() {
        novelCenterMenuView.isHidden = !novelCenterMenuView.isHidden
    }
    
    @objc func setBrightnessAction(sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    
    func setContentController(scrollDirection: UICollectionView.ScrollDirection) {
        let frame = CGRect(x: 0, y: statusbarHeight, width: view.frame.size.width, height: view.frame.size.height - statusbarHeight - 44)
        initContentCollection(frame: frame, scrollDirection: scrollDirection)
    }
    
    func initPageLabel() {
        let height = 20.0
        pageLabel = UILabel(frame: CGRect(x: 0, y: view.frame.size.height-height-20, width: view.frame.size.width, height: height))
        pageLabel.textColor = .black
        pageLabel.center.x = view.center.x
        pageLabel.textAlignment = .center
        view.addSubview(pageLabel)
    }
    
    func setPageLabel() {
        guard let pageItem = viewModel.getCurrentPageItem() else {
            return
        }
        let currentPage = pageItem.page+1
        let toalPage = viewModel.getTotalPage()
        pageLabel.text = "\(currentPage)/\(toalPage)"
    }
    
    //設定內文字體
    @objc func setFontSizeAction(sender: UIButton) {

        let total = Double(viewModel.getTotalPage())
        let current = Double(viewModel.currentIndex+1)
        //改變字體大小前的閱讀比例
        let originPercent = current/total

        switch sender.tag {
        case 0:
            viewModel.setFontSize(newFontSize: 18.0)
        case 1:
            viewModel.setFontSize(newFontSize: 15.0)
        case 2:
            viewModel.setFontSize(newFontSize: 12.0)
        default:
            break
        }
        
        novelCenterMenuView.setFontButtonSelectedStyle(tag: sender.tag)
        displayNovelCenterMenuViewAction()
        
        let afterTotal = Double(viewModel.getTotalPage())
        viewModel.currentIndex = Int(round(afterTotal*originPercent))-1
        scrollToItem(row: viewModel.currentIndex, animated: false)
        setPageLabel()
        
    }
    
    //設定頁數滑桿數字
    func setPageSlider() {
        novelCenterMenuView.pageSlider.minimumValue = 0
        novelCenterMenuView.pageSlider.maximumValue = Float(viewModel.getTotalPage()-1)
        novelCenterMenuView.pageSlider.value = Float(viewModel.currentIndex)
    }
}

// MARK: - ReadNovelViewController + ReadNovelDelegate

extension ReadNovelViewController: ReadNovelDelegate {
    //分割新章節文字後會在這處理
    func didSplitChapter(scrollType: ScrollType?) {
        reloadData { [weak self] in
            guard let self = self else { return }
            if let scrollType = scrollType {
                switch scrollType {
                case .previous:
                    //讀取上一章後，滑動至最後一頁
                    let totalPage = self.viewModel.getTotalPage()
                    let row = totalPage-1
                    self.viewModel.currentIndex = row
                    self.scrollToItem(row: self.viewModel.currentIndex, animated: false)
                case .next:
                    if self.viewModel.currentIndex + 1 < self.viewModel.contentArray.count {
                        self.viewModel.currentIndex += 1
                        self.scrollToItem(row: self.viewModel.currentIndex, animated: true)
                    }
                case .resetFont:
                    break
                }
            }
        }
    }
}
