//
//  MainViewController.swift
//  Camera Project
//
//  Created by Jack Darnell on 12/7/22.
//x

import UIKit
import Spitfire
import Photos

class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    let reuseIdentifier = "ImageCell"
    var images : [UIImage] = []
    
    lazy var spitfire: Spitfire = {
            return Spitfire(delegate: self)
    }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var TimelapseButton: UIButton!
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    @IBOutlet weak var TotalImagesLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ImageCollectionView.dataSource = self
        
        TimelapseButton.setTitle("Create Timelapse", for: .normal)

    }
    
    // MARK: - Actions
    
    @IBAction func CreateTimelapsePressed(_ sender: Any) {
        TimelapseButton.setTitle("Creating...", for: .normal)
        spitfire.makeVideo(with: images, fps: Int32(20))
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameraSegue" {
            if let dest = segue.destination as? CameraViewController {
                dest.cameraDelegate = self
            }
        }
    }
    
    // MARK: - Helper Methods

    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
            requestAuthorization {
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .video, fileURL: outputURL, options: nil)
                }) { (result, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let dialogMessage = UIAlertController(title: "Saved Successfully", message: "", preferredStyle: .alert)
                            // Create OK button with action handler
                            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                self.TimelapseButton.setTitle("Create Timelapse", for: .normal)
                            })
                            
                            dialogMessage.addAction(ok)
                            self.present(dialogMessage, animated: true, completion: nil)
                        }
                        completion?(error)
                    }
                }
            }
        }
    
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized{
            completion()
        }
    }
}

// MARK: - SpitfireDelegate - timelapse implementation

extension MainViewController : SpitfireDelegate {
    
    // Update UI with timelapse creation progress
    func videoProgress(progress: Progress) {
        if (progress.isFinished) {
            DispatchQueue.main.async {
                self.TimelapseButton.setTitle("Saving...", for: .normal)
            }
        }
    }
    // Video completed creation, saves timelapse to system
    func videoCompleted(url: URL) {

        self.saveVideoToAlbum(url) { (error) in
            print(error.debugDescription)
        }
    }
    // Update UI with error
    func videoFailed(error: SpitfireError) {
        TimelapseButton.setTitle("Try again?", for: .normal)
        print(error)
    }
}

// MARK: - CollectionViewDataSource - methods for data source management

extension MainViewController : UICollectionViewDataSource {
    
    // Total cells in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    // Dequeue Cell - updates cell ImageView with image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    // Number of sections of collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - CameraViewControllerDelegate - methods for passing image captured from CameraViewController

extension MainViewController : CameraViewControllerDelegate {
    
    func imageCaptured(image: UIImage) {
        // Add image to array of images
        images.append(image)
        // Update TotalImages label
        TotalImagesLabel.text = "Total Images: \(images.count)"
        // Reload collection view to update with new image
        ImageCollectionView.reloadData()
    }
}

