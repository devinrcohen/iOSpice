//
//  ContentView.swift
//  iOSpice
//
//  Created by Devin R Cohen on 1/15/26.
//

import SwiftUI
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
    @StateObject private var engineHolder = SpiceEngineHolder()
    let netlist = """
VDIVIDER.CIR
*
VS 1 0 dc 5 ac 1
L1 1 4 100p
R1 4 2 3k
*R2 2 0 7k
C1 2 0 1n
*D1 2 0 DTEST
.model DTEST D(IS=0.1p RS=12m)
.ic V(2)=2
.ac dec 10 1 100meg
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
            Button("Say hello") {
                //engineHolder.sayHello()
                print ("\"version\"\n")
                print ("=========\n")
                engineHolder.runCommand(cmd: "version")
                print ("\"set\"\n")
                print ("=========\n")
                engineHolder.runCommand(cmd: "set")
            }
            .padding()
            Button("Execute") {
                //engineHolder.runCommand(cmd: "destroy all")
                //engineHolder.runCommand(cmd: "remcirc")
                //engineHolder.runCommand(cmd: "destroy all")
                //engineHolder.runCommand(cmd: "version")
                //engineHolder.runCommand(cmd: "run")
                engineHolder.run(netlist: netlist)
                engineHolder.getMessage()
            }.padding()
            Button("Help") {
                //engineHolder.runCommand(cmd: "help")
                //engineHolder.runCommand(cmd: "help reset")
                //engineHolder.runCommand(cmd: "help remcirc")
            }.padding().border(Color.white)
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
