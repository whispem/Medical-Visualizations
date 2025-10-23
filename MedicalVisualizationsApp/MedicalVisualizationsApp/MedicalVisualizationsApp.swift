//
//  MedicalVisualizationsApp.swift
//  MedicalVisualizationsApp
//
//  Created by Emilie on 23/10/2025.
//
import SwiftUI

// MARK: - Main Container View
struct MedicalVisualizationsApp: View {
    @State private var selectedView: Int = 0
    
    var body: some View {
        ZStack {
            switch selectedView {
            case 0:
                TumorMicroenvironmentView()
            case 1:
                MultiOmicsIntegrationView()
            case 2:
                DrugResponseSimulationView()
            default:
                TumorMicroenvironmentView()
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    NavigationButton(
                        icon: "circle.hexagongrid.fill",
                        title: "Tumor",
                        isSelected: selectedView == 0
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedView = 0
                        }
                    }
                    
                    NavigationButton(
                        icon: "circle.grid.cross.fill",
                        title: "Multi-Omics",
                        isSelected: selectedView == 1
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedView = 1
                        }
                    }
                    
                    NavigationButton(
                        icon: "cross.vial",
                        title: "Drug Response",
                        isSelected: selectedView == 2
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedView = 2
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Navigation Button
struct NavigationButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .cyan : .white.opacity(0.5))
                
                Text(title)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(isSelected ? .cyan : .white.opacity(0.5))
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.05))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.cyan.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1.5)
                )
            )
            .shadow(color: isSelected ? .cyan.opacity(0.4) : .clear, radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - 1. TUMOR MICROENVIRONMENT VIEW
struct TumorMicroenvironmentView: View {
    @State private var cells: [TumorCell] = []
    @State private var vessels: [BloodVessel] = []
    @State private var immuneCells: [ImmuneCell] = []
    @State private var time: CGFloat = 0
    @State private var growthRate: CGFloat = 2.3
    @State private var vascularization: CGFloat = 68.5
    @State private var immuneInfiltration: CGFloat = 42.0
    @State private var oxygenLevel: CGFloat = 73.0
    @State private var showMetrics: Bool = true
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            MedicalBackground(color1: Color(red: 0.01, green: 0.02, blue: 0.06), color2: Color(red: 0.03, green: 0.04, blue: 0.12))
            
            Canvas { context, size in
                // Oxygen gradient
                let gradient = Gradient(colors: [
                    Color.red.opacity(0.15),
                    Color.orange.opacity(0.1),
                    Color.yellow.opacity(0.05),
                    Color.clear
                ])
                
                context.fill(
                    Circle().path(in: CGRect(x: size.width * 0.5 - 250, y: size.height * 0.5 - 250, width: 500, height: 500)),
                    with: .radialGradient(gradient, center: CGPoint(x: size.width * 0.5, y: size.height * 0.5), startRadius: 0, endRadius: 250)
                )
                
                // Blood vessels
                for vessel in vessels {
                    var path = Path()
                    path.move(to: vessel.points[0])
                    for point in vessel.points.dropFirst() {
                        path.addLine(to: point)
                    }
                    
                    context.stroke(
                        path,
                        with: .color(.red.opacity(Double(vessel.opacity))),
                        lineWidth: vessel.width
                    )
                    
                    context.stroke(
                        path,
                        with: .color(.red.opacity(Double(vessel.opacity * 0.3))),
                        lineWidth: vessel.width * 2
                    )
                }
                
                // Tumor cells
                for cell in cells {
                    let pulseSize = cell.size * (1 + sin(time * 2 + CGFloat(cell.id.hashValue)) * 0.1)
                    
                    context.fill(
                        Circle().path(in: CGRect(
                            x: cell.position.x - pulseSize / 2,
                            y: cell.position.y - pulseSize / 2,
                            width: pulseSize,
                            height: pulseSize
                        )),
                        with: .radialGradient(
                            Gradient(colors: [
                                cell.color.opacity(Double(cell.health)),
                                cell.color.opacity(Double(cell.health * 0.6)),
                                cell.color.opacity(Double(cell.health * 0.2))
                            ]),
                            center: cell.position,
                            startRadius: 0,
                            endRadius: pulseSize / 2
                        )
                    )
                    
                    // Nucleus
                    let nucleusSize = pulseSize * 0.35
                    context.fill(
                        Circle().path(in: CGRect(
                            x: cell.position.x - nucleusSize / 2,
                            y: cell.position.y - nucleusSize / 2,
                            width: nucleusSize,
                            height: nucleusSize
                        )),
                        with: .color(.purple.opacity(Double(cell.health * 0.8)))
                    )
                }
                
                // Immune cells
                for immune in immuneCells {
                    let trailLength = min(10, immune.trail.count)
                    for i in 0..<trailLength {
                        let index = immune.trail.count - 1 - i
                        let point = immune.trail[index]
                        let opacity = CGFloat(trailLength - i) / CGFloat(trailLength) * immune.activity
                        
                        context.fill(
                            Circle().path(in: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)),
                            with: .color(.green.opacity(Double(opacity * 0.5)))
                        )
                    }
                    
                    context.fill(
                        Circle().path(in: CGRect(
                            x: immune.position.x - immune.size / 2,
                            y: immune.position.y - immune.size / 2,
                            width: immune.size,
                            height: immune.size
                        )),
                        with: .radialGradient(
                            Gradient(colors: [
                                .green.opacity(Double(immune.activity)),
                                .green.opacity(Double(immune.activity * 0.5)),
                                .clear
                            ]),
                            center: immune.position,
                            startRadius: 0,
                            endRadius: immune.size / 2
                        )
                    )
                }
            }
            
            VStack {
                if showMetrics {
                    HStack(spacing: 12) {
                        MedicalMetricCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Growth Rate",
                            value: String(format: "%.1f", growthRate),
                            unit: "%/day",
                            color: .red,
                            trend: .up
                        )
                        
                        MedicalMetricCard(
                            icon: "drop.fill",
                            title: "Vascularization",
                            value: String(format: "%.1f", vascularization),
                            unit: "%",
                            color: .orange,
                            trend: .up
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    HStack(spacing: 12) {
                        MedicalMetricCard(
                            icon: "shield.fill",
                            title: "Immune Infiltration",
                            value: String(format: "%.1f", immuneInfiltration),
                            unit: "%",
                            color: .green,
                            trend: .stable
                        )
                        
                        MedicalMetricCard(
                            icon: "wind",
                            title: "Oxygen Level",
                            value: String(format: "%.1f", oxygenLevel),
                            unit: "%",
                            color: .cyan,
                            trend: .down
                        )
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showMetrics.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showMetrics ? "eye.slash.fill" : "chart.bar.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text(showMetrics ? "Hide" : "Show")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                        )
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            updateTumorSimulation()
        }
        .onAppear {
            initializeTumor()
        }
    }
    
    func initializeTumor() {
        let center = CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.5)
        
        // Create tumor cells
        for _ in 0..<80 {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 0...120)
            let x = center.x + cos(angle) * distance
            let y = center.y + sin(angle) * distance
            
            cells.append(TumorCell(
                position: CGPoint(x: x, y: y),
                size: CGFloat.random(in: 20...35),
                color: [Color.red, Color.pink, Color.orange].randomElement() ?? .red,
                health: CGFloat.random(in: 0.7...1.0)
            ))
        }
        
        // Create blood vessels
        for _ in 0..<15 {
            var points: [CGPoint] = []
            let startAngle = CGFloat.random(in: 0...(2 * .pi))
            let startDistance = CGFloat.random(in: 150...200)
            var currentPoint = CGPoint(
                x: center.x + cos(startAngle) * startDistance,
                y: center.y + sin(startAngle) * startDistance
            )
            points.append(currentPoint)
            
            for _ in 0..<20 {
                let angle = atan2(center.y - currentPoint.y, center.x - currentPoint.x) + CGFloat.random(in: -0.3...0.3)
                let distance = CGFloat.random(in: 10...25)
                currentPoint = CGPoint(
                    x: currentPoint.x + cos(angle) * distance,
                    y: currentPoint.y + sin(angle) * distance
                )
                points.append(currentPoint)
            }
            
            vessels.append(BloodVessel(points: points, width: CGFloat.random(in: 2...4), opacity: CGFloat.random(in: 0.6...1.0)))
        }
        
        // Create immune cells
        for _ in 0..<25 {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 180...250)
            immuneCells.append(ImmuneCell(
                position: CGPoint(
                    x: center.x + cos(angle) * distance,
                    y: center.y + sin(angle) * distance
                ),
                size: CGFloat.random(in: 12...18),
                activity: CGFloat.random(in: 0.6...1.0)
            ))
        }
    }
    
    func updateTumorSimulation() {
        time += 0.02
        let center = CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.5)
        
        // Update immune cells
        for i in immuneCells.indices {
            let dx = center.x - immuneCells[i].position.x
            let dy = center.y - immuneCells[i].position.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance > 50 {
                immuneCells[i].position.x += (dx / distance) * 0.8
                immuneCells[i].position.y += (dy / distance) * 0.8
            }
            
            immuneCells[i].trail.append(immuneCells[i].position)
            if immuneCells[i].trail.count > 15 {
                immuneCells[i].trail.removeFirst()
            }
        }
        
        // Update metrics
        withAnimation(.easeInOut(duration: 2.0)) {
            growthRate = 2.0 + sin(time * 0.5) * 0.5
            vascularization = 65 + sin(time * 0.3) * 8
            immuneInfiltration = 40 + cos(time * 0.4) * 6
            oxygenLevel = 70 + sin(time * 0.6) * 8
        }
    }
}

