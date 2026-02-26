//
//  Task.swift
//  Project 1 Scavenger Hunt
//
//  Created by Sunny Chen on 9/1/24.
//

import UIKit
import CoreLocation

class Task {
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Task {
    static var mockedTasks: [Task] {
        return [
            Task(title: "Take a picture of you parked next to the same car.",
                 description: "It has to be the same exact generation car."),
            Task(title: "Fix the tire on the Mazda.",
                 description: "The Mazda has been sitting there for weeks.. Fix the tire already.."),
            Task(title: "Find a CFMOTO bike in China.",
                 description: "It's a Chinese motorcycle, there's no way you won't see one there.")
        ]
    }
}
