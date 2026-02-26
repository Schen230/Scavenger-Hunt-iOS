//
//  TaskDetailViewController.swift
//  Project 1 Scavenger Hunt
//
//  Created by Sunny Chen on 9/1/24.
//

import UIKit
import MapKit
import PhotosUI
import ImageIO
import CoreLocation

class TaskDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet private weak var completedImageView: UIImageView!
    @IBOutlet private weak var completedLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var attachPhotoButton: UIButton!
    @IBOutlet weak var viewPhoto: UIButton!
    @IBOutlet weak var openCamera: UIButton!
    
    // MapView outlet
    @IBOutlet private weak var mapView: MKMapView!
    var task: Task!
    var locationManager: CLLocationManager?
    var locationAuthorizationCompletion: ((Bool) -> Void)?
    var capturedLocation: CLLocation?
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()

        // Register custom annotation view
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)

        // Set mapView delegate
        mapView.delegate = self

        // UI Candy
        mapView.layer.cornerRadius = 12


        updateUI()
        updateMapView()
    }

    func configureLocationManager() {
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        } else {
            print("Location authorization denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    /// Configure UI for the given task
    private func updateUI() {
        titleLabel.text = task.title
        descriptionLabel.text = task.description

        let completedImage = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")

        // calling `withRenderingMode(.alwaysTemplate)` on an image allows for coloring the image via it's `tintColor` property.
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = task.isComplete ? "Complete" : "Incomplete"

        let color: UIColor = task.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color

        mapView.isHidden = !task.isComplete
        attachPhotoButton.isHidden = task.isComplete
        viewPhoto.isHidden = !task.isComplete
        openCamera.isHidden = task.isComplete
    }

    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        // If authorized, show photo picker, otherwise request authorization.
        // If authorization denied, show alert with option to go to settings to update authorization.
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            // Request photo library access
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    // The user authorized access to their photo library
                    // show picker (on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert (on main thread)
                    DispatchQueue.main.async {
                        // Helper method to show settings alert
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            // Show photo picker
            presentImagePicker()
        }
    }

    private func presentImagePicker() {
        // Create a configuration object
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker.
        present(picker, animated: true)
    }
    
    @IBAction func didTapOpenCameraButton(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available on this device.")
            // Handle the case where the camera is not available
            return
    }
        capturedLocation = currentLocation
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        present(imagePickerController, animated: true, completion: nil)

    }

    func updateMapView() {
        // Make sure the task has image location.
        guard let imageLocation = task.imageLocation else { return }

        // Get the coordinate from the image location. This is the latitude / longitude of the location.
        // https://developer.apple.com/documentation/mapkit/mkmapview
        let coordinate = imageLocation.coordinate

        // Set the map view's region based on the coordinate of the image.
        // The span represents the maps's "zoom level". A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)

        // Add an annotation to the map view based on image location.
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

// TODO: Conform to PHPickerViewControllerDelegate + implement required method(s)

// TODO: Conform to MKMapKitDelegate + implement mapView(_:viewFor:) delegate method.

// Helper methods to present various alerts
extension TaskDetailViewController {

    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    /// Show an alert for the given error
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}


extension TaskDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // Dismiss the picker
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
        }
        
        // Get the selected image asset (we can grab the 1st item in the array since we only allowed a selection limit of 1)
        let result = results.first
        
        // Get image location
        // PHAsset contains metadata about an image or video (ex. location, size, etc.)
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }
        
        print("📍 Image location coordinate: \(location.coordinate)")
        
        // Make sure we have a non-nil item provider
        guard let provider = result?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            // Handle any errors
            if let error = error {
                DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
                
            }
            
            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else { return }
            
            print("🌉 We have an image!")
            
            // UI updates should be done on main thread, hence the use of `DispatchQueue.main.async`
            DispatchQueue.main.async { [weak self] in
                
                // Set the picked image and location on the task
                self?.task.set(image, with: location)
                
                // Update the UI since we've updated the task
                self?.updateUI()
                
                // Update the map view since we now have an image an location
                self?.updateMapView()
            }
        }
    }
    
    func capturePhoto() {
        guard let currentLocation = locationManager?.location else {
            print("Location not available")
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        
        // Save the location data for use after the photo is taken
        self.capturedLocation = currentLocation
        
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Dismiss the picker
        picker.dismiss(animated: true, completion: nil)
        
        // Get the captured image
        guard let image = info[.originalImage] as? UIImage else {
            print("Error: Could not get the image from the picker.")
            return
        }
        saveImageToPhotoLibrary(image, location: capturedLocation)
    }
    
    func saveImageToPhotoLibrary(_ image: UIImage, location: CLLocation?) {
        // Convert image to data
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Error: Could not convert image to data.")
            return
        }
        
        // Create an asset with metadata
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            request.addResource(with: .photo, data: imageData, options: options)
            if let location = location {
                request.location = location
            }
        }, completionHandler: { success, error in
            if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            } else {
                print("Image successfully saved to photo library with location metadata")
            }
        })
    }

    
    func fetchSavedImageMetadata() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo library access not authorized")
                return
            }
            
            // Fetch the most recent image asset from the library
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            guard let asset = fetchResult.firstObject else {
                print("No image asset found")
                return
            }
            
            // Retrieve the location metadata from the image
            if let location = asset.location {
                print("Image location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                // You can now use this location with your task
                // self.task.set(image, with: location)
            } else {
                print("No location metadata found in the image")
            }
        }
    }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        func getCurrentLocation() -> CLLocation? {
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            return locationManager.location
        }
        
    func getLocationFromImage(image: UIImage) -> CLLocation? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Error: Could not convert image to data.")
            return nil
        }
        
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, options) else {
            print("Error: Could not create image source.")
            return nil
        }
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, options) as? [CFString: Any] else {
            print("Error: Could not get image properties.")
            return nil
        }
        guard let gpsData = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] else {
            print("No GPS data found in image.")
            return nil
            }
        if let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
           let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
            let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef] as? String,
            let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef] as? String {
                
            let latitudeMultiplier = latitudeRef == "N" ? 1.0 : -1.0
            let longitudeMultiplier = longitudeRef == "E" ? 1.0 : -1.0
            
            let location = CLLocation(
                latitude: latitude * latitudeMultiplier,
                longitude: longitude * longitudeMultiplier
            )
                
                return location
            }
            
            return nil
        }
    
    func checkLocationAuthorization(completion: @escaping (Bool) -> Void) {
        let locationManager = CLLocationManager()
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Delay the completion until after the user responds to the authorization request
            locationManager.delegate = self
            self.locationAuthorizationCompletion = completion
            
        case .restricted, .denied:
            showLocationServicesDisabledAlert()
            completion(false)
            
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
            
        @unknown default:
            completion(false)
        }
    }
    func showLocationServicesDisabledAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services in Settings to allow this app to include GPS data in photos.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }

    }

extension TaskDetailViewController: MKMapViewDelegate {
    // Implement mapView(_:viewFor:) delegate method.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Dequeue the annotation view for the specified reuse identifier and annotation.
        // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
        // 💡 This is very similar to how we get and prepare cells for use in table views.
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation) as? TaskAnnotationView else {
            fatalError("Unable to dequeue TaskAnnotationView")
        }

        // Configure the annotation view, passing in the task's image.
        annotationView.configure(with: task.image)
        return annotationView
    }
    
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Segue to Detail View Controller
     if segue.identifier == "PhotoSegue" {
         if let photoViewController = segue.destination as? PhotoViewController {
             photoViewController.task = task
          }
      }
  }
}


