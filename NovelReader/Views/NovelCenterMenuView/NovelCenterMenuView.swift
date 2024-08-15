//
//  NovelCenterMenuView.swift
//  NovelReader
//
//  Created by Yu Li Lin on 2024/8/13.
//  Copyright © 2024 Rex. All rights reserved.
//

import UIKit

class NovelCenterMenuView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var brightnessSlider: UISlider!
    @IBOutlet var fontSizeButtons: [UIButton]!
    @IBOutlet var baseCoverButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func setFontButtonSelectedStyle(tag: Int) {
        fontSizeButtons.forEach { button in
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.layer.borderWidth = 1
            if tag == button.tag {
                button.backgroundColor = .white
                button.setTitleColor(.systemBlue, for: .normal)
            } else {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

//MARK: - Private Methods
private extension NovelCenterMenuView {
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        Bundle(for: NovelCenterMenuView.self).loadNibNamed("\(NovelCenterMenuView.self)",
                                                 owner: self,
                                                 options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
        
        fontSizeButtons.forEach { $0.layer.cornerRadius = 10.0 }
    }
}
