


































































































# MainViewController.swift

 First import these modules:
 -  UIKit
 - Spitfire
 - Photos

After that we create three IBOutlets for the TimelapseButton, ImageCollectionView, and the TotalImagesLabel. Here is the code in action:

```
@IBOutlet  weak  var  TimelapseButton: UIButton!

@IBOutlet  weak  var  ImageCollectionView: UICollectionView!

@IBOutlet  weak  var  TotalImagesLabel: UILabel!
```
Control click each of those and drag them to the storyboard to connect them.

After that we need to connect the Reuse identifier and create the array of images that will be used later, put this code at the top of the class:

```
let  reuseIdentifier = "ImageCell"

var images : [UIImage] = []
```

After that we also want to set the spitfire delegate as self, for the multi image to video Timelapse with this code:

```
lazy var spitfire: Spitfire = {
	return Spitfire(delegate: self)
}()
```

Next lets set up our viewDidLoad function:

```
super.viewDidLoad()
self.ImageCollectionView.dataSource = self
TimelapseButton.setTitle("Create Timelapse", for: .normal)
```
The second line sets the collection view to use this class as the data source and the third line sets the Timelapse button to create Timelapse, since the text will change as a Timelapse is being created.

Next we create an action that will be run when the Timelapse button is pressed with this code:
```
@IBAction  func  CreateTimelapsePressed(_ sender: Any) {
	TimelapseButton.setTitle("Creating...", for: .normal)
	spitfire.makeVideo(with: images, fps: Int32(20))
}
```
Remember to control drag to link this to the create Timelapse button. The code will set the button title to creating and also call spitfire to make the video with the image array we set up earlier.

Next we will put some helper methods for saving the video that can be found at this link: **https://stackoverflow.com/questions/29482738/swift-save-video-from-nsurl-to-user-camera-roll**

Here is the code, paste this at the bottom of the MainViewController class :
```
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

func  requestAuthorization(completion: @escaping ()->Void) {
	if  PHPhotoLibrary.authorizationStatus() == .notDetermined {
		PHPhotoLibrary.requestAuthorization { (status) in
			DispatchQueue.main.async {
				completion()
			}
		}
	} else  if  PHPhotoLibrary.authorizationStatus() == .authorized{
		completion()
	}
}
```
We also added an UIAlertController to notify the user when the video has been saved successfully, and we include a button to close the window. This is only shown if there are no errors and starts at the line ``` let dialogMessage ```

Also be sure to add this key value pair into the info.plist file:
```
Key: Privacy - Photo Library Usage Description
Value: This app needs access to photos to save the timelapse
```
This is used for letting the user choose the apps access to the photo library.

Now lets create an extension to the MainViewController that inherits from SpitfireDelegate. The line will look like this:
```
extension  MainViewController : SpitfireDelegate {
}
```
Now we need to implement three functions as the delegate, the first being videoProgress:
```
func  videoProgress(progress: Progress) {
	if (progress.isFinished) {
		DispatchQueue.main.async {
			self.TimelapseButton.setTitle("Saving...", for: .normal)
		}
	}
}
```
This will check to see if the video is being processed, and then set the buttons text to " Saving..."

The next function we need to implement is videoCompleted:
```
func  videoCompleted(url: URL) {
	self.saveVideoToAlbum(url) { (error) in
		print(error.debugDescription)
	}
}
```
This code just calls the previous methods we got from stack overflow to save the video with the url spitfire gives us. If there are any errors it will print them to the console. 

The last function we need to implement in this extension is videoFailed that will throw a SpitfireError object in case of failure, we just print out the error and set the Timelapse button text to "Try Again?" here is the code:
```
func  videoFailed(error: SpitfireError) {
	TimelapseButton.setTitle("Try again?", for: .normal)
	print(error)
}
```

Now we just have two more extensions for the main view controller to implement, the first is UICollectionViewDataSource:
```
extension  MainViewController : UICollectionViewDataSource {
}
```
There are three functions that we need to implement in this extension, they will all be used to control the CollectionView.

The first function is numberOfItemsInSection:
```
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
	return images.count
}
```
All this does is create the number of cells based on the number of images.

the next is Deqeue cell, this creates a new cell based on the ImageCell and updates the image in the cell to the correct index of the image array:
```
func  collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
	let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
	cell.imageView.image = images[indexPath.row]
	return cell
}
```
All thats left is setting the number of sections to 1, since we will only be adding images to one section we don't need to worry about returning anything else:
```
func numberOfSections(in collectionView: UICollectionView) -> Int {
	return 1
}
```
Now here is the last extension needed for main view controller, and it is the CameraViewControllerDelagate:
```
extension  MainViewController : CameraViewControllerDelegate {
}
```
In this we use a function that will receive images taken from the camera and add them to the image array, here is the function:
```
func  imageCaptured(image: UIImage) {
	// Add image to array of images
	images.append(image)
	
	// Update TotalImages label
	TotalImagesLabel.text = "Total	Images: \(images.count)"
	
	// Reload collection view to update with new image
	ImageCollectionView.reloadData()
}
```
Now with all of that built we just need to include a segue for the camera using prepare for segue above the saveVideoToAlbum code in the MainViewController. Here is the segue:
```
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	if segue.identifier == "cameraSegue" {
		if let dest = segue.destination as? CameraViewController {
			dest.cameraDelegate = self
		}
	}
}
```
Be sure to double check your segue id in the storyboard and make sure it matches up with cameraSegue named here. 

Now you have the MainViewController code all complete!
















































































