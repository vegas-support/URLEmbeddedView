//
//  OGListCell.swift
//  URLEmbeddedViewSample
//
//  Created by Taiki Suzuki on 2016/03/15.
//  Copyright © 2016年 Taiki Suzuki. All rights reserved.
//

import UIKit
import URLEmbeddedView
import MisterFusion

class OGListCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    let embeddedView = URLEmbeddedView()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.addLayoutSubview(embeddedView, andConstraints:
            embeddedView.top |+| 8,
            embeddedView.right |-| 12,
            embeddedView.left |+| 12,
            embeddedView.bottom |-| 7.5
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        embeddedView.prepareViewsForReuse()
        label.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
