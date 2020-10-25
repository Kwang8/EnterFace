//
//  MaskController.swift
//  EnterFace
//
//  Created by Kevin Wang on 10/24/20.
//  Copyright © 2020 Kevin Wang. All rights reserved.
// @source https://www.iowncode.com/ios-cat-and-dog-image-classifier-with-coreml-and-keras/

import Foundation
import UIKit
import Firebase
class MaskController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    var imagePicker: UIImagePickerController!
    let model = maskModel_1()
    var check = 0
    var ref: DatabaseReference!
    var roomCap = 0
    var qr = "";
    var roomName = ""
    private let trainedImageSize = CGSize(width: 299, height: 299)
    override func viewDidLoad() {
        check = 0
    }
    
    @IBAction func ScanPressed(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (check == 1) {
            performSegue(withIdentifier: "toRoom", sender: self)
            let userDefaults = UserDefaults.standard
            roomCap = userDefaults.integer(forKey: "cap") ?? -5
            roomName = userDefaults.string(forKey: "name") ?? "none"
            qr = userDefaults.string(forKey: "qr") ?? "error"
            var ref = Database.database().reference().child(qr)
            ref.child("capacity").setValue(roomCap + 1)
        }
    }
    
    //prediction of a uiImage
    func predict(image: UIImage) -> String {
        do {
            if let resizedImage = resize(image: image, newSize: trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer() {
                let prediction = try model.prediction(image: pixelBuffer)
                let value = prediction.classLabel
                print(value)
                if value == "Mask"{
                    return "Mask"
                }
                else{
                    return "No Mask"
                }
            }
        } catch {
            print("error")
        }
        return "none"
    }
    // resize's images so they can fit into a CVPixel
    func resize(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        var predictionStr = predict(image:image)
        if (predictionStr == "No Mask") {
            let alert = UIAlertController(title: "Mask worn incorrectly", message: "Please adjust mask and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
            }))
            self.present(alert, animated: true)
        }
        else {
            self.check = 1
        }
    }
}

//converts ui image into a CVPixelBuffer
extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}

