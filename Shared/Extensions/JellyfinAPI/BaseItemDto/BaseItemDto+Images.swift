//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Factory
import Foundation
import JellyfinAPI
import UIKit

// TODO: figure out what to do about screen scaling with .main being deprecated
//       - maxWidth assume already scaled?

extension BaseItemDto {

    // MARK: Item Images

    func imageURL(
        _ type: ImageType,
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> URL? {
        _imageURL(type, maxWidth: maxWidth, maxHeight: maxHeight, itemID: id ?? "")
    }

    // TODO: will server actually only have a single blurhash per type?
    //       - makes `firstBlurHash` redundant
    func blurHash(_ type: ImageType) -> String? {
        guard type != .logo else { return nil }

        if let tag = imageTags?[type.rawValue], let taggedBlurHash = imageBlurHashes?[type]?[tag] {
            return taggedBlurHash
        } else if let firstBlurHash = imageBlurHashes?[type]?.values.first {
            return firstBlurHash
        }

        return nil
    }

    func imageSource(_ type: ImageType, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> ImageSource {
        _imageSource(
            type,
            maxWidth: maxWidth,
            maxHeight: maxHeight
        )
    }

    // MARK: Series Images

    func seriesImageURL(_ type: ImageType, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> URL? {
        _imageURL(
            type,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            itemID: seriesID ?? ""
        )
    }

    func seriesImageSource(_ type: ImageType, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> ImageSource {
        let url = _imageURL(
            type,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            itemID: seriesID ?? ""
        )

        return ImageSource(
            url: url,
            blurHash: nil
        )
    }

    /// This will force the creation of an image source even if it doesn't have a tag, due
    /// to episodes also retrieving series images in some areas.
    ///
    /// Underscored because it seems `unsafe` and will cause more 404s server side.
    func _forceSeriesImageSource(_ type: ImageType, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> ImageSource {
        let url = _imageURL(
            type,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            itemID: seriesID ?? "",
            force: true
        )

        return ImageSource(
            url: url,
            blurHash: nil
        )
    }

    // MARK: private

    private func _imageURL(
        _ type: ImageType,
        maxWidth: CGFloat?,
        maxHeight: CGFloat?,
        itemID: String,
        force: Bool = false
    ) -> URL? {
        let scaleWidth = maxWidth == nil ? nil : UIScreen.main.scale(maxWidth!)
        let scaleHeight = maxHeight == nil ? nil : UIScreen.main.scale(maxHeight!)

        let tag = getImageTag(for: type)

        if tag == nil && !force {
            return nil
        }

        let client = Container.userSession().client
        let parameters = Paths.GetItemImageParameters(
            maxWidth: scaleWidth,
            maxHeight: scaleHeight,
            tag: tag
        )

        let request = Paths.getItemImage(
            itemID: itemID,
            imageType: type.rawValue,
            parameters: parameters
        )

        return client.fullURL(with: request)
    }

    private func getImageTag(for type: ImageType) -> String? {
        switch type {
        case .backdrop:
            backdropImageTags?.first
        case .screenshot:
            screenshotImageTags?.first
        default:
            imageTags?[type.rawValue]
        }
    }

    private func _imageSource(_ type: ImageType, maxWidth: CGFloat?, maxHeight: CGFloat?) -> ImageSource {
        let url = _imageURL(type, maxWidth: maxWidth, maxHeight: maxHeight, itemID: id ?? "")
        let blurHash = blurHash(type)

        return ImageSource(
            url: url,
            blurHash: blurHash
        )
    }
}
