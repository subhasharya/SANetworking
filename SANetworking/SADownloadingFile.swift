//
//  SADownloadingFile.swift
//  SANetworking
//
//  Created by gauri on 10/29/18.
//  Copyright © 2018 gauri. All rights reserved.
//

import UIKit
import MobileCoreServices

public class SADownloadingFile: NSObject,URLSessionDownloadDelegate {
    public weak var delegate : SADownloadingFileDelegate?
    var defaultSession: URLSession?
    var downloadTask: URLSessionDownloadTask?
    var url : URL?
    
    public func startDownloading (url:URL) {
        self.url = url
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        defaultSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        downloadTask = defaultSession?.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    public func downloadingCancel() {
        downloadTask?.cancel()
    }
    
    // MARK:- URLSessionDownloadDelegate
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl!.appendingPathComponent(url!.lastPathComponent)
        let dataFromURL = NSData(contentsOf: location)
        dataFromURL?.write(to: destinationUrl, atomically: true)
        
        if let del = delegate {
            del.downloadedFileStatus(status: true, response: location)
        }
    }
    
    private func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let del = delegate {
            del.downloadedFile(byteWritten: Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))
        }
    }
    
    private func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        downloadTask = nil
        if (error != nil) {
            if let del = delegate {
                del.downloadedFileStatus(status: false, response: error ?? "Downloading failed")
            }
        }
    }
    
}


public protocol SADownloadingFileDelegate : class {
    func downloadedFile(byteWritten : Float)
    func downloadedFileStatus(status : Bool,response: Any)
}