struct TumorCell: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var health: CGFloat
}

struct BloodVessel: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var width: CGFloat
    var opacity: CGFloat
}

struct ImmuneCell: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var activity: CGFloat
    var trail: [CGPoint] = []
}

// MARK: - 2. MULTI-OMICS INTEGRATION VIEW
struct MultiOmicsIntegrationView: View {
    @State private var rotation: CGFloat = 0
    @State private var layerData: [OmicsLayer] = []
    @State private var connections: [OmicsConnection] = []
    @State private var dataFlow: CGFloat = 0
    @State private var integrationScore: CGFloat = 87.5
    @State private var activePathways: Int = 142
    @State private var correlations: Int = 1847
    @State private var showMetrics: Bool = true
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            MedicalBackground(color1: Color(red: 0.01, green: 0.02, blue: 0.06), color2: Color(red: 0.02, green: 0.05, blue: 0.10))
            
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                // Draw connections between layers
                for connection in connections {
                    let fromLayer = layerData[connection.fromLayer]
                    let toLayer = layerData[connection.toLayer]
                    
                    let fromRadius = fromLayer.radius
                    let toRadius = toLayer.radius
                    
                    let fromAngle = connection.fromAngle + rotation
                    let toAngle = connection.toAngle + rotation
                    
                    let fromPoint = CGPoint(
                        x: center.x + cos(fromAngle) * fromRadius,
                        y: center.y + sin(fromAngle) * fromRadius
                    )
                    let toPoint = CGPoint(
                        x: center.x + cos(toAngle) * toRadius,
                        y: center.y + sin(toAngle) * toRadius
                    )
                    
                    var path = Path()
                    path.move(to: fromPoint)
                    path.addLine(to: toPoint)
                    
                    context.stroke(
                        path,
                        with: .color(connection.color.opacity(Double(connection.strength * 0.5))),
                        lineWidth: 1 + connection.strength * 1.5
                    )
                }
                
