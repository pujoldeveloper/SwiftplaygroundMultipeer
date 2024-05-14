//
//  ProgressCircularView.swift
//  SwiftplaygroundMultipeer
//
//  Created by Bruno PUJOL on 13/05/2024.
//

import Foundation
import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let strokeColor: Color
    let strokeLineWidth: CGFloat = 5
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    strokeColor.opacity(0.3),
                    lineWidth: strokeLineWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    strokeColor,
                    style: StrokeStyle(
                        lineWidth: strokeLineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)

        }
    }
}
