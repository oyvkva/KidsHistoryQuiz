//
//  CategoryCell.swift
//  Quiz App Template
//
//  Created by Oyvind Kvanes on 1/12/15.
//  Copyright © 2015 Kvanes AS. All rights reserved.
//


import UIKit

class CategoryCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var topsubtitleLabel: UILabel!
    @IBOutlet var bottomsubtitleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