                // Draw omics layers
                for (index, layer) in layerData.enumerated() {
                    // Layer ring
                    context.stroke(
                        Circle().path(in: CGRect(
                            x: center.x - layer.radius,
                            y: center.y - layer.radius,
                            width: layer.radius * 2,
                            height: layer.radius * 2
                        )),
                        with: .color(layer.color.opacity(0.4)),
                        lineWidth: 2
                    )
                    
                    // Data points on ring
                    for i in 0..<layer.dataPoints {
                        let angle = (CGFloat(i) / CGFloat(layer.dataPoints)) * 2 * .pi + rotation
                        let x = center.x + cos(angle) * layer.radius
                        let y = center.y + sin(angle) * layer.radius
                        
                        let size: CGFloat = layer.pointSizes[i]
                        let activity = layer.activities[i]
                        
                        context.fill(
                            Circle().path(in: CGRect(
                                x: x - size / 2,
                                y: y - size / 2,
                                width: size,
                                height: size
                            )),
                            with: .radialGradient(
                                Gradient(colors: [
                                    layer.color.opacity(Double(activity)),
                                    layer.color.opacity(Double(activity * 0.5)),
                                    .clear
                                ]),
                                center: CGPoint(x: x, y: y),
                                startRadius: 0,
                                endRadius: size / 2
                            )
                        )
                    }
                }
                
