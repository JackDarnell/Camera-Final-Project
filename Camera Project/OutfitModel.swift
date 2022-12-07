//
//  OutfitModel.swift
//  Camera Project
//
//  Created by Jagger Denhof on 12/7/22.
//

import Foundation

struct Outfit {
    
    let imageData : Data!
    let date : Date!
    
    init(imageData: Data, date: Date) {
        self.imageData = imageData
        self.date = date
    
    }
}
