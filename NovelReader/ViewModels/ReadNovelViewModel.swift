//
//  ReadNovelViewModel.swift
//  NovelReader
//
//  Created by Yu Li Lin on 2024/8/13.
//  Copyright © 2024 Rex. All rights reserved.
//

import Foundation

// MARK: - ReadNovelViewModel

class ReadNovelViewModel {
    //MARK: - Public Properties
    weak var delegate: ReadNovelDelegate?
    var lineSpacing: CGFloat = 15.0
    var fontSize: CGFloat = 15.0
    
    //MARK: - Private Properties
    private(set) var contentArray: [PageItem] = []
    private(set) var chapterArray: [ChapterItem] = []
    var currentIndex: Int = 0
    var currentChapter: Int {
        return getCurrentPageItem()?.chapter ?? 0
    }
    private(set) var isLoading: Bool = false
    private var spliter = ContentSpliter()

    init() {
        let chapterOne = ChapterItem(content: """
                                     輕裝，重擊，
                                     M3 出招。
                                     MacBook Air 上陣，工作玩樂一路順。有了 M3 晶片，全球最受歡迎的筆電實力更犀利，再搭配最長達 18 小時的電池續航力1，這款超輕便好帶的 MacBook Air 哪裡都能去，做什麼都超快。
                                     全新 MacBook Air 配備 M3 晶片 NT$35,900 起
                                     MacBook Air 配備 M2 晶片 NT$32,900 起
                                      使用 AR 看看
                                     方便攜帶的設計
                                     為行動派
                                     而設計。

                                     超輕巧且厚度僅約一公分，MacBook Air 不僅能輕易融入你的生活，更是以地球為念而打造。配備 M3 的 MacBook Air 創下 Apple 先例，製造所採用的再生物料達 50% 之多。此外，所有 MacBook Air 筆電也都具備耐用的再生鋁金屬機身。


                                     13 吋
                                     顯示器
                                     15 吋
                                     顯示器
                                     兩款完美尺寸，攜帶都方便。 13 吋機型是終極的隨身筆電；15 吋機型則提供更寬廣的螢幕空間，同時處理多項任務也游刃有餘2。
                                      使用 AR 看看 13 吋 MacBook Air
                                      使用 AR 看看 15 吋 MacBook Air
                                     四款色系，都是天際美色。 各個選項都絕美，各自備有顏色相襯的 MagSafe 充電線。
                                     顏色選擇器

                                     午夜色

                                     星光色

                                     太空灰色

                                     銀色

                                     """,
                                     chapterIndex: 0,
                                     hasNextChapter: true,
                                     hasPrevChapter: false)

        chapterArray.append(chapterOne)

        let chapterTwo = ChapterItem(content: "Adaptivity and Layout \n\n People generally want to be able to use their favorite apps on all of their devices and in any context. In an iOS app, you can configure interface elements and layouts to automatically change shape and size on different devices, during multitasking on iPad, in split view, when the screen rotates, and more. It’s important to design an adaptable interface that provides a great experience in any environment. \n\n Device Screen Sizes and Orientations \n\n iOS devices have a variety of screen sizes and can be used in either portrait or landscape orientation. In edge-to-edge devices like iPhone X and iPad Pro, the display has rounded corners that closely match the device’s overall dimensions. Other devices — such as iPhone SE and iPad Air — have a rectangular display. \n\n If your app runs on a specific device, make sure it runs on every screen size for that device. In other words, an iPhone-only app must run on every iPhone screen size and an iPad-only app must run on every iPad screen size. \n\n Auto Layout \n\n Auto Layout is a development tool for constructing adaptive interfaces. Using Auto Layout, you can define rules (known as constraints) that govern the content in your app. For example, you can constrain a button so it’s always horizontally centered and positioned eight points below an image, regardless of the available screen space. \n\n Auto Layout automatically readjusts layouts according to the specified constraints when certain environmental variations (known as traits) are detected. You can set your app to dynamically adapt to a wide range of traits, including: \n\n * Different device screen sizes, resolutions, and color gamuts (sRGB/P3) \n * Different device orientations (portrait/landscape) \n * Split view \n * Multitasking modes on iPad \n * Dynamic Type text-size changes \n * Internationalization features that are enabled based on locale (left-to-right/right-to-left layout direction, date/time/number formatting, font variation, text length) \n * System feature availability (3D Touch) \n For developer guidance, see Auto Layout Guide and UITraitCollection. \n",
                                     chapterIndex: 1,
                                     hasNextChapter: false,
                                     hasPrevChapter: true)

        chapterArray.append(chapterTwo)
    }

    func setTextSize(size: CGSize) {
        spliter.setTextSize(size: size)
    }

    func getCurrentChapterItem() -> ChapterItem? {
        if chapterArray.count > currentChapter {
            return chapterArray[currentChapter]
        }
        return nil
    }
    
    func getCurrentPageItem() -> PageItem? {
        if contentArray.count > currentIndex {
            return contentArray[currentIndex]
        }
        return nil
    }

    func getTotalPage() -> Int {
        let chapter = contentArray[currentIndex].chapter
        return contentArray.filter { $0.chapter == chapter }.count
    }

    func setPageIndex(currentIndex: Int) {
        self.currentIndex = currentIndex
    }

    //讀取預設章節
    func loadDefaultPage() {
        getPageItems(currentChapter: 1) { [weak self] results in
            guard let self = self else { return }
            self.contentArray.append(contentsOf: results)
            self.delegate?.didSplitChapter(scrollType: nil)
        }
    }

    func loadNextChapter() {
        guard let currentChapterItem = getCurrentChapterItem() else {
            return
        }
        
        if !currentChapterItem.hasNextChapter {
            return
        }
        
        guard let pageItem = getCurrentPageItem() else {
            return
        }
        
        let nextChapter = pageItem.chapter+1
        
        getPageItems(currentChapter: nextChapter, completion: { [weak self] results in
            guard let self = self else { return }
            self.contentArray.append(contentsOf: results)
            self.delegate?.didSplitChapter(scrollType: .next)
        })
    }

    func loadPrevPage() {
        guard let currentChapterItem = getCurrentChapterItem() else {
            return
        }
        
        if !currentChapterItem.hasPrevChapter {
            return
        }
            
        guard let pageItem = getCurrentPageItem() else {
            return
        }
        
        let prevChater = pageItem.chapter-1
        
        getPageItems(currentChapter: prevChater) { [weak self] results in
            guard let self = self else { return }
            self.contentArray.insert(contentsOf: results, at: 0)
            self.delegate?.didSplitChapter(scrollType: .previous)
        }
    }
    
    func setFontSize(newFontSize: CGFloat) {
        let chapter = currentChapter
        currentIndex = 0
        fontSize = newFontSize
        contentArray.removeAll()
        getPageItems(currentChapter: chapter) { [weak self] results in
            guard let self = self else { return }
            self.contentArray.append(contentsOf: results)
            self.delegate?.didSplitChapter(scrollType: nil)
        }
    }
}

//MARK: - Private Methods
private extension ReadNovelViewModel {
    func getPageItems(currentChapter: Int, completion: @escaping (_ results: [PageItem]) -> Void) {
        let chapter = chapterArray[currentChapter]
        spliter.splitChapter(text: chapter.content, lineSpacing: lineSpacing, font: fontSize) { results in
            var temp = [PageItem]()
            for (index, result) in results.enumerated() {
                let pageItem = PageItem(chapter: currentChapter, page: index, content: result)
                temp.append(pageItem)
            }
            completion(temp)
        }
    }
}
