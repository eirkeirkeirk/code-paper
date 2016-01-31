#!/usr/bin/swift
//
//  main.swift
//  code-paper-generator
//
//  Created by Erik P. Hansen on 1/29/16.
//  Copyright © 2016 Erik P. Hansen. All rights reserved.
//
import Cocoa

let fileName = "code-paper.pdf"

var paperWidth = 8.5
var paperHeight = 11.0

var marginTop = 0.75
var marginRight = 0.75
var marginBottom = 0.75
var marginLeft = 0.75

// `page` dimensions refer to the writing area of the paper
var pageWidth = paperWidth - marginLeft - marginRight
var pageHeight = paperHeight - marginBottom - marginTop

var borderWidth = 1.0
var borderColor = NSColor(calibratedHue: 0, saturation: 0, brightness: 0.4, alpha: 1)

var lineWidth = 0.5
var lineColor = NSColor(calibratedHue: 0, saturation: 0, brightness: 0.8, alpha: 1)
var lineSpacing = 0.25
var numberOfLines = Int(floor(pageHeight / lineSpacing))

var tabLineWidth = 0.5
var tabLinesSpacing = 0.28
let firstTabLineOffset = 0.5
var tabLineColor = NSColor(calibratedHue: 0, saturation: 0, brightness: 0.9, alpha: 1)
var numbersOfTabs = 4

func getPath() -> NSURL? {
    let fileManager = NSFileManager.defaultManager()
    do {
        let dir = try fileManager.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
        return dir.URLByAppendingPathComponent(fileName)
    } catch {
        return nil
    }
}

func updateDimensions() {
    let newPageHeight = Double(numberOfLines) * lineSpacing
    let difference = pageHeight - newPageHeight
    pageHeight = newPageHeight
    marginTop += difference / 2
    marginBottom += difference / 2
}

func drawBorder() {
    let path = NSBezierPath(rect: NSRect(x: marginLeft * 72, y: marginBottom * 72, width: 72 * pageWidth, height: 72 * pageHeight))
    borderColor.set()
    path.lineWidth = CGFloat(borderWidth)
    path.stroke()
}

func drawLines() {
    let path = NSBezierPath()
    let x = marginLeft * 72
    let y = marginBottom * 72
    let length = pageWidth * 72
    path.moveToPoint(NSPoint(x: x, y: y))
    path.lineToPoint(NSPoint(x: x + length, y: y))
    path.lineWidth = CGFloat(lineWidth)
    lineColor.set()
    let transform = NSAffineTransform()
    transform.translateXBy(0.0, yBy: CGFloat(lineSpacing * 72))
    for _ in 0...numberOfLines - 2 { // don't draw lines at the very bottom or top of the page
        path.transformUsingAffineTransform(transform)
        path.stroke()
    }
}

func drawTabs() {
    let path = NSBezierPath()
    let x = (marginLeft + firstTabLineOffset) * 72
    let y = marginBottom * 72
    let length = pageHeight * 72
    path.moveToPoint(NSPoint(x:x, y:y))
    path.lineToPoint(NSPoint(x:x, y:y + length))
    path.lineWidth = CGFloat(tabLineWidth)
    tabLineColor.set()
    let transform = NSAffineTransform()
    transform.translateXBy(CGFloat(tabLinesSpacing * 72), yBy: 0.0)
    path.stroke()
    for _ in 0..<numbersOfTabs {
        path.transformUsingAffineTransform(transform)
        path.stroke()
    }
}

func drawPDF() {
    var pageRect = CGRect(x: 0, y: 0, width: 72 * paperWidth, height: 72 * paperHeight)
    let context = CGPDFContextCreateWithURL(getPath(), &pageRect, nil)
    let graphicsContext = NSGraphicsContext(CGContext: context!, flipped:false)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.setCurrentContext(graphicsContext)
    CGPDFContextBeginPage(context, nil)

    updateDimensions()
    drawTabs()
    drawLines()
    drawBorder()

    CGPDFContextEndPage(context)
    CGPDFContextClose(context)
}

drawPDF()

// now open the PDF
if let thePDFFile = getPath() {
    NSWorkspace.sharedWorkspace().openURL(thePDFFile)
}