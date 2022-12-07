//
//  OutfitTableViewCell.swift
//  Camera Project
//
//  Created by Jagger Denhof on 12/7/22.
//

import UIKit

class OutfitTableViewCell: UITableViewCell {
    

    @IBOutlet weak var timestamp: UILabel!
    
    @IBOutlet weak var outfitImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