                // Center hub
                context.fill(
                    Circle().path(in: CGRect(
                        x: center.x - 30,
                        y: center.y - 30,
                        width: 60,
                        height: 60
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            .purple.opacity(0.8),
                            .purple.opacity(0.4),
                            .purple.opacity(0.1)
                        ]),
                        center: center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
            }
            
            VStack {
                if showMetrics {
                    HStack(spacing: 12) {
                        MedicalMetricCard(
                            icon: "chart.pie.fill",
                            title: "Integration Score",
                            value: String(format: "%.1f", integrationScore),
                            unit: "%",
                            color: .purple,
                            trend: .up
                        )
                        
                        MedicalMetricCard(
                            icon: "network",
                            title: "Active Pathways",
                            value: "\(activePathways)",
                            unit: "",
                            color: .cyan,
                            trend: .stable
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    HStack(spacing: 12) {
                        OmicsLayerLabel(name: "Genomics", color: .blue, icon: "d.circle.fill")
                        OmicsLayerLabel(name: "Transcriptomics", color: .cyan, icon: "t.circle.fill")
                        OmicsLayerLabel(name: "Proteomics", color: .mint, icon: "p.circle.fill")
                        OmicsLayerLabel(name: "Metabolomics", color: .green, icon: "m.circle.fill")
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showMetrics.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showMetrics ? "eye.slash.fill" : "chart.bar.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text(showMetrics ? "Hide" : "Show")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(Capsule().stroke(Color.purple.opacity(0.4), lineWidth: 1))
                        )
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            updateOmicsSimulation()
        }
        .onAppear {
            initializeOmics()
        }
    }
    
    func initializeOmics() {
        let colors: [Color] = [.blue, .cyan, .mint, .green]
        let radii: [CGFloat] = [80, 130, 180, 230]
        let pointCounts = [24, 32, 40, 48]
        
        for i in 0..<4 {
            var pointSizes: [CGFloat] = []
            var activities: [CGFloat] = []
            
            for _ in 0..<pointCounts[i] {
                pointSizes.append(CGFloat.random(in: 4...10))
                activities.append(CGFloat.random(in: 0.3...1.0))
            }
            
            layerData.append(OmicsLayer(
                radius: radii[i],
                color: colors[i],
                dataPoints: pointCounts[i],
                pointSizes: pointSizes,
                activities: activities
            ))
        }
        
        // Create connections
        for _ in 0..<60 {
            let fromLayer = Int.random(in: 0..<3)
            let toLayer = fromLayer + 1
            
            connections.append(OmicsConnection(
                fromLayer: fromLayer,
                toLayer: toLayer,
                fromAngle: CGFloat.random(in: 0...(2 * .pi)),
                toAngle: CGFloat.random(in: 0...(2 * .pi)),
                strength: CGFloat.random(in: 0.3...1.0),
                color: [Color.purple, Color.pink, Color.indigo].randomElement() ?? .purple
            ))
        }
    }
    
    func updateOmicsSimulation() {
        rotation += 0.003
        dataFlow += 0.02
        
        // Update activities
        for i in layerData.indices {
            for j in layerData[i].activities.indices {
                let variation = sin(dataFlow + CGFloat(i) * 0.5 + CGFloat(j) * 0.1) * 0.2
                layerData[i].activities[j] = 0.6 + variation
            }
        }
        
        withAnimation(.easeInOut(duration: 2.0)) {
            integrationScore = 85 + sin(dataFlow * 0.5) * 5
            activePathways = 135 + Int(sin(dataFlow * 0.3) * 15)
        }
    }
}

struct OmicsLayer: Identifiable {
    let id = UUID()
    var radius: CGFloat
    var color: Color
    var dataPoints: Int
    var pointSizes: [CGFloat]
    var activities: [CGFloat]
}

struct OmicsConnection: Identifiable {
    let id = UUID()
    var fromLayer: Int
    var toLayer: Int
    var fromAngle: CGFloat
    var toAngle: CGFloat
    var strength: CGFloat
    var color: Color
}

struct OmicsLayerLabel: View {
    let name: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            
            Text(name)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - 3. DRUG RESPONSE SIMULATION VIEW
struct DrugResponseSimulationView: View {
    @State private var cells: [DrugCell] = []
    @State private var drugMolecules: [DrugMolecule] = []
    @State private var time: CGFloat = 0
    @State private var drugAdded: Bool = false
    @State private var survivalRate: CGFloat = 100.0
    @State private var apoptosisRate: CGFloat = 0.0
    @State private var ic50: CGFloat = 0.0
    @State private var efficacy: CGFloat = 0.0
    @State private var showMetrics: Bool = true
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            MedicalBackground(color1: Color(red: 0.01, green: 0.02, blue: 0.05), color2: Color(red: 0.02, green: 0.04, blue: 0.10))
            
            Canvas { context, size in
                // Drug molecules
                for molecule in drugMolecules {
                    let trailLength = min(8, molecule.trail.count)
                    for i in 0..<trailLength {
                        let index = molecule.trail.count - 1 - i
                        let point = molecule.trail[index]
                        let opacity = CGFloat(trailLength - i) / CGFloat(trailLength) * 0.4
                        
                        context.fill(
                            Circle().path(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)),
                            with: .color(.cyan.opacity(Double(opacity)))
                        )
                    }
                    
                    context.fill(
                        Circle().path(in: CGRect(
                            x: molecule.position.x - molecule.size / 2,
                            y: molecule.position.y - molecule.size / 2,
                            width: molecule.size,
                            height: molecule.size
                        )),
                        with: .radialGradient(
                            Gradient(colors: [
                                .cyan.opacity(0.9),
                                .cyan.opacity(0.5),
                                .cyan.opacity(0.2)
                            ]),
                            center: molecule.position,
                            startRadius: 0,
                            endRadius: molecule.size / 2
                        )
                    )
                }
                
                // Cells
                for cell in cells {
                    let cellColor: Color
                    let glowIntensity: CGFloat
                    
                    switch cell.state {
                    case .healthy:
                        cellColor = .green
                        glowIntensity = 0.6
                    case .affected:
                        cellColor = .orange
                        glowIntensity = 0.8
                    case .apoptotic:
                        cellColor = .red
                        glowIntensity = 0.3
                    case .dead:
                        cellColor = .gray
                        glowIntensity = 0.1
                    }
                    
                    let pulseSize = cell.size * (1 + sin(time * 3 + CGFloat(cell.id.hashValue)) * 0.08)
                    
                    // Cell glow
                    if cell.state != .dead {
                        context.fill(
                            Circle().path(in: CGRect(
                                x: cell.position.x - pulseSize,
                                y: cell.position.y - pulseSize,
                                width: pulseSize * 2,
                                height: pulseSize * 2
                            )),
                            with: .radialGradient(
                                Gradient(colors: [
                                    cellColor.opacity(Double(glowIntensity * 0.3)),
                                    cellColor.opacity(Double(glowIntensity * 0.1)),
                                    .clear
                                ]),
                                center: cell.position,
                                startRadius: 0,
                                endRadius: pulseSize
                            )
                        )
                    }
                    
                    // Cell body
                    context.fill(
                        Circle().path(in: CGRect(
                            x: cell.position.x - pulseSize / 2,
                            y: cell.position.y - pulseSize / 2,
                            width: pulseSize,
                            height: pulseSize
                        )),
                        with: .radialGradient(
                            Gradient(colors: [
                                cellColor.opacity(Double(cell.health)),
                                cellColor.opacity(Double(cell.health * 0.6)),
                                cellColor.opacity(Double(cell.health * 0.2))
                            ]),
                            center: cell.position,
                            startRadius: 0,
                            endRadius: pulseSize / 2
                        )
                    )
                    
                    // Nucleus
                    let nucleusSize = pulseSize * 0.4
                    context.fill(
                        Circle().path(in: CGRect(
                            x: cell.position.x - nucleusSize / 2,
                            y: cell.position.y - nucleusSize / 2,
                            width: nucleusSize,
                            height: nucleusSize
                        )),
                        with: .color(cellColor.opacity(Double(cell.health * 0.5)))
                    )
                }
            }
            
            VStack {
                if showMetrics {
                    HStack(spacing: 12) {
                        MedicalMetricCard(
                            icon: "chart.line.downtrend.xyaxis",
                            title: "Survival Rate",
                            value: String(format: "%.1f", survivalRate),
                            unit: "%",
                            color: survivalRate > 50 ? .green : .red,
                            trend: .down
                        )
                        
                        MedicalMetricCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "Apoptosis Rate",
                            value: String(format: "%.1f", apoptosisRate),
                            unit: "%",
                            color: .orange,
                            trend: .up
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    HStack(spacing: 12) {
                        MedicalMetricCard(
                            icon: "cross.vial.fill",
                            title: "IC50",
                            value: String(format: "%.2f", ic50),
                            unit: "μM",
                            color: .cyan,
                            trend: .stable
                        )
                        
                        MedicalMetricCard(
                            icon: "checkmark.seal.fill",
                            title: "Efficacy",
                            value: String(format: "%.1f", efficacy),
                            unit: "%",
                            color: .purple,
                            trend: .up
                        )
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                if !drugAdded {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            addDrug()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "cross.vial.fill")
                                .font(.system(size: 16, weight: .bold))
                            
                            Text("Add Drug Treatment")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 15, x: 0, y: 8)
                    }
                    .padding(.bottom, 140)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showMetrics.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: showMetrics ? "eye.slash.fill" : "chart.bar.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text(showMetrics ? "Hide" : "Show")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1))
                        )
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            updateDrugSimulation()
        }
        .onAppear {
            initializeCells()
        }
    }
    
    func initializeCells() {
        let bounds = UIScreen.main.bounds
        let cols = 10
        let rows = 14
        let spacing: CGFloat = 45
        let offsetX = (bounds.width - CGFloat(cols) * spacing) / 2
        let offsetY = (bounds.height - CGFloat(rows) * spacing) / 2
        
        for row in 0..<rows {
            for col in 0..<cols {
                let x = offsetX + CGFloat(col) * spacing + spacing / 2
                let y = offsetY + CGFloat(row) * spacing + spacing / 2
                
                cells.append(DrugCell(
                    position: CGPoint(x: x, y: y),
                    size: CGFloat.random(in: 22...30),
                    health: 1.0,
                    state: .healthy
                ))
            }
        }
    }
    
    func addDrug() {
        drugAdded = true
        
        // Create drug molecules
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if drugMolecules.count < 200 {
                let bounds = UIScreen.main.bounds
                drugMolecules.append(DrugMolecule(
                    position: CGPoint(
                        x: CGFloat.random(in: 0...bounds.width),
                        y: -20
                    ),
                    size: CGFloat.random(in: 6...10),
                    velocity: CGPoint(
                        x: CGFloat.random(in: -0.5...0.5),
                        y: CGFloat.random(in: 1.5...3.0)
                    )
                ))
            } else {
                timer.invalidate()
            }
        }
    }
    
