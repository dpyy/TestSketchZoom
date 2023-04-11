//
//  ContentView22.swift
//  TestSketchZoom
//
//  Created by Gary Fung on 2023-04-02.
//

import PencilKit
import SwiftUI

struct ContentView2: View {
    @State var canvasView = PKCanvasView()

    var body: some View {
        VStack {
            Button("SAVE") {
                saveDrawing("whiteBg")
            }
            .frame(height: 50)

            CanvasView2(canvasView: $canvasView, onSaved: saveDrawing)
        }
    }

    func saveDrawing() {
    }

    func saveDrawing(_ fileName: String) {
        let data = canvasView.drawing.dataRepresentation()

        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(fileName)

        print(fileURL)

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
        }
    }
}

struct CanvasView2 {
    @Binding var canvasView: PKCanvasView
    @State var toolPicker = PKToolPicker()
    let onSaved: () -> Void
}

class Coordinator: NSObject {
    var canvasView: Binding<PKCanvasView>
    let onSaved: () -> Void
    var myImageView: UIImageView?

    init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
        self.canvasView = canvasView
        self.onSaved = onSaved
    }
}

extension Coordinator: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if !canvasView.drawing.bounds.isEmpty {
            onSaved()
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return myImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX: CGFloat = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY: CGFloat = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        myImageView?.frame.size = CGSize(width: canvasView.wrappedValue.bounds.width * scrollView.zoomScale, height: canvasView.wrappedValue.bounds.height * scrollView.zoomScale)
        myImageView?.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}

extension CanvasView2: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        // canvas
        canvasView.contentSize = CGSize(width: 1500, height: 1000)
        canvasView.drawingPolicy = .anyInput
        canvasView.minimumZoomScale = 0.2
        canvasView.maximumZoomScale = 4.0
        canvasView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        canvasView.contentInset = UIEdgeInsets(top: 280, left: 400, bottom: 280, right: 400)
        canvasView.contentMode = .center
        canvasView.scrollsToTop = false

        let imageView = UIImageView(image: UIImage(named: "dog"))
        imageView.frame = CGRect(x: 0, y: 0, width: 1500, height: 1000)
        canvasView.addSubview(imageView)
        canvasView.sendSubviewToBack(imageView)
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator

        if let whiteBackground = importDrawing("whiteBg") {
            canvasView.drawing = whiteBackground
        }

        canvasView.becomeFirstResponder()

        // toolpicker
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)

        return canvasView
    }

    func importDrawing(_ fileName: String) -> PKDrawing? {
        guard let data = NSDataAsset(name: fileName)?.data else { return nil }

        if let drawing = try? PKDrawing(data: data) {
            return drawing
        } else {
            return nil
        }
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
