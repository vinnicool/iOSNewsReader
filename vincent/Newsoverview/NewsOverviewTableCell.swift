//
//  NewOverviewTableCell.swift
//  vincent
//
//  Created by Vincent on 10/24/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation
import UIKit

public class NewsOverviewTableCell : UITableViewCell{
    
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    public override func awakeFromNib() {
        newsImage.image = UIImage(named: "placeholder")
    }
    
    public override func prepareForReuse() {
        newsTitle.text = ""
        newsImage.image = UIImage(named: "placeholder")
        self.backgroundColor = nil
    }
}
