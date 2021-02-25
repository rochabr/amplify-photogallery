//
//  DrawingPad.swift
//  DrawingPadSwiftUI
//
//  Created by Martin Mitrevski on 20.07.19.
//  Copyright © 2019 Mitrevski. All rights reserved.
//

import SwiftUI

extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

struct DrawingPad: View {
    @Binding var currentDrawing: Drawing
    @Binding var drawings: [Drawing]
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    @Binding var image: UIImage?
    @Binding var dImage: UIImage?
    @Binding var imageCache: [UIImage?]
    
    //@State private var showingModalView = false
    
    @State private var rect: CGRect = .zero
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        VStack{
            VStack{
                if image != nil{
                    Image(uiImage: image!)
                        .resizable()
                        .overlay(
                            GeometryReader { geometry in
                                Path { path in
                                    for drawing in self.drawings {
                                        self.add(drawing: drawing, toPath: &path)
                                    }
                                    self.add(drawing: self.currentDrawing, toPath: &path)
                                }
                                .stroke(self.color, lineWidth: self.lineWidth)
                                    .background(Color(white: 0.95)
                                                    .opacity(0.1))
                                    .gesture(
                                        DragGesture(minimumDistance: 0.1)
                                            .onChanged({ (value) in
                                                let currentPoint = value.location
                                                if currentPoint.y >= 0
                                                    && currentPoint.y < geometry.size.height {
                                                    self.currentDrawing.points.append(currentPoint)
                                                }
                                            })
                                            .onEnded({ (value) in
                                                self.drawings.append(self.currentDrawing)
                                                self.currentDrawing = Drawing()
                                            })
                                )
                            }
                        )
                        .frame(maxHeight: .infinity)
                        .background(RectGetter(rect: $rect))
                }
  
            }
            Button("Confirm", action: {
                self.dImage = UIApplication.shared.windows[0].rootViewController?.view.asImage(rect: self.rect)
                self.imageCache.append(self.dImage)
                self.image = nil
            })
            .pretty()
        }
    }
    
    struct RectGetter: View {
        @Binding var rect: CGRect

        var body: some View {
            GeometryReader { proxy in
                self.createView(proxy: proxy)
            }
        }

        func createView(proxy: GeometryProxy) -> some View {
            DispatchQueue.main.async {
                self.rect = proxy.frame(in: .global)
            }

            return Rectangle().fill(Color.clear)
        }
    }
    
    private func add(drawing: Drawing, toPath path: inout Path) {
        let points = drawing.points
        if points.count > 1 {
            for i in 0..<points.count-1 {
                let current = points[i]
                let next = points[i+1]
                path.move(to: current)
                path.addLine(to: next)
            }
        }
    }

    
}
