//
//  PopupView.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

// MARK: - iOS / macOS Implementation
#if os(iOS) || os(macOS)
struct PopupView: View {
    let globalConfig: GlobalConfig
    @ObservedObject private var stack: PopupManager = .shared

    init(globalConfig: GlobalConfig) {
        self.globalConfig = globalConfig
    }

    var body: some View { createBody() }
}

// MARK: - tvOS Implementation
#elseif os(tvOS)
struct PopupView: View {
    let rootView: any View
    let globalConfig: GlobalConfig
    @ObservedObject private var stack: PopupManager = .shared


    var body: some View {
        AnyView(rootView)
            .disabled(!stack.views.isEmpty)
            .overlay(createBody())
    }
}
#endif


// MARK: - Common Part
private extension PopupView {
    func createBody() -> some View {
        Group {
            if #available(iOS 15.0, *) {
                createPopupStackView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        ZStack {
                            createOverlay()
                            createTopOverlay()
                            createCentreOverlay()
                            createBottomOverlay()
                        }
                    }
            } else {
                createPopupStackView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(createOverlay())
            }
        }
    }
}

private extension PopupView {
    func createPopupStackView() -> some View {
        ZStack {
            createTopPopupStackView()
            createCentrePopupStackView()
            createBottomPopupStackView()
        }
        .animation(stack.presenting ? globalConfig.common.animation.entry : globalConfig.common.animation.removal, value: stack.views.map(\.id))
    }
    
    func createOverlay() -> some View {
        overlayColour
            .ignoresSafeArea()
            .active(if: !stack.views.isEmpty)
            .animation(overlayAnimation, value: stack.views.isEmpty)
    }
    
    func createTopOverlay() -> some View {
        overlayTopColour
            .ignoresSafeArea()
            .active(if: !stack.top.isEmpty)
            .animation(overlayAnimation, value: stack.top.isEmpty)
    }
    
    func createCentreOverlay() -> some View {
        overlayCentreColour
            .ignoresSafeArea()
            .active(if: !stack.centre.isEmpty)
            .animation(overlayAnimation, value: stack.centre.isEmpty)
    }
    
    func createBottomOverlay() -> some View {
        overlayBottomColour
            .ignoresSafeArea()
            .active(if: !stack.bottom.isEmpty)
            .animation(overlayAnimation, value: stack.bottom.isEmpty)
    }
}

private extension PopupView {
    func createTopPopupStackView() -> some View {
        PopupTopStackView(items: stack.top, globalConfig: globalConfig)
    }
    func createCentrePopupStackView() -> some View {
        PopupCentreStackView(items: stack.centre, globalConfig: globalConfig)
    }
    func createBottomPopupStackView() -> some View {
        PopupBottomStackView(items: stack.bottom, globalConfig: globalConfig)
    }
}

private extension PopupView {
    var overlayColour: Color { globalConfig.common.overlayColour }
    var overlayTopColour: Color { globalConfig.top.overlayColour }
    var overlayCentreColour: Color { globalConfig.centre.overlayColour }
    var overlayBottomColour: Color { globalConfig.bottom.overlayColour }
    var overlayAnimation: Animation { .easeInOut(duration: 0.44) }
}
