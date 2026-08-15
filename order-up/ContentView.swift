//
//  ContentView.swift
//  order-up
//
//  Created by YJ Soon on 14/8/26.
//

import Combine
import SwiftUI

struct MenuItem {
    let name: String
    let price: Double

    static let milo = MenuItem(name: "🥤  Milo", price: 1.50)
    static let teh = MenuItem(name: "🍵  Teh", price: 1.20)
    static let toast = MenuItem(name: "🍞  Kaya Toast", price: 2.00)
}

struct OrderItem: Identifiable {
    let id = UUID()
    let item: MenuItem
    let count: Int

    var name: String { item.name }
    var subtotal: Double { Double(count) * item.price }
}

/// A drifting button. Which item it secretly controls is `targetIndex` —
/// nothing on screen gives it away, so you have to guess.
struct FloatingButton: Identifiable {
    let id = UUID()
    var position: CGPoint
    let targetIndex: Int
}

struct ContentView: View {
    @State private var milo = 0
    @State private var teh = 0
    @State private var toast = 0
    @State private var showingReceipt = false

    @State private var hour = Calendar.current.component(.hour, from: Date())
    @State private var buttons: [FloatingButton] = []

    private let drift = Timer.publish(every: 0.55, on: .main, in: .common).autoconnect()

    /// Even hour: both buttons add. Odd hour: both buttons subtract.
    private var isAddingHour: Bool { hour % 2 == 0 }

    private var orderedItems: [OrderItem] {
        [
            OrderItem(item: .milo, count: milo),
            OrderItem(item: .teh, count: teh),
            OrderItem(item: .toast, count: toast),
        ]
        .filter { $0.count > 0 }
    }

    private var total: Double {
        orderedItems.reduce(0) { $0 + $1.subtotal }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Drinks") {
                    MenuItemRow(item: .milo, count: milo)
                    MenuItemRow(item: .teh, count: teh)
                }

                Section {
                    MenuItemRow(item: .toast, count: toast)
                } header: {
                    Text("Food")
                } footer: {
                    Text(isAddingHour
                         ? "Even hour — all three buttons add. Each one secretly belongs to a different item. Guess which is which."
                         : "Odd hour — all three buttons subtract. Each one secretly belongs to a different item. Guess which is which.")
                }

                Section("Summary") {
                    HStack {
                        Text("Total")
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text("$\(total, specifier: "%.2f")")
                            .font(.title3)
                            .bold()
                            .monospacedDigit()
                    }

                    Button {
                        showingReceipt = true
                    } label: {
                        Text("Place Order")
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(orderedItems.isEmpty)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Order Up")
            .overlay {
                floatingButtons
            }
            .sheet(isPresented: $showingReceipt, onDismiss: refreshEverything) {
                OrderPlacedView(items: orderedItems, total: total)
            }
        }
    }

    private var floatingButtons: some View {
        GeometryReader { geo in
            // The ZStack must own onAppear/onReceive: modifiers on a ForEach
            // attach to its children, and with `buttons` empty there are none.
            ZStack {
                ForEach(buttons) { button in
                    Button {
                        applyChange(to: button.targetIndex)
                    } label: {
                        // Every button looks identical — that's the guessing game.
                        Image(systemName: isAddingHour ? "plus.circle.fill" : "minus.circle.fill")
                            .font(.system(size: 56))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, isAddingHour ? .green : .red)
                            .shadow(radius: 6)
                    }
                    .position(button.position)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {
                // One button per item, assigned in a shuffled order each launch.
                buttons = [0, 1, 2].shuffled().map {
                    FloatingButton(position: randomPoint(in: geo.size), targetIndex: $0)
                }
            }
            .onReceive(drift) { _ in
                hour = Calendar.current.component(.hour, from: Date())
                withAnimation(.easeInOut(duration: 0.5)) {
                    for index in buttons.indices {
                        buttons[index].position = randomPoint(in: geo.size)
                    }
                }
            }
        }
    }

    private func randomPoint(in size: CGSize) -> CGPoint {
        let inset: CGFloat = 40
        guard size.width > inset * 2, size.height > inset * 2 else { return .zero }
        return CGPoint(
            x: .random(in: inset...(size.width - inset)),
            y: .random(in: inset...(size.height - inset))
        )
    }

    /// Clears the order and reshuffles which button controls which item,
    /// so the next customer starts from scratch and has to guess again.
    private func refreshEverything() {
        milo = 0
        teh = 0
        toast = 0
        buttons = zip(buttons, [0, 1, 2].shuffled()).map {
            FloatingButton(position: $0.position, targetIndex: $1)
        }
    }

    private func applyChange(to targetIndex: Int) {
        let delta = isAddingHour ? 1 : -1
        switch targetIndex {
        case 0: milo = max(0, milo + delta)
        case 1: teh = max(0, teh + delta)
        default: toast = max(0, toast + delta)
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    let count: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.title3)
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(count)")
                .font(.title)
                .monospacedDigit()
                .frame(minWidth: 28)
        }
        .padding(.vertical, 4)
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
