//
//  ViewController.swift
//  OCR
//
//  Created by Souvik Das on 05/01/21.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet var label: UITextView!
    @IBOutlet var image: UIImageView!
    @IBOutlet var act: UIActivityIndicatorView!

    var request = VNRecognizeTextRequest(completionHandler: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        act.isHidden = true
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.masksToBounds = true
        image.layer.borderWidth = 2
        image.layer.cornerRadius = 55
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.overrideUserInterfaceStyle = .dark
    }
    
    @IBAction func didTapCamera(){
        presentPhotoActionSheet()
    }
    @IBAction func didTapReset(){
        act.isHidden = true
        image.image = UIImage(systemName: "photo")
        label.text = "Detected text will appear here"
    }
    private func recognizeText(image: UIImage?){
        var textString = ""
        request = VNRecognizeTextRequest(completionHandler: {(request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    print("duh")
                    continue
                }
                textString += "\n\(topCandidate.string)"
                DispatchQueue.main.async {
                    self.act.isHidden = true
                    self.act.stopAnimating()
                    self.label.text = textString
                }
            }
            
        })
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let img = image?.cgImage else {
                print("Nay")
                return
            }
            let handle = VNImageRequestHandler(cgImage: img, options: [:])
            try?handle.perform(requests)
        }
        
    }


}
//MARK: - PROFILE PICTURE
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: NSLocalizedString("Profile Picture", comment: "") ,
                                            message: NSLocalizedString("How would you like to select a picture?", comment: ""),
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""),
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentCamera()
                                                
                                            }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Chose Photo", comment: ""),
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
                                                
                                            }))
        
        //iPad Alert Controller
//        actionSheet.popoverPresentationController?.barButtonItem = self.tempbutton
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        act.isHidden = false
        act.startAnimating()
        self.image.image = selectedImage
        recognizeText(image: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

