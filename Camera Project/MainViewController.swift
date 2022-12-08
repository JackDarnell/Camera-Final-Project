//
//  MainViewController.swift
//  Camera Project
//
//  Created by Jack Darnell on 12/7/22.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    
    let reuseIdentifier = "snapshotCell"
    let snapshots : [Snapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var snapshotImageView: UIImageView!
}
    
extension MainViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snapshots.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let snapshot = snapshots[indexPath.row]
        cell.snapshotImageView.image = UIImage(data: snapshot.image)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item + 1)
    }
}
/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/

