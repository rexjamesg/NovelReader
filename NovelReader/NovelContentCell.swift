//
//  NovelContentCell.swift
//  CatNovel
//
//  Created by Rex on 2018/7/13.
//  Copyright © 2018年 olddriver. All rights reserved.
//

import UIKit

class NovelContentCell: UICollectionViewCell {
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var novelContentLabel: UILabel!
    
    var prevPageAction: (() -> Void)?
    var nextPageAction: (() -> Void)?
    var centerControlAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setContent(text:String, fontSize:CGFloat, isNightMode:Bool) {
        let textColor:UIColor = .black
        let cellBackgroundColor:UIColor = .white
        
        backgroundColor = cellBackgroundColor
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CONTENT_LINE_SPACING
        
        let attributes = [NSAttributedString.Key.paragraphStyle : style,NSAttributedString.Key.font:UIFont.systemFont(ofSize: fontSize),NSAttributedString.Key.foregroundColor : textColor]
                        
        novelContentLabel.attributedText = NSMutableAttributedString(string: text, attributes: attributes)

        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevAction), for: .touchUpInside)
        centerButton.addTarget(self, action: #selector(centetAction), for: .touchUpInside)
    }
    
    @objc func nextAction() {
        nextPageAction?()
    }
    
    @objc func prevAction() {
        prevPageAction?()
    }
    
    @objc func centetAction() {
        centerControlAction?()
    }
    
    func lockControl(isLock:Bool) {
        prevButton.isEnabled = !isLock
        nextButton.isEnabled = !isLock
        centerButton.isEnabled = !isLock
    }    
}
