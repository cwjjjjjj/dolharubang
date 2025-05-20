import Foundation
import UniformTypeIdentifiers
import UIKit
import SwiftUI


func encodeFileToBase64(fileURL: URL) -> String? {
    do {
        let fileData = try Data(contentsOf: fileURL)
        return fileData.base64EncodedString()
    } catch {
        return nil
    }
}

let formatMappings: [UTType: (mimeType: String, extension: String)] = [
    .jpeg: ("image/jpeg", "jpg"),
    .png: ("image/png", "png"),
    .heic: ("image/heic", "heic"),
    .gif: ("image/gif", "gif"),
    .tiff: ("image/tiff", "tiff")
]

func getImageDataAndFormat(_ image: UIImage) -> (data: Data, mimeType: String, extension: String)? {
    guard let cgImage = image.cgImage,
          let imageData = image.jpegData(compressionQuality: 1.0),
          let source = CGImageSourceCreateWithData(imageData as CFData, nil),
          let uti = CGImageSourceGetType(source) as String?,
          let uniformType = UTType(uti) else {
        return nil
    }
    
    // 원본 포맷에 따라 데이터 생성
    let data: Data?
    switch uniformType {
    case .jpeg:
        data = image.jpegData(compressionQuality: 0.7)
    case .png:
        data = image.pngData()
    case .heic:
        data = image.heicData()
    case .gif:
        data = imageData // GIF는 직접 변환 API 없음, 원본 데이터 사용
    case .tiff:
        data = imageToTIFFData(cgImage)
    default:
        data = image.jpegData(compressionQuality: 0.7) // 기본값으로 JPEG
    }
    
    guard let finalData = data else { return nil }
    
    // 포맷 매핑에서 MIME 타입과 확장자 가져오기
    let mapping = formatMappings[uniformType] ?? formatMappings[.jpeg]! // 기본값 JPEG
    return (data: finalData, mimeType: mapping.mimeType, extension: mapping.extension)
}

// 파일 이름 생성
func generateFileName(withExtension ext: String) -> String {
    let timestamp = Date().timeIntervalSince1970
    return "image_\(timestamp).\(ext)"
}

func imageToTIFFData(_ cgImage: CGImage) -> Data? {
    guard let data = NSMutableData() as CFMutableData?,
          let imageDestination = CGImageDestinationCreateWithData(data, UTType.tiff.identifier as CFString, 1, nil) else {
        return nil
    }
    
    CGImageDestinationAddImage(imageDestination, cgImage, nil)
    
    if CGImageDestinationFinalize(imageDestination) {
        return data as Data
    }
    return nil
}


extension UIImage {
    func heicData(quality: CGFloat = 0.7) -> Data? {
        guard let imageData = self.jpegData(compressionQuality: 1.0),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let uti = CGImageSourceGetType(source) else {
            return nil
        }
        
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, uti, 1, nil) else {
            return nil
        }
        
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        return data as Data
    }
}
