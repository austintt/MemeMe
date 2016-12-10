//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Austin Tooley on 12/10/16.
//  Copyright © 2016 Tooley. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var memeImage: UIImageView!
    var savedMeme: Meme?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let meme = savedMeme {
            memeImage.image = meme.memedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
}
