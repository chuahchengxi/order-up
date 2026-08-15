//
//  ContentView.swift
//  order-up
//
//  Created by YJ Soon on 14/8/26.
//

import SwiftUI

struct OrderItem: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let price: Double

    var subtotal: Double { Double(count) * price }
}

struct ContentView: View {
    @State private var milo = 0
    @State private var teh = 0
    @State private var toast = 0
    @State private var showingReceipt = false

    private var orderedItems: [OrderItem] {
        [
            OrderItem(name: "🥤  Milo", count: milo, price: 1.5),
            OrderItem(name: "🍵  Teh", count: teh, price: 1.2),
            OrderItem(name: "🍞  Kaya Toast", count: toast, price: 2.0),
        ]
        .filter { $0.count > 0 }
    }

    private var total: Double {
        orderedItems.reduce(0) { $0 + $1.subtotal }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Order Up")
                .font(.largeTitle)
                .bold()

            Text("Kopitiam snacks. Tap + or − to adjust.")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack {
                Text("🥤  Milo")
                    .font(.title2)
                Text("$1.50")
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    milo = max(0, milo - 1)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.largeTitle)
                }
                .disabled(milo == 0)
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
                Button {
                    teh = max(0, teh - 1)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.largeTitle)
                }
                .disabled(teh == 0)
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
                Button {
                    toast = max(0, toast - 1)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.largeTitle)
                }
                .disabled(toast == 0)
                Text("\(toast)")
                    .font(.title)
                    .monospacedDigit()
                Button {
                    toast += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.22))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("Total  $\(total, specifier: "%.2f")")
                .font(.title)
                .bold()
                .padding(.top, 8)

            Button("Place Order") {
                showingReceipt = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .font(.title2)
            .disabled(orderedItems.isEmpty)
        }
        .padding(20)
        .sheet(isPresented: $showingReceipt) {
            OrderPlacedView(items: orderedItems, total: total)
        }
    }
}

struct OrderPlacedView: View {
    let items: [OrderItem]
    let total: Double

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .padding(.top, 32)

            Text("Order Placed!")
                .font(.largeTitle)
                .bold()

            Text("Here's what you ordered:")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(items) { item in
                    HStack {
                        Text(item.name)
                            .font(.title3)
                        Spacer()
                        Text("×\(item.count)")
                            .font(.title3)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Text("$\(item.subtotal, specifier: "%.2f")")
                            .font(.title3)
                            .monospacedDigit()
                            .frame(width: 72, alignment: .trailing)
                    }
                }

                Divider()

                HStack {
                    Text("Total")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Text("$\(total, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .monospacedDigit()
                }
            }

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .font(.title2)
        }
        .padding(24)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ContentView()
}
