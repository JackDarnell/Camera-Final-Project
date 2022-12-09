//
//  MainViewController.swift
//  Camera Project
//
//  Created by Jack Darnell on 12/7/22.
//x

import UIKit
import Spitfire
import Photos

class MainViewController: UIViewController, SpitfireDelegate {
    
    @IBOutlet weak var TimelapseButton: UIButton!
    
    func videoProgress(progress: Progress) {
        
    }
    
    func videoCompleted(url: URL) {

        self.saveVideoToAlbum(url) { (error) in
            print(error.debugDescription)
            
        }
        
    }
    
    func videoFailed(error: SpitfireError) {
        TimelapseButton.setTitle("Try again?", for: .normal)
        print(error)
    }
    
    lazy var spitfire: Spitfire = {
            return Spitfire(delegate: self)
    }()
    
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    
    @IBOutlet weak var TotalImagesLabel: UILabel!
    
    let reuseIdentifier = "ImageCell"
    var images : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ImageCollectionView.dataSource = self
        self.ImageCollectionView.delegate = self
        
        TimelapseButton.setTitle("Create Timelapse", for: .normal)

    }
    
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
}


extension MainViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item + 1)
    }
    
    
    
}

extension MainViewController : CameraViewControllerDelegate {
    func imageCaptured(image: UIImage) {
        
        images.append(image)
        
        TotalImagesLabel.text = "Total Images: \(images.count)"
        
        ImageCollectionView.reloadData()
    }
}

