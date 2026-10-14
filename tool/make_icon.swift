import AppKit

// 앱 아이콘 원본을 그린다 (맥 기본 Didot 글꼴 사용).
// swift tool/make_icon.swift assets/icon/app_icon.png full
// swift tool/make_icon.swift assets/icon/app_icon_foreground.png foreground
// 그다음 dart run flutter_launcher_icons
let args = CommandLine.arguments
let out = args[1]
let foregroundOnly = args.count > 2 && args[2] == "foreground"
let size: CGFloat = 1024

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
let ctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = ctx
let cg = ctx.cgContext

func rgb(_ hex: Int, _ a: CGFloat = 1) -> NSColor {
  NSColor(deviceRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255,
          blue: CGFloat(hex & 0xff) / 255, alpha: a)
}

if !foregroundOnly {
  // 분홍 그라데이션 배경 (왼쪽 위 밝게 → 오른쪽 아래 진하게)
  let bg = NSGradient(colors: [rgb(0xF59AB0), rgb(0xE8587A), rgb(0xD9466A)],
                      atLocations: [0, 0.55, 1], colorSpace: .deviceRGB)!
  bg.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: -45)
  // 왼쪽 위 은은한 빛
  let glow = NSGradient(colors: [rgb(0xFFFFFF, 0.28), rgb(0xFFFFFF, 0)])!
  glow.draw(fromCenter: NSPoint(x: 260, y: 800), radius: 0,
            toCenter: NSPoint(x: 260, y: 800), radius: 560, options: [])
}

// 안드로이드 적응형 아이콘 전경은 안전 영역(가운데 약 66%) 안에 들어가도록 줄인다.
let scale: CGFloat = foregroundOnly ? 0.62 : 1.0
cg.translateBy(x: size / 2, y: size / 2)
cg.scaleBy(x: scale, y: scale)
cg.translateBy(x: -size / 2, y: -size / 2)

// 흰 이탤릭 세리프 R
let font = NSFontManager.shared.font(withFamily: "Didot", traits: .italicFontMask, weight: 5, size: 700)
  ?? NSFont(name: "Didot-Italic", size: 700)!
let shadow = NSShadow()
shadow.shadowColor = rgb(0x8A1E3C, 0.25)
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.shadowBlurRadius = 24
let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white, .shadow: shadow]
let r = NSAttributedString(string: "R", attributes: attrs)
let b = r.size()
r.draw(at: NSPoint(x: (size - b.width) / 2 - 14, y: (size - b.height) / 2 - 18))

// 작은 하트 (R의 오른쪽 위)
func heart(center c: NSPoint, width w: CGFloat) -> NSBezierPath {
  let p = NSBezierPath()
  let h = w * 0.9
  p.move(to: NSPoint(x: c.x, y: c.y - h * 0.5))
  p.curve(to: NSPoint(x: c.x - w * 0.5, y: c.y + h * 0.12),
          controlPoint1: NSPoint(x: c.x - w * 0.12, y: c.y - h * 0.32),
          controlPoint2: NSPoint(x: c.x - w * 0.5, y: c.y - h * 0.18))
  p.curve(to: NSPoint(x: c.x, y: c.y + h * 0.28),
          controlPoint1: NSPoint(x: c.x - w * 0.5, y: c.y + h * 0.5),
          controlPoint2: NSPoint(x: c.x - w * 0.08, y: c.y + h * 0.52))
  p.curve(to: NSPoint(x: c.x + w * 0.5, y: c.y + h * 0.12),
          controlPoint1: NSPoint(x: c.x + w * 0.08, y: c.y + h * 0.52),
          controlPoint2: NSPoint(x: c.x + w * 0.5, y: c.y + h * 0.5))
  p.curve(to: NSPoint(x: c.x, y: c.y - h * 0.5),
          controlPoint1: NSPoint(x: c.x + w * 0.5, y: c.y - h * 0.18),
          controlPoint2: NSPoint(x: c.x + w * 0.12, y: c.y - h * 0.32))
  p.close()
  return p
}
NSGraphicsContext.saveGraphicsState()
shadow.set()
NSColor.white.setFill()
heart(center: NSPoint(x: 770, y: 760), width: 120).fill()
NSGraphicsContext.restoreGraphicsState()

// 반짝임
let sparkle = NSAttributedString(string: "✦", attributes: [
  .font: NSFont.systemFont(ofSize: 70), .foregroundColor: rgb(0xFFFFFF, 0.55)])
sparkle.draw(at: NSPoint(x: 205, y: 760))

NSGraphicsContext.restoreGraphicsState()
// iOS 앱 아이콘은 투명도가 없어야 하므로 전체 아이콘은 그대로(불투명 배경) 저장
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("saved", out)
