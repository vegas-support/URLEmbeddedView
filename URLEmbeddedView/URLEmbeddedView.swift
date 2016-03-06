//
//  URLEmbeddedView.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import UIKit

public class URLEmbeddedView: UIView {
    private var URL: NSURL?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    public convenience init(url: String) {
        self.init(url: url, frame: .zero)
    }
    
    public init(url: String, frame: CGRect) {
        super.init(frame: frame)
        URL = NSURL(string: url)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
