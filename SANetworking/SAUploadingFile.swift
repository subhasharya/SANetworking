//
//  SAUploadingFile.swift
//  SANetworking
//
//  Created by gauri on 10/29/18.
//  Copyright © 2018 gauri. All rights reserved.
//

import UIKit
import MobileCoreServices

public class SAUploadingFile: NSObject {
    public weak var delegate: SAUploadingFileDelegate?
    
    public func UploadFile(imageName: String, fileData: Data, requestUrl : URL) {
        let request = NSMutableURLRequest(url: requestUrl);
        request.httpMethod = "POST";
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: imageName, imageDataKey: fileData as Data, boundary: boundary) as Data
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            
            if error != nil {
                if let del = self.delegate {
                    del.fileUploadStatus(status: false, response: error ?? "Uploading failed" )
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 201, httpStatus.statusCode == 200 {
                if let del = self.delegate {
                    del.fileUploadStatus(status: true, response: httpStatus)
                }
            }
        }
        task.resume()
        
    }
    
    private  func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    private func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> NSData {
        var body = Data()
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        var filename = ""
        if filePathKey != "" {
            let fileArray = filePathKey?.components(separatedBy: "/")
            filename = (fileArray?.last)!
        }
        let mimetype = "multipart/form-data"
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(imageDataKey as Data)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body as NSData
    }
}

extension UIImage {
    fileprivate func resize(_ image: UIImage) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 300.0
        let maxWidth: Float = 400.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    
}

public protocol SAUploadingFileDelegate: class {
    func fileUploadStatus(status : Bool,response : Any)
}
