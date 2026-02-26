//
//  PhotoViewController.swift
//  Project 1 Scavenger Hunt
//
//  Created by Sunny Chen on 9/1/24.
//

import UIKit

class PhotoViewController: UIViewController {
    var task: Task!

    @IBOutlet weak var photoView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.image = task.image

        // Do any additional setup after loading the view.
    }

}

