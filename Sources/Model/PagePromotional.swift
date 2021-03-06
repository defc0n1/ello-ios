////
///  PagePromotional.swift
//

import SwiftyJSON


public let PagePromotionalVersion = 1

public final class PagePromotional: JSONAble {

    public let id: String
    public let header: String
    public let subheader: String
    public let ctaCaption: String
    public let ctaURL: NSURL?
    public let image: Asset?
    public var tileURL: NSURL? { return image?.xhdpi?.url }

    // links
    public var user: User? { return getLinkObject("user") as? User }

    public init(
        id: String,
        header: String,
        subheader: String,
        ctaCaption: String,
        ctaURL: NSURL?,
        image: Asset?
    ) {
        self.id = id
        self.header = header
        self.subheader = subheader
        self.ctaCaption = ctaCaption
        self.ctaURL = ctaURL
        self.image = image
        super.init(version: PagePromotionalVersion)
    }

    public required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        header = decoder.decodeKey("header")
        subheader = decoder.decodeKey("subheader")
        ctaCaption = decoder.decodeKey("ctaCaption")
        ctaURL = decoder.decodeOptionalKey("ctaURL")
        image = decoder.decodeOptionalKey("image")
        super.init(coder: coder)
    }

    public override func encodeWithCoder(coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(header, forKey: "header")
        encoder.encodeObject(subheader, forKey: "subheader")
        encoder.encodeObject(ctaCaption, forKey: "ctaCaption")
        encoder.encodeObject(ctaURL, forKey: "ctaURL")
        encoder.encodeObject(image, forKey: "image")
        super.encodeWithCoder(coder)
    }

    override public class func fromJSON(data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let header = json["header"].stringValue
        let subheader = json["subheader"].stringValue
        let ctaCaption = json["cta_caption"].stringValue
        let ctaURL = json["cta_href"].string.flatMap { NSURL(string: $0) }

        let image = Asset.parseAsset(id, node: data["image"] as? [String: AnyObject])

        let promotional = PagePromotional(
            id: id,
            header: header,
            subheader: subheader,
            ctaCaption: ctaCaption,
            ctaURL: ctaURL,
            image: image
            )
        promotional.links = data["links"] as? [String: AnyObject]
        return promotional
    }
}

extension PagePromotional: JSONSaveable {
    var uniqId: String? { return id }
}
