//
//  QRReaderViewController.swift
//  ARQR
//
//  Created by aboiko on 21/02/2018.
//  Copyright © 2018 Reinvently. All rights reserved.
//

import UIKit
import AVKit

class QRReaderViewController: UIViewController {
    //UIView
    @IBOutlet var hintLabel: UILabel!
    
    //AVKit
    var captureSession: AVCaptureSession! = nil
    var videoPreviewLayer: AVCaptureVideoPreviewLayer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! setUpCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restoreCaptureSessionIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopCaptureSession()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QRReaderViewController {
    private func setUpCaptureSession() throws {
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            throw NSError(domain:"", code: 0)
        }
        captureSession = AVCaptureSession()
        
        let captureInput = try AVCaptureDeviceInput(device: captureDevice)
        let captureOutput = AVCaptureMetadataOutput()
        
        guard captureSession.canAddInput(captureInput),
              captureSession.canAddOutput(captureOutput) else {
             throw NSError(domain:"", code: 0)
        }
        
        captureSession.addInput(captureInput)
        captureSession.addOutput(captureOutput)
        
        captureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = self.view.bounds
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
    }
    
    private func restoreCaptureSessionIfNeeded() {
        if captureSession.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    private func stopCaptureSession() {
        captureSession.stopRunning()
    }
}

extension QRReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if  let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let qrCodeStringRepresentation = metadataObject.stringValue {
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print(qrCodeStringRepresentation)
            handle(qrCode: qrCodeStringRepresentation)
            
        }
    }
}

extension QRReaderViewController {
    private func handle(qrCode: String) {
        stopCaptureSession()
        performSegue(withIdentifier: "ShowProduct", sender: qrCode)
    }
}
