import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: AnyObject {
    func imageCaptured(image: UIImage)
}
class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    // MARK: - Properties
    
    weak var cameraDelegate: CameraViewControllerDelegate?
    
    let session = AVCaptureSession()
    var capturePhotoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureDevice: AVCaptureDevice!

    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var previewImageView: UIImageView!

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.setupCaputure()
        
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaputure()
                    }
                }
            
            case .denied: // The user has previously denied access.
                return

            case .restricted: // The user can't grant access due to restrictions.
                return
            
        @unknown default:
            return
        }
        
    }

    // MARK: - Helper Methods
    
    func setupCaputure() {
        print("Setting up capture...")
        self.setupCaptureSession()
        self.setupPreviewLayer()
    }

    func setupCaptureSession() {
        session.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
                    print("Failed to get the camera device")
                    return
        }
        
        self.captureDevice = captureDevice
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: self.captureDevice) else {
                return
        }

        self.capturePhotoOutput = AVCapturePhotoOutput()
        
        session.addInput(captureDeviceInput)
        
        if session.canAddOutput(capturePhotoOutput) {
            session.addOutput(capturePhotoOutput)
        }
    }

    func setupPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        var bounds:CGRect
                bounds=previewImageView.layer.frame
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
       previewLayer!.bounds=bounds
       previewLayer!.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))

        
        self.previewLayer!.frame = previewImageView.bounds
        
        previewImageView.layer.insertSublayer(previewLayer!, at: 0)
        
        session.startRunning()
    }

    // MARK: - Actions

    @IBAction func takePicture(_ sender: Any) {
        guard let capturePhotoOutput = capturePhotoOutput else {
            print("Failed to get the capture photo output")
            return
        }

        let photoSettings = AVCapturePhotoSettings()
        // Call AVCapturePhotoOutput api to take picture
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    @IBAction func zoomAction(_ sender: Any) {
        guard let captureDevice = self.captureDevice else {
            print("Failed to get the capture device")
            return
        }

        do {
            try captureDevice.lockForConfiguration()
            
            let zoomFactor: CGFloat = CGFloat(truncating: zoomSlider.value as NSNumber)
            
            captureDevice.ramp(toVideoZoomFactor: zoomFactor, withRate: 5.0)
            captureDevice.unlockForConfiguration()
    } catch {
                    print("Failed to zoom in: \(error.localizedDescription)")
                }
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    @objc(captureOutput:didFinishProcessingPhoto:error:) func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Failed to capture photo: \(error!.localizedDescription)")
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to get the image data")
            return
        }

        guard let image = UIImage(data: imageData) else {
            print("Failed to create the image")
            return
        }

        // Do something with the image here...
        if let del = cameraDelegate {
            print("Camera Image Cap")
            del.imageCaptured(image: image)
        }
        _ = self.navigationController?.popViewController(animated: true)
        
    }
}
