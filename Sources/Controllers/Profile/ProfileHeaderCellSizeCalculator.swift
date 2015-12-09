//
//  ProfileHeaderCellSizeCalculator.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class ProfileHeaderCellSizeCalculator: NSObject {
    static let ratio: CGFloat = 16.0/9.0

    let webView: UIWebView
    var maxWidth: CGFloat = 0.0
    public var cellItems: [StreamCellItem] = []
    public var completion: ElloEmptyCompletion = {}

    required public init(webView: UIWebView) {
        self.webView = webView
        super.init()
        webView.delegate = self
    }

    public func processCells(cellItems: [StreamCellItem], withWidth width: CGFloat, completion: ElloEmptyCompletion) {
        self.cellItems = cellItems
        self.completion = completion
        self.maxWidth = width
        // -30 for the padding on the webview
        self.webView.frame = self.webView.frame.withWidth(self.maxWidth - (StreamTextCellPresenter.postMargin * 2))
        loadNext()
    }

    private func loadNext() {
        if let item = cellItems.safeValue(0),
            let user = item.jsonable as? User
        {
            let html = StreamTextCellHTML.postHTML(user.headerHTMLContent)
            // needs to use the same width as the post text region
            webView.loadHTMLString(html, baseURL: NSURL(string: "/"))
        }
        else {
            completion()
        }
    }

    private func assignCellHeight(webViewHeight: CGFloat) {
        if let cellItem = cellItems.safeValue(0) {
            let height = ProfileHeaderCellSizeCalculator.calculateHeightBasedOn(
                webViewHeight: webViewHeight,
                width: maxWidth
                )
            self.cellItems.removeAtIndex(0)
            cellItem.calculatedWebHeight = webViewHeight
            cellItem.calculatedOneColumnCellHeight = height
            cellItem.calculatedMultiColumnCellHeight = height
        }
        loadNext()
    }

    class func calculateHeightBasedOn(webViewHeight webViewHeight: CGFloat, width: CGFloat) -> CGFloat {
        var height: CGFloat = width / ratio // cover image size
        height += 166 // top of webview
        // add web view height and bottom padding
        height += max(webViewHeight, 0)
        return height
    }

}

extension ProfileHeaderCellSizeCalculator: UIWebViewDelegate {

    public func webViewDidFinishLoad(webView: UIWebView) {
        let webViewHeight = webView.windowContentSize()?.height ?? 0
        assignCellHeight(webViewHeight)
    }

}
