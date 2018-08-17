//
//  PS_BarCode_ViewController.swift
//  MyScanner
//
//  Created by Manjunath Shivakumara on 20/12/17.
//  Copyright © 2017 Manjunath Shivakumara. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeDelegate {
    func barcodeRead(barcode: String)
}

class PS_BarCode_ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    var delegate: BarcodeDelegate?
    
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet var barMessageLabel:UILabel!
    @IBOutlet var apptentiveBtn:UIButton!
    
    @IBOutlet var scanView:UIView!
    var qrCodeFrameView : UIView!
    var captureSession = AVCaptureSession()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        barMessageLabel.text = "Code not detected"
        self .setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device) else {
                return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = scanView.bounds
        
        scanView.layer.addSublayer(previewLayer)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8 , .code39 , .code93, .code128 , .code39Mod43, .upce, .pdf417, .aztec, .dataMatrix]
        } else {
            print("Could not add metadata output")
        }
        
        view.bringSubview(toFront: barMessageLabel)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // This is the delegate's method that is called when a code is read
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            barMessageLabel.text = "Code not detected"
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        for metadata in metadataObjects {
            
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj)
            
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let readableObject = metadata as? AVMetadataMachineReadableCodeObject,
                let code = readableObject.stringValue {
                dismiss(animated: true)
                delegate?.barcodeRead(barcode: code)
                
                if metadataObj.stringValue != nil {
                    barMessageLabel.text = code
                    
                }
                print("code - \(code)")
                print("code Type - \(readableObject.type)")
            }
        }
    }
}
