//
//  PairDetailDateViewView.swift
//  cybexMobile
//
//  Created DKM on 2018/10/17.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class PairDetailDateViewView: CybexBaseView {
    
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var baseAmount: UILabel!
    @IBOutlet weak var changeAmount: UILabel!
    @IBOutlet weak var change: UILabel!
    
    var base_name : String = ""
    var quote_name : String = ""
    
    enum Event:String {
        case PairDetailDateViewViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.PairDetailDateViewViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}