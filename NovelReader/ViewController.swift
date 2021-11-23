//
//  ViewController.swift
//  NovelReader
//
//  Created by Rex Lin on 2020/6/24.
//  Copyright © 2020 Rex. All rights reserved.
//

import UIKit

var CONTENT_LINE_SPACING:CGFloat = 15

class ViewController: NovelContentViewController {

    var novelContent:String = "Adaptivity and Layout \n\n People generally want to be able to use their favorite apps on all of their devices and in any context. In an iOS app, you can configure interface elements and layouts to automatically change shape and size on different devices, during multitasking on iPad, in split view, when the screen rotates, and more. It’s important to design an adaptable interface that provides a great experience in any environment. \n\n Device Screen Sizes and Orientations \n\n iOS devices have a variety of screen sizes and can be used in either portrait or landscape orientation. In edge-to-edge devices like iPhone X and iPad Pro, the display has rounded corners that closely match the device’s overall dimensions. Other devices — such as iPhone SE and iPad Air — have a rectangular display. \n\n If your app runs on a specific device, make sure it runs on every screen size for that device. In other words, an iPhone-only app must run on every iPhone screen size and an iPad-only app must run on every iPad screen size. \n\n Auto Layout \n\n Auto Layout is a development tool for constructing adaptive interfaces. Using Auto Layout, you can define rules (known as constraints) that govern the content in your app. For example, you can constrain a button so it’s always horizontally centered and positioned eight points below an image, regardless of the available screen space. \n\n Auto Layout automatically readjusts layouts according to the specified constraints when certain environmental variations (known as traits) are detected. You can set your app to dynamically adapt to a wide range of traits, including: \n\n * Different device screen sizes, resolutions, and color gamuts (sRGB/P3) \n * Different device orientations (portrait/landscape) \n * Split view \n * Multitasking modes on iPad \n * Dynamic Type text-size changes \n * Internationalization features that are enabled based on locale (left-to-right/right-to-left layout direction, date/time/number formatting, font variation, text length) \n * System feature availability (3D Touch) \n For developer guidance, see Auto Layout Guide and UITraitCollection. \n"
        
    //Manager
    var contentArray:[String] = []
    var spliter = ContentSpliter.init()
    var currentIndex:Int = 0
    var isLoading:Bool = false
    
    //test
    var button:UIButton = UIButton()
    var isHorizontal:Bool = true
    
    var statusbarHeight:CGFloat {
        if let statusBarManager = view.window?.windowScene?.statusBarManager {
            return statusBarManager.statusBarFrame.height
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let frame = CGRect.init(x: 0, y: statusbarHeight, width: view.frame.size.width, height: view.frame.size.height-statusbarHeight-44)
        initContentCollection(frame: frame, scrollDirection: .horizontal)
        spliter.setTextSize(size: visibleTextAreaSize)
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        spliter.splitChapter(text: novelContent, lineSpacing: 15.0, font: 15.0) { (results) in
            self.contentArray += results
            self.reloadData()
        }
    }

    //MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentArray.count
    }
       
    //MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NovelContentCell", for: indexPath)
        if let cell = cell as? NovelContentCell {
            
            if contentArray.count > indexPath.row {
                let content = contentArray[indexPath.row]
                cell.setContent(text: content, fontSize:15.0, isNightMode: false)
            }
            
            cell.prevPageAction = {
                self.prevPageAction(collectionView: collectionView, indexPath: indexPath)
            }
            
            cell.nextPageAction = {
                self.nextPageAction(collectionView: collectionView, indexPath: indexPath)
            }
            
            cell.centerControlAction = {

            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isNextPageAvailable(collectionView, didEndDisplaying: cell, forItemAt: indexPath) && !isLoading {
            print("load next available")
        }
    }
    
    override func prevPageAction(collectionView: UICollectionView, indexPath: IndexPath) {
        if currentIndex-1 >= 0 {
            scrollToItem(row: currentIndex-1, animated: true)
        }
    }
    
    override func nextPageAction(collectionView: UICollectionView, indexPath: IndexPath) {
        if currentIndex+1 < contentArray.count {
            scrollToItem(row: currentIndex+1, animated: true)
        }
    }
    
    override func setPageIndex(currentPage: Int) {
        super.setPageIndex(currentPage: currentPage)
        currentIndex = currentPage
    }

}