    func updateDrugSimulation() {
        time += 0.02
        
        // Update drug molecules
        for i in drugMolecules.indices {
            drugMolecules[i].position.x += drugMolecules[i].velocity.x
            drugMolecules[i].position.y += drugMolecules[i].velocity.y
            
            drugMolecules[i].trail.append(drugMolecules[i].position)
            if drugMolecules[i].trail.count > 12 {
                drugMolecules[i].trail.removeFirst()
            }
            
            // Check collision with cells
            for j in cells.indices {
                if cells[j].state != .dead {
                    let dx = cells[j].position.x - drugMolecules[i].position.x
                    let dy = cells[j].position.y - drugMolecules[i].position.y
                    let distance = sqrt(dx * dx + dy * dy)
                    
                    if distance < cells[j].size / 2 + 5 {
                        cells[j].drugExposure += 0.1
                        
                        if cells[j].drugExposure > 2.0 && cells[j].state == .healthy {
                            cells[j].state = .affected
                        } else if cells[j].drugExposure > 5.0 && cells[j].state == .affected {
                            cells[j].state = .apoptotic
                        } else if cells[j].drugExposure > 8.0 && cells[j].state == .apoptotic {
                            cells[j].state = .dead
                            cells[j].health = 0.1
                        }
                        
                        if cells[j].state != .healthy {
                            cells[j].health = max(0.1, cells[j].health - 0.01)
                        }
                    }
                }
            }
        }
        
        // Remove out-of-bounds molecules
        drugMolecules.removeAll { $0.position.y > UIScreen.main.bounds.height + 20 }
        
        // Update metrics
        let totalCells = CGFloat(cells.count)
        let healthyCells = CGFloat(cells.filter { $0.state == .healthy }.count)
        let apoptoticCells = CGFloat(cells.filter { $0.state == .apoptotic || $0.state == .dead }.count)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            survivalRate = (healthyCells / totalCells) * 100
            apoptosisRate = (apoptoticCells / totalCells) * 100
            
            if drugAdded {
                ic50 = min(8.5, ic50 + 0.02)
                efficacy = min(95.0, apoptosisRate * 1.2)
            }
        }
    }
}

