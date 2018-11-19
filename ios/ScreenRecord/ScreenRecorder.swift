//  Created by Giridhar on 09/06/17.
//  MIT Licence.
//  Modified By: [
//  Matt Thompson 9/14/18
//]

import Foundation
import ReplayKit
import AVKit
import Photos

@objc class ScreenRecorder: NSObject {
    var assetWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    var fileURL: URL!
    let screenRecorder = RPScreenRecorder.shared()
    let viewOverlay = WindowUtil()

    public func startRecording(withFileName fileName: String, recordingHandler: @escaping (Error?) -> Void) {
        if #available(iOS 11.0, *) {
            do {
                fileURL = URL(fileURLWithPath: ReplayFileUtil.filePath(fileName))
                assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: AVFileTypeQuickTimeMovie)
                // video
                let videoOutputSettings: Dictionary<String, Any> = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: UIScreen.main.bounds.width * UIScreen.main.scale,
                    AVVideoHeightKey: UIScreen.main.bounds.height * UIScreen.main.scale
                ]
                videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoOutputSettings)
                videoInput.expectsMediaDataInRealTime = true
                assetWriter.add(videoInput)
                // audio
                var acl = AudioChannelLayout()
                acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono
                let audioOutputSettings: Dictionary<String, Any> = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 44100.0,
                    AVEncoderBitRateKey: 64000,
                    AVChannelLayoutKey: NSData(bytes: &acl, length: MemoryLayout<AudioChannelLayout>.size)
                ]
                audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
                audioInput.expectsMediaDataInRealTime = true
                assetWriter.add(audioInput)
            } catch {
                recordingHandler(error)
            }

            // start the screen capturing
            screenRecorder.isMicrophoneEnabled = true
            screenRecorder.startCapture(handler: { (sample, bufferType, error) in
                if let error = error {
                    recordingHandler(error)
                }

                // store the video/audio samples
                if bufferType == .video && self.assetWriter.status == .unknown {
                    self.assetWriter.startWriting()
                    self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                    print("asset writer started")
                }

                if self.assetWriter.status == .failed {
                    print("Error writing screencast to file: \(self.assetWriter.status.rawValue)")
                }

                if bufferType == .video {
                    if self.videoInput.isReadyForMoreMediaData {
                        self.videoInput.append(sample)
                    }
                } else if bufferType == .audioMic && self.assetWriter.status == .writing {
                    if self.audioInput.isReadyForMoreMediaData {
                        self.audioInput.append(sample)
                    }
                }
            }, completionHandler: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        recordingHandler(error)
                    } else {
                        print("Screen capture started successfully.")
                        // handle success
                    }
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }

    public func stopRecording(handler: @escaping (Error?) -> Void) {
        if #available(iOS 11.0, *) {
            screenRecorder.stopCapture { error in
                handler(error)
                self.assetWriter.finishWriting {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.fileURL)
                    }) { saved, error in
                        if saved {
                            print("reply saved")
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}


