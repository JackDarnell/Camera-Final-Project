import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    // MARK: - Properties

    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    @IBOutlet weak var previewImageView: UIImageView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.setupCaptureSession()
            
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
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

    func setupCaptureSession() {
        captureSession.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get capture device")
            return
        }
        
        self.captureDevice = captureDevice

        let capturePhotoOutput = AVCapturePhotoOutput()
        
        self.capturePhotoOutput = capturePhotoOutput
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
              captureSession.canAddInput(videoDeviceInput)
        else {return}

        captureSession.addInput(videoDeviceInput)
        captureSession.addOutput(capturePhotoOutput)
    }

    func setupPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
        self.previewLayer = previewLayer

        previewLayer.frame = previewImageView.bounds
        previewImageView.layer.insertSublayer(previewLayer, at: 0)
    }

    // MARK: - Actions

    @IBAction func takePicture(_ sender: Any) {
        guard let capturePhotoOutput = capturePhotoOutput else {
            print("Failed to get the capture photo output")
            return
        }

        let photoSettings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
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
    }
}
