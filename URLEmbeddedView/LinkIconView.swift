//
//  LinkIconView.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/10.
//
//

import UIKit

final class LinkIconView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        let pdfPage = loadPdf()
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        let boxRect = CGPDFPageGetBoxRect(pdfPage, .MediaBox)
        let xScale = bounds.size.width / boxRect.size.width
        let yScale = bounds.size.height / boxRect.size.height
        let scale = xScale < yScale ? xScale : yScale
        CGContextTranslateCTM(context, 0.0, boxRect.size.height * yScale)
        CGContextScaleCTM(context, scale, -scale);
        CGContextDrawPDFPage(context, pdfPage);
        CGContextRestoreGState(context)
    }
    
    private func loadPdf() -> CGPDFPage? {
        let pdfURL = NSBundle(forClass: self.dynamicType).URLForResource("LinkIcon", withExtension: "pdf")
        let pdfDocument = CGPDFDocumentCreateWithURL(pdfURL as CFURLRef?)
        return CGPDFDocumentGetPage(pdfDocument, 1)
    }
}
