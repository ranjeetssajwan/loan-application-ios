
//
//  StepProgressView.swift
//  Sample
//
 
 

import UIKit

final class StepProgressView: UIView {

    // MARK: - Config

    private let stepCount: Int
    private let labels: [String]

    // MARK: - Subviews

    private var circles: [UIView]    = []
    private var lines:   [UIView]    = []
    private var stepLabels: [UILabel] = []

    // MARK: - Current step (1-based)

    var currentStep: Int = 1 {
        didSet { updateAppearance() }
    }

    // MARK: - Init

    init(steps: [String]) {
        self.stepCount = steps.count
        self.labels    = steps
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 68).isActive = true
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build

    private func build() {
        
        
        let hStack       = UIStackView()
        hStack.axis      = .horizontal
        hStack.alignment = .top
        hStack.distribution = .equalSpacing
        hStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        for i in 0..<stepCount {
            // each step = circle + label stacked vertically
            let col       = UIStackView()
            col.axis      = .vertical
            col.alignment = .center
            col.spacing   = 6
            col.translatesAutoresizingMaskIntoConstraints = false

            let circle = makeCircle(index: i)
            circles.append(circle)

            let lbl = UILabel()
            lbl.text      = labels[i]
            lbl.font      = .systemFont(ofSize: 10, weight: .medium)
            lbl.textColor = AppColor.textMuted
            lbl.translatesAutoresizingMaskIntoConstraints = false
            stepLabels.append(lbl)

            col.addArrangedSubview(circle)
            col.addArrangedSubview(lbl)
            hStack.addArrangedSubview(col)

            // connector line between steps
            if i < stepCount - 1 {
                let line = UIView()
                line.backgroundColor = AppColor.stepInactive
                line.layer.cornerRadius = 1
                line.translatesAutoresizingMaskIntoConstraints = false
                lines.append(line)
                // lines are placed using addSubview and constraints relative to circles
                addSubview(line)
            }
        }

        // Layout lines after circles are known
        layoutIfNeeded()
    }

    private func makeCircle(index: Int) -> UIView {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: 28),
            v.heightAnchor.constraint(equalToConstant: 28)
        ])

        let lbl       = UILabel()
        lbl.text      = "\(index + 1)"
        lbl.font      = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        positionLines()
    }

    private func positionLines() {
        for (i, line) in lines.enumerated() {
            guard i + 1 < circles.count else { continue }
            let c1 = circles[i]
            let c2 = circles[i + 1]
            let y  = c1.frame.midY - 1
            let x1 = c1.frame.maxX + 4
            let x2 = c2.frame.minX - 4
            line.frame = CGRect(x: x1, y: y, width: max(0, x2 - x1), height: 2)
        }
    }

    private func updateAppearance() {
        for (i, circle) in circles.enumerated() {
            let stepNum = i + 1
            if stepNum < currentStep {
                circle.backgroundColor = AppColor.stepDone
                (circle.subviews.first as? UILabel)?.text = "✓"
                stepLabels[i].textColor = AppColor.stepDone
            } else if stepNum == currentStep {
                circle.backgroundColor = AppColor.stepActive
                (circle.subviews.first as? UILabel)?.text = "\(stepNum)"
                stepLabels[i].textColor = AppColor.accentLight
            } else {
                circle.backgroundColor = AppColor.stepInactive
                (circle.subviews.first as? UILabel)?.text = "\(stepNum)"
                stepLabels[i].textColor = AppColor.textMuted
            }
        }
        for (i, line) in lines.enumerated() {
            line.backgroundColor = (i + 1) < currentStep ? AppColor.stepDone : AppColor.stepInactive
        }
    }
}
