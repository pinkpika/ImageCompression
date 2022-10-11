//
//  ViewController.swift
//  iOS_ImageCompression
//
//  Created by cm0620 on 2020/7/8.
//  Copyright © 2020 CMoney. All rights reserved.
//

import UIKit

/// 範例頁面
class ViewController: UIViewController {
    
    /// 目標圖片文字
    @IBOutlet weak var targetImageLabel: UILabel!
    
    /// 目標圖片
    @IBOutlet weak var targetImageView: UIImageView!
    
    /// 結果圖片文字
    @IBOutlet weak var resultImageLabel: UILabel!
    
    /// 結果圖片
    @IBOutlet weak var resultImageView: UIImageView!
    
    /// 目標圖片
    private var targetImage: UIImage?
    
    /// 目標圖片大小(KB)
    private var targetImageSize: Double?
    
    /// 圖片詳細
    private lazy var imageDetail: ImageDetailViewManager = {
        let imageDetail = ImageDetailViewManager()
        return imageDetail
    }()
    
    /// 點擊載入圖片
    @IBAction func didLoadFile(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
            let title = NSLocalizedString("請到設定頁面打開相簿權限", comment: "")
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// 點擊壓縮圖片
    @IBAction func didCompressionFile(sender: UIButton) {
        guard let targetImage = targetImage, let targetImageSize = targetImageSize else { return }
        
        let targetImageSizeS = String(format: "%.2f", targetImageSize)
        let controller = UIAlertController(title: "壓縮檔案", message: "請選擇壓縮品質", preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "q: 0.5", style: .default) { (action) in
            _ = self.setResultImage(image: targetImage, quality: 0.5)
        })
        
        controller.addAction(UIAlertAction(title: "q: 0.3", style: .default) { (action) in
            _ = self.setResultImage(image: targetImage, quality: 0.3)
        })
        
        let quality1 = 500.0 / targetImageSize
        let quality1S = String(format: "%.4f", quality1)
        controller.addAction(UIAlertAction(title: "q: 500/\(targetImageSizeS) = \(quality1S)", style: .default) { (action) in
            _ = self.setResultImage(image: targetImage, quality: CGFloat(quality1))
        })
        
        let quality2 = 300.0 / targetImageSize
        let quality2S = String(format: "%.4f", quality2)
        controller.addAction(UIAlertAction(title: "q: 300/\(targetImageSizeS) = \(quality2S)", style: .default) { (action) in
            _ = self.setResultImage(image: targetImage, quality: CGFloat(quality2))
        })
        
        controller.addAction(UIAlertAction(title: "q: 500/\(targetImageSizeS) = \(quality1S) * 3次", style: .default) { (action) in
            if let first = self.setResultImage(image: targetImage, quality: CGFloat(quality1)){
                if let second = self.setResultImage(image: first, quality: CGFloat(quality1)){
                     _ = self.setResultImage(image: second, quality: CGFloat(quality1))
                }
            }
        })
        
        controller.addAction(UIAlertAction(title: "q: 300/\(targetImageSizeS) = \(quality2S) * 3次", style: .default) { (action) in
            if let first = self.setResultImage(image: targetImage, quality: CGFloat(quality2)){
                if let second = self.setResultImage(image: first, quality: CGFloat(quality2)){
                     _ = self.setResultImage(image: second, quality: CGFloat(quality2))
                }
            }
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGesture(imageView: targetImageView)
        setGesture(imageView: resultImageView)
    }
    
    /// 設定圖片訊息
    private func setTargetImage(image: UIImage){
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        guard let newImage = UIImage(data: imageData) else { return }
        targetImageSize = Double(imageData.count) / 1024.0
        let width = image.size.width
        let height = image.size.height
        let size = String(format: "%.2f", targetImageSize ?? "未知")
        targetImageLabel.text = "width: \(width), height: \(height), size(KB): \(size)"
    }
    
    /// 設定結果圖片
    private func setResultImage(image: UIImage, quality: CGFloat) -> UIImage? {
        guard let newData = image.jpegData(compressionQuality: quality) else { return nil }
        guard let newImage = UIImage(data: newData) else { return nil }
        resultImageView.image = newImage
        let width = newImage.size.width
        let height = newImage.size.height
        let size = String(format: "%.2f", Double(newData.count) / 1024.0)
        resultImageLabel.text = "width: \(width), height: \(height), size(KB): \(size)"
        return newImage
    }

    /// 設定手勢
    private func setGesture(imageView: UIImageView?){
        if let imageView = imageView{
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didImageTap(_:)))
            gesture.numberOfTapsRequired = 1
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(gesture)
        }
    }
    
    /// 點擊圖片
    @objc func didImageTap(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView, imageView.image != nil{
            imageDetail.zoomIn(imageView: imageView)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        targetImage = image
        setTargetImage(image: image)
        dismiss(animated: true, completion: nil)
    }
}
