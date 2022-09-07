//
//  AlertToast.swift
//  MoeMemos
//
//  Created by Mudkip on 2022/9/7.
//

import SwiftUI

fileprivate let loadingMaxWidth: CGFloat = 150
fileprivate let loadingMaxHeight: CGFloat = 150
fileprivate let errorMaxWidth: CGFloat = 300

enum AlertType: Equatable {
    case systemImage(_ name: String, _ title: String?)
    case loading
}

struct AlertToast: View {
    var type: AlertType
    
    var body: some View {
        switch type {
        case .systemImage(let name, let title):
            HStack {
                Image(systemName: name)
                if let title = title {
                    Text(title)
                        .lineLimit(3)
                }
                
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(10)
        case .loading:
            ProgressView()
                .scaleEffect(2)
                .padding()
                .frame(maxWidth: loadingMaxWidth, maxHeight: loadingMaxHeight)
                .background(.regularMaterial)
                .cornerRadius(10)
        }
    }
}

struct AlertToastModifier: ViewModifier {
    @Binding var isPresenting: Bool
    @State var duration: Double = 2
    @State private var workItem: DispatchWorkItem?
    
    let alertType: AlertType
    
    @ViewBuilder
    private func main(content: Content) -> some View {
        if isPresenting {
            content
                .overlay {
                    ZStack {
                        AlertToast(type: alertType)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .animation(Animation.spring(), value: isPresenting)
                }
        } else {
            content
        }
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        main(content: content)
            .onChange(of: isPresenting) { presented in
                if presented {
                    onAppearAction()
                }
            }
    }
    
    private func onAppearAction() {
        if alertType != .loading && duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                withAnimation(Animation.spring()){
                    isPresenting = false
                    workItem = nil
                }
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}

extension View {
    func toast(isPresenting: Binding<Bool>, duration: Double = 2, alertType: AlertType) -> some View {
        modifier(AlertToastModifier(isPresenting: isPresenting, duration: duration, alertType: alertType))
    }
}

struct AlertToast_Previews: PreviewProvider {
    static var previews: some View {
        AlertToast(type: .systemImage("xmark.circle", "Error"))
    }
}
