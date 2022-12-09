//
//  MainViewController.swift
//  Camera Project
//
//  Created by Jack Darnell on 12/7/22.
//x

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    
    @IBOutlet weak var TotalImagesLabel: UILabel!
    
    let reuseIdentifier = "ImageCell"
    var images : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ImageCollectionView.dataSource = self
        self.ImageCollectionView.delegate = self

    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameraSegue" {
            if let dest = segue.destination as? CameraViewController {
                dest.cameraDelegate = self
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

