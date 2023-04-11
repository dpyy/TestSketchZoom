//
//  ContentView.swift
//  TestSketchZoom
//
//  Created by Gary Fung on 2023-03-20.
//

import PencilKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        CanvasView()
            .background() {
                Color.red
            }
    }
}

struct CanvasView {
    @State var canvasView: PKCanvasView = PKCanvasView()
    @State var toolPicker = PKToolPicker()
}

extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
            // canvas
        canvasView.contentSize = CGSize(width: 1500, height: 1000)
        canvasView.drawingPolicy = .anyInput
        canvasView.minimumZoomScale = 0.2
        canvasView.maximumZoomScale = 4.0
        canvasView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        canvasView.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
        canvasView.becomeFirstResponder()
        
            //toolpicker
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
