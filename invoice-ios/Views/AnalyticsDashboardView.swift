//
//  AnalyticsDashboardView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/26.
//

import SwiftUI
import Charts

struct AnalyticsDashboardView<ViewModel: AnalyticsDashboardViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    @State private var selected: Double?
    @State private var barSelection: String?
    @State private var cumulativeRanges: [(name: String, range: Range<Double>)] = []

    var selectedData: ChartData? {
        if let selected,
           let selectedIndex = cumulativeRanges
            .firstIndex(where: { $0.range.contains(selected) }) {
            return viewModel.chartData[selectedIndex]
        }

        return nil
    }

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Picker("Grouping Option", selection: $viewModel.duration) {
                ForEach(DashboardDuration.allCases, id: \.self) { option in
                    Text(option.name)
                }
            }
            .pickerStyle(.segmented)

            Chart(viewModel.chartData, id: \.name) { data in
                SectorMark(
                    angle: .value("Amount", max(data.amount, 1)),
                    innerRadius: .ratio(0.618),
                    angularInset: 2
                )
                .cornerRadius(8.0)
                .foregroundStyle(by: .value("Name", data.name))
                .opacity(data.name == (selectedData?.name ?? viewModel.maxData?.name) ? 1 : 0.3)
            }
            .chartLegend(alignment: .center, spacing: 18)
            .chartAngleSelection(value: $selected)
            .chartLegend(.hidden)
            .scaledToFit()
            .frame(height: 400)
            .scaleEffect(x: -1, y: 1)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text("消費金額最高")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .opacity(selectedData?.name == nil || selectedData?.name == viewModel.maxData?.name ? 1 : 0)
                        Text(selectedData?.name ?? viewModel.maxData?.name ?? "")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        Text("$" + (selectedData?.amount.formatted() ?? viewModel.maxData?.amount.formatted() ?? "0"))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            .onChange(of: viewModel.chartData) {
                var cumulative = 0.0
                self.cumulativeRanges = viewModel.chartData.map {
                    let newCumulative = cumulative + Double(max($0.amount, 1))
                    let result = (name: $0.name, range: cumulative ..< newCumulative)
                    cumulative = newCumulative
                    return result
                }
            }

            Chart {
                ForEach(viewModel.chartData, id: \.name) { data in
                    BarMark(
                        x: .value("Name", data.name),
                        y: .value("Total Amount", data.amount)
                    )
                    .foregroundStyle(by: .value("Name", data.name))
                }

                if let barSelection = barSelection {
                    RuleMark(x: .value("Name", barSelection))
                        .foregroundStyle(.gray.opacity(0.5))
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 200)
            .chartXSelection(value: $barSelection)
            .onChange(of: barSelection) {
                if let data = viewModel.chartData.first(where: { $0.name == barSelection }) {
                    selected = cumulativeRanges.first(where: { $0.name == data.name })?.range.lowerBound
                } else {
                    selected = nil
                }
            }
        }
        .padding()
        .navigationTitle("統計數據")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.generalBackground)
    }
}
