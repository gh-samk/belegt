import AppKit

// Zeichnet AppIcon.icns aus docs/assets/icon.svg: Aufruf `symbol <icon.svg> <Ausgabe.iconset>`.
// Das Symbol füllt wie bei macOS üblich rund 80 % der Fläche und wirft einen weichen Schatten.

guard CommandLine.arguments.count == 3, let svg = NSImage(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])) else {
    FileHandle.standardError.write(Data("Aufruf: symbol <icon.svg> <Ausgabe.iconset>\n".utf8))
    exit(2)
}
let ausgabe = URL(fileURLWithPath: CommandLine.arguments[2])
try FileManager.default.createDirectory(at: ausgabe, withIntermediateDirectories: true)

func zeichne(_ pixel: Int) -> Data {
    let darstellung = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixel, pixelsHigh: pixel, bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: darstellung)
    let seite = CGFloat(pixel)
    let kante = seite * 0.8
    let rahmen = NSRect(x: (seite - kante) / 2, y: (seite - kante) / 2 + seite * 0.01, width: kante, height: kante)
    let schatten = NSShadow()
    schatten.shadowColor = NSColor.black.withAlphaComponent(0.3)
    schatten.shadowBlurRadius = seite * 0.02
    schatten.shadowOffset = NSSize(width: 0, height: -seite * 0.01)
    NSGraphicsContext.current?.saveGraphicsState()
    schatten.set()
    svg.draw(in: rahmen)
    NSGraphicsContext.current?.restoreGraphicsState()
    NSGraphicsContext.restoreGraphicsState()
    return darstellung.representation(using: .png, properties: [:])!
}

for (name, pixel) in [
    ("icon_16x16", 16), ("icon_16x16@2x", 32), ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256), ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
] {
    try zeichne(pixel).write(to: ausgabe.appendingPathComponent("\(name).png"))
}
