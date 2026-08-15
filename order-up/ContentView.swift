//
//  ContentView.swift
//  order-up
//
//  Created by YJ Soon on 14/8/26.
//

import SwiftUI

struct ContentView: View {
    @State private var milo = 0
    @State private var teh = 0
    @State private var toast = 0
    @State private var arr: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("Order Up")
                .font(.largeTitle)
                .bold()

            Text("Kopitiam snacks. Tap + to add.")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack {
                Text("🥤  Milo")
                    .font(.title2)
                Text("$1.50")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(milo)")
                    .font(.title)
                    .monospacedDigit()
                Button {
                    milo += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack {
                Text("🍵  Teh")
                    .font(.title2)
                Text("$1.20")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(teh)")
                    .font(.title)
                    .monospacedDigit()
                Button {
                    teh += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
            }
            .padding()
            .background(Color.brown.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack {
                Text("🍞  Kaya Toast")
                    .font(.title2)
                Text("$2.00")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(toast)")
                    .font(.title)
                    .monospacedDigit()
                Button {
                    toast += 1
                    arr.append("x")
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.22))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("Total  $\(Double(milo) * 1.5 + Double(toast) * 2.0 + Double(teh) * 1.2, specifier: "%.2f")")
                .font(.title)
                .bold()
                .padding(.top, 8)

            Button("Place Order") {
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .font(.title2)
        }
        .padding(20)
    }
}

#Preview {
    ContentView()
}
