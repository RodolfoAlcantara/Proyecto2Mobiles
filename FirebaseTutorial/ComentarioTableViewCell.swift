//
//  ComentarioTableViewCell.swift
//  FirebaseTutorial
//
//  Created by Rodolfo Alcantara on 4/26/19.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

class ComentarioTableViewCell: UITableViewCell {
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var textFieldComentario: UITextView!
    @IBOutlet weak var lblNombre: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
