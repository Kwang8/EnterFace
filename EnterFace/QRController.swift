//
//  QRController.swift
//  EnterFace
//
//  Created by Kevin Wang on 10/24/20.
//  Copyright © 2020 Kevin Wang. All rights reserved.
//  Source @ https://www.hackingwithswift.com/example-code/media/how-to-scan-a-qr-code

import Foundation
import UIKit
import AVFoundation
import Firebase

class QRController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var session: AVCaptureSession!
    var preview: AVCaptureVideoPreviewLayer!
    var ref: DatabaseReference!
    var qrCodeFrameView: UIView?
    var roomCap = 0
    var roomMax = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        session = AVCaptureSession()
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 10
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
        
        guard let captureDevie = AVCaptureDevice.default(for: .video) else {
            return
        }
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevie)
        }
        catch {
            return
        }
        if (session.canAddInput(input)) {
            session.addInput(input)
        } else {
            failCatch()
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        
        if(session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        }
        else {
            failCatch()
            return
        }
        
        //creating preview layer (what goes on the camera)
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        session.startRunning()
    }
    
    //alert if QR Scan doesn't work
    func failCatch() {
        let alert = UIAlertController(title: "Scanning did not work", message: "try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
        session = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (session.isRunning == false) {
            session.startRunning()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (session.isRunning == false) {
            session.stopRunning()
        }
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            let barCodeObject = preview?.transformedMetadataObject(for: metadataObjects[0] as! AVMetadataMachineReadableCodeObject)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            view.bringSubviewToFront(qrCodeFrameView!)
            result(code: stringValue)
        }
    }
    func result(code: String) {
        retrieve(code: code , completion: { message in
            if (self.roomCap == 0 && self.roomMax == 0) {
                let alert = UIAlertController(title: "Scanning did not work", message: "try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
            else if (self.roomCap >= self.roomMax) {
                let alert = UIAlertController(title: "Sorry room is at max Capacity", message: "comback later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
            else {
                self.performSegue(withIdentifier: "toFace", sender: self)
            }
        })

    }
    
    func retrieve(code: String, completion: @escaping (String) -> Void) {
        var ref = Database.database().reference().child(code)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
             if let Dict = snapshot.value as? [String:Any] {
                self.roomCap = Dict["capacity"] as! Int
                self.roomMax = Dict["max"] as! Int
                completion("DONE")
            }
            completion("DONE")
        })
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

