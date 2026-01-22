//
//  ContentView.swift
//  iOSpice
//
//  Created by Devin R Cohen on 1/15/26.
//

import SwiftUI
import Charts
import Combine // necessary for ObservableObject



final class SpiceEngineHolder: ObservableObject {
    private var engine: SpiceEngine
    
    init() {
        debugScripts()
        if let scriptsPath = installIfNeeded() {
            scriptsPath.withCString { SpiceEngine.setSpiceScriptsPath($0) }
        }
        engine = SpiceEngine()
        print("INIT OUTPUT SNAPSHOT:")
        print(engine.getOutput())
    }
    
    func getVector(name: String, comp: Component) -> [Double] {
        // Ask how big the vector is
        let required = engine.getVector(name, comp, nil, 0)
        guard required > 0 else { return [] }
        
        // Swift-owned buffer of size 'required'
        var buf = [Double](repeating: 0, count: required)
        
        // provide temporary pointer to Swift's contiguous storage so C can fill it
        let written: Int = buf.withUnsafeMutableBufferPointer { ptr in
            let w = engine.getVector(name, comp, ptr.baseAddress, ptr.count)
            return Int(w)
        }
        
        // trim in case written < required
        buf.removeLast(buf.count - written)
        
        // buffer is now data vector
        return buf
    }
    
    func getVector(name: String) -> [Double] {
        return getVector(name: name, comp: Component.REAL)
    }
    
    func getMessage() {
        print (engine.getOutput())
    }
    
    func sayHello() {
        engine.say_hello()
    }
    
    func runCommand(cmd: String) {
        engine.runCommand(cmd)
    }
    
    func run(netlist: String) {
        engine.runAnalysis(netlist, "run")
    }
}

struct ContentView: View {
    func dBdeg(real: Double, imag: Double) -> (dB: Double, phase: Double) {
        return (10 * log10(real*real + imag*imag), 180.0 / Double.pi*atan2(imag, real))
    }
    
    struct BodePoint: Identifiable {
        let id = UUID()
        var mag_dB: Double
        var phase_deg: Double
        var freq: Double
    }
    
    @State private var bodePoints: [BodePoint] = []
    
    struct TranPoint: Identifiable {
        let id = UUID()
        var value: Double
        var time: Double
    }
    
    @State private var timePoints: [TranPoint] = []
    
    @StateObject private var engineHolder = SpiceEngineHolder()
    let netlist = """
VDIVIDER.CIR
*
VS 1 0 dc 5 ac 1
L1 1 4 0
R1 4 2 1.59154943k
*R2 2 0 7k
C1 2 0 100n
*D1 2 0 DTEST
.model DTEST D(IS=0.1p RS=12m)
.ic V(2)=2
.ac dec 50 1 100meg
.END
"""
    init() {
//        print("resourceURL:", Bundle.main.resourceURL?.path ?? "nil")
//        print("scriptsDir:", Bundle.main.resourceURL?.appendingPathComponent("ngspice_scripts").path ?? "nil")
//        print("spinitExists:", FileManager.default.fileExists(atPath:
//            Bundle.main.resourceURL!.appendingPathComponent("ngspice_scripts/spinit").path
//        ))
    }
    var body: some View {
        VStack {
            Section("RC Filter Frequency Response") {
                if !bodePoints.isEmpty {
                    Chart {
                        ForEach(bodePoints) { p in
                            LineMark(x: .value("Frequency", p.freq),
                                     y: .value("dB", p.mag_dB),
                                     series: .value("", "Magnitude (dB)"))
                            .foregroundStyle(.red)
                            LineMark(x: .value("Frequency", p.freq),
                                     y: .value("°", p.phase_deg),
                                     series: .value("", "Phase (°)"))
                            .foregroundStyle(.green)
                        }
                    }
                    .chartXScale(type: .log)
//                    .chartYAxis(
//                        AxisMarks(
//                            values: [-80, -60, -40, -20, 0, 20]
//                        )
//                    )
                }
            }
            Button("Execute") {
                engineHolder.run(netlist: netlist)
                engineHolder.getMessage()
            }.padding()
            Button("Print Vector") {
                let v2real = engineHolder.getVector(name: "V(2)", comp: Component.REAL)
                let v2imag = engineHolder.getVector(name: "V(2)", comp: Component.IMAG)
                let freq = engineHolder.getVector(name: "frequency")
                let len = min(v2real.count, v2imag.count, freq.count)
                bodePoints.removeAll()
                for i in 0...len-1 {
                    let (dB, deg) = dBdeg(real: v2real[i], imag: v2imag[i])
//                    print (String(format: "%.2f", freq[i]) + " Hz " +
//                           String(format: "%.2f", dB) + " dB, " +
//                           String(format: "%.2f", deg) + "°")
//                    bodePoints[i].freq = freq[i]
//                    bodePoints[i].mag_dB = dB
//                    bodePoints[i].phase_deg = deg
                    bodePoints.append(BodePoint(mag_dB: dB, phase_deg: deg, freq: freq[i]))
                }
            }.padding().border(Color.white)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
