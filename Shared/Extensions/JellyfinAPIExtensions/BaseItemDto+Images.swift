//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import UIKit

extension BaseItemDto {

    // MARK: Item Images

    func imageURL(
        _ type: ImageType,
        maxWidth: Int? = nil,
        maxHeight: Int? = nil
    ) -> URL {
        _imageURL(type, maxWidth: maxWidth, maxHeight: maxHeight, itemID: id ?? "")
    }

    func imageURL(
        _ type: ImageType,
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> URL {
        _imageURL(type, maxWidth: Int(maxWidth), maxHeight: Int(maxHeight), itemID: id ?? "")
    }

    func blurHash(_ type: ImageType) -> String? {
        guard type != .logo else { return nil }
        if let tag = imageTags?[type.rawValue], let taggedBlurHash = imageBlurHashes?[type]?[tag] {
            return taggedBlurHash
        } else if let firstBlurHash = imageBlurHashes?[type]?.values.first {
            return firstBlurHash
        }

        return nil
    }

    func imageSource(_ type: ImageType, maxWidth: Int? = nil, maxHeight: Int? = nil) -> ImageSource {
        _imageSource(type, maxWidth: maxWidth, maxHeight: maxHeight)
    }

    func imageSource(_ type: ImageType, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> ImageSource {
        _imageSource(type, maxWidth: Int(maxWidth), maxHeight: Int(maxHeight))
    }

    // MARK: Series Images

    func seriesImageURL(_ type: ImageType, maxWidth: Int? = nil, maxHeight: Int? = nil) -> URL {
        _imageURL(type, maxWidth: maxWidth, maxHeight: maxHeight, itemID: seriesId ?? "")
    }

    func seriesImageURL(_ type: ImageType, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> URL {
        let maxWidth = maxWidth != nil ? Int(maxWidth!) : nil
        let maxHeight = maxHeight != nil ? Int(maxHeight!) : nil
        return _imageURL(type, maxWidth: maxWidth, maxHeight: maxHeight, itemID: seriesId ?? "")
    }

    func seriesImageSource(_ type: ImageType, maxWidth: Int? = nil, maxHeight: Int? = nil) -> ImageSource {
        let url = _imageURL(type, maxWidth: maxWidth, maxHeight: maxHeight, itemID: seriesId ?? "")
        return ImageSource(url: url, blurHash: nil)
    }

    func seriesImageSource(_ type: ImageType, maxWidth: CGFloat) -> ImageSource {
        seriesImageSource(type, maxWidth: Int(maxWidth))
    }

    // MARK: Fileprivate

    fileprivate func _imageURL(
        _ type: ImageType,
        maxWidth: Int?,
        maxHeight: Int?,
        itemID: String
    ) -> URL {
        let scaleWidth = maxWidth == nil ? nil : UIScreen.main.scale(maxWidth!)
        let scaleHeight = maxHeight == nil ? nil : UIScreen.main.scale(maxHeight!)
        let tag = imageTags?[type.rawValue]
        return ImageAPI.getItemImageWithRequestBuilder(
            itemId: itemID,
            imageType: type,
            maxWidth: scaleWidth,
            maxHeight: scaleHeight,
            tag: tag
        ).url
    }

    fileprivate func _imageSource(_ type: ImageType, maxWidth: Int?, maxHeight: Int?) -> ImageSource {
        let url = _imageURL(type, maxWidth: maxWidth, maxHeight: maxHeight, itemID: id ?? "")
        let blurHash = blurHash(type)
        return ImageSource(url: url, blurHash: blurHash)
    }
}

fileprivate extension Int {
    init?(_ source: CGFloat?) {
        if let source = source {
            self.init(source)
        } else {
            return nil
        }
    }
}
