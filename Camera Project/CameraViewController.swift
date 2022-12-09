import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: AnyObject {
    func imageCaptured(image: UIImage)
}

class CameraViewController: UIViewController {

    // MARK: - Properties
    
    weak var cameraDelegate: CameraViewControllerDelegate?
    
    let session = AVCaptureSession()
    var capturePhotoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureDevice: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    
    // MARK: - Outlets

    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var previewImageView: UIImageView!

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var valid = false
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                valid = true
        
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        valid = true
                    }
                }
            
            case .denied: // The user has previously denied access.
                return

            case .restricted: // The user can't grant access due to restrictions.
                return
            
        @unknown default:
            return
        }
        // Once authorization valid
        if valid {
                self.setupCaputure()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session.stopRunning()
    }

    // MARK: - Capture Setup
    
    func setupCaputure() {
        self.setupCaptureSession()
        self.setupPreviewLayer()
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)

        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }

        captureDevice = frontCamera
        
    }

    func setupCaptureSession() {
        session.sessionPreset = .photo
        
        setupDevice()
        
        guard let captureDevice = self.captureDevice else {
            return
        }
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
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
        
        let bounds:CGRect = previewImageView.layer.frame
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer!.bounds = bounds
        previewLayer!.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))

        self.previewLayer!.frame = previewImageView.bounds
        
        previewImageView.layer.insertSublayer(previewLayer!, at: 0)
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
        
    }

    // MARK: - Actions
    
    @IBAction func flipCamera(_ sender: Any) {
        // Get current input
        guard let input = session.inputs.first else { return }

        // Remove current input
        session.removeInput(input)

        // Get new input
        let newCamera = (captureDevice == backCamera) ? frontCamera : backCamera

        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera!)
            session.addInput(newInput)
            captureDevice = newCamera
        } catch {
            print(error)
        }
    }

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
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    
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
        if let del = cameraDelegate {
            print("Camera Image Cap")
            del.imageCaptured(image: image)
        }
        _ = self.navigationController?.popViewController(animated: true)
        
    }
}