struct DrugCell: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var health: CGFloat
    var state: CellState
    var drugExposure: CGFloat = 0
    
    enum CellState {
        case healthy, affected, apoptotic, dead
    }
}

struct DrugMolecule: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var velocity: CGPoint
    var trail: [CGPoint] = []
}

// MARK: - Shared Components

struct MedicalBackground: View {
    let color1: Color
    let color2: Color
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [color1, color2, color1],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Canvas { context, size in
                for i in 0..<40 {
                    let x = (CGFloat(i) * size.width / 40 + particleOffset * 0.2).truncatingRemainder(dividingBy: size.width)
                    let y = (CGFloat(i * 19) + particleOffset).truncatingRemainder(dividingBy: size.height)
                    
                    context.fill(
                        Circle().path(in: CGRect(x: x, y: y, width: 2, height: 2)),
                        with: .color(.white.opacity(0.1))
                    )
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                particleOffset = UIScreen.main.bounds.height
            }
        }
    }
}

struct MedicalMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    let trend: MetricTrend
    
    enum MetricTrend {
        case up, down, stable
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(color.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    TrendIcon(trend: trend)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct TrendIcon: View {
    let trend: MedicalMetricCard.MetricTrend
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(trendColor)
            .padding(4)
            .background(
                Circle()
                    .fill(trendColor.opacity(0.15))
            )
    }
    
    var iconName: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .orange
        }
    }
}

// MARK: - Preview
#Preview {
    MedicalVisualizationsApp()
}
