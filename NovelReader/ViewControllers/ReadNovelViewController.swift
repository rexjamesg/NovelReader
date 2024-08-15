//
//  ViewController.swift
//  NovelReader
//
//  Created by Rex Lin on 2020/6/24.
//  Copyright © 2020 Rex. All rights reserved.
//

import UIKit

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
            return UIApplication.shared.statusBarFrame.height
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentController()
        viewModel.delegate = self
        viewModel.setTextSize(size: visibleTextAreaSize)
        setupNovelCenterMenuView()
        initPageLabel()
    }
    
    override func viewWillAppear(_: Bool) {
        viewModel.loadDefaultPage()
        setPabeLabel()
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
        
        setPabeLabel()
    }

    override func nextPageAction(collectionView _: UICollectionView, indexPath _: IndexPath) {
        if viewModel.currentIndex + 1 < viewModel.contentArray.count {
            viewModel.currentIndex += 1
            scrollToItem(row: viewModel.currentIndex, animated: true)
        } else {
            viewModel.loadNextChapter()
        }
        
        setPabeLabel()
    }
    
    //滑動時，設定頁數
    override func didScrollPage(currentPage: Int) {
        super.didScrollPage(currentPage: currentPage)
        viewModel.setPageIndex(currentIndex: currentPage)
        setPabeLabel()
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
        
        novelCenterMenuView.isHidden = true
        novelCenterMenuView.setFontButtonSelectedStyle(tag: 1)
        novelCenterMenuView.baseCoverButton.addTarget(self, action: #selector(displayNovelCenterMenuViewAction), for: .touchUpInside)
        
        novelCenterMenuView.brightnessSlider.value = Float(UIScreen.main.brightness)
        novelCenterMenuView.brightnessSlider.addTarget(self, action: #selector(setBrightnessAction(sender:)), for: .valueChanged)
        
        novelCenterMenuView.fontSizeButtons.forEach { $0.addTarget(self, action: #selector(setFontSizeAction(sender:)), for: .touchUpInside)}
    }
    
    @objc func displayNovelCenterMenuViewAction() {
        novelCenterMenuView.isHidden = !novelCenterMenuView.isHidden
    }
    
    @objc func setBrightnessAction(sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    
    func setContentController() {
        let frame = CGRect(x: 0, y: statusbarHeight, width: view.frame.size.width, height: view.frame.size.height - statusbarHeight - 44)
        initContentCollection(frame: frame, scrollDirection: .horizontal)
    }
    
    func initPageLabel() {
        let height = 20.0
        pageLabel = UILabel(frame: CGRect(x: 0, y: view.frame.size.height-height-20, width: view.frame.size.width, height: height))
        pageLabel.textColor = .black
        pageLabel.center.x = view.center.x
        pageLabel.textAlignment = .center
        view.addSubview(pageLabel)
    }
    
    func setPabeLabel() {
        guard let pageItem = viewModel.getCurrentPageItem() else {
            return
        }
        let currentPage = pageItem.page+1
        let toalPage = viewModel.getTotalPage()
        pageLabel.text = "\(currentPage)/\(toalPage)"
    }
    
    //設定內文字體
    @objc func setFontSizeAction(sender: UIButton) {
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
