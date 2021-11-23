//
//  ContentSpliter.swift
//  NovelReader
//
//  Created by Rex Lin on 2020/6/24.
//  Copyright © 2020 Rex. All rights reserved.
//

import UIKit

extension String {
    /**
     設定內文樣式
     - Parameter content: 內容
     - Parameter fontSize:  文字
     */
    func setContentStyle(fontSize:CGFloat, lineSpacing:CGFloat) -> NSAttributedString {
        let str = self as NSString
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.paragraphStyle : style,NSAttributedString.Key.font:font]
        let attributedText:NSAttributedString = NSAttributedString.init(string: str as String, attributes: attributes)
        return attributedText
    }
}

//計算TextView可視字元
public extension UITextView {
    var visibleRange: NSRange? {
        if let start = closestPosition(to: contentOffset) {
            if let end = characterRange(at: CGPoint(x: contentOffset.x + bounds.maxX, y: contentOffset.y + bounds.maxY))?.end {
                return NSMakeRange(offset(from: beginningOfDocument, to: start), offset(from: start, to: end))
            }
        }
        return nil
    }
    
    /**
     取得可視字串
     - Parameter content: 目前陣列其中一項小說內容
     - Returns: 整頁可視字串
     */
    func getVisibleText(content:String, font:CGFloat, lineSpacing:CGFloat) -> String {
        self.attributedText = content.setContentStyle(fontSize: font, lineSpacing: lineSpacing)
        let myNSString = content as NSString
        let visibleRange = self.visibleRange!
        let visibleText: String = myNSString.substring(with: visibleRange)
        return visibleText
    }
}

class ContentSpliter: NSObject {

    private var textView:UITextView = UITextView()
    var isNextChapter:Bool = true
    
    override init() {
        super.init()
    }
    
    func setTextSize(size:CGSize) {
        textView = UITextView.init(frame: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
    }
    
    /**
     切割文章為一頁
     **由於是利用UITextView的函示取得目前可視字串，所以需要在主執行緒執行**
     - Parameter chapter: 是否是讀取下一章
     - Parameter chapterNumber: 章節索引
     - Parameter lineSpacing: 行高
     - Parameter font: 字體大小
     */
    func splitChapter(text:String, lineSpacing:CGFloat, font:CGFloat, finished: @escaping (_ results:[String]) -> Void) {
        var content:NSString = text as NSString
        var array:[String] = []
        var index = 0
        repeat {
            let result = self.textView.getVisibleText(content: content as String, font: font, lineSpacing: lineSpacing)
            if content.length > 0 {
                content = content.replacingOccurrences(of: result as String, with: "") as NSString
                if checkSplitResult(result: result) {
                    index += 1
                }
                array.append(result)
            }
        } while (content.length > 0)
        finished(array)
    }
    
    private func checkSplitResult(result:String) -> Bool {
        let match = matches(for: "^\\s+$", in: result)
        if match.count <= 0 {
            return true
        }
        return false
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map { String(text[Range($0.range, in: text)!]) }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
