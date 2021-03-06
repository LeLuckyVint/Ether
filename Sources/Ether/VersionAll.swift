// The MIT License (MIT)
//
// Copyright (c) 2017 Caleb Kleveter
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Console
import Foundation
import Helpers

public final class VersionAll: Command {
    public let id = "all"
    
    public var help: [String] = [
        "Outputs the name of each package installed and its version"
    ]
    
    public var signature: [Argument] = []
    
    public let console: ConsoleProtocol
    
    public init(console: ConsoleProtocol) {
        self.console = console
    }
    
    public func run(arguments: [String]) throws {
        let fetchingDataBar = console.loadingBar(title: "Getting Package Data")
        fetchingDataBar.start()
        
        let manager = FileManager.default
        if let packageData = manager.contents(atPath: "\(manager.currentDirectoryPath)/Package.resolved") {
            if let packageJson = try packageData.json()?["object"] as? [String: AnyObject] {
                if let pins = packageJson["pins"] as? [[String: AnyObject]] {
                    fetchingDataBar.finish()
                    for package in pins {
                        console.output("\(package["package"] ?? "N/A" as AnyObject): ", style: .success, newLine: false)
                        if let state = package["state"] as? [String: AnyObject] {
                            console.output("v\(state["version"] ?? "N/A" as AnyObject)", style: .plain, newLine: true)
                        }
                    }
                }
            } else {
                throw fail(bar: fetchingDataBar, with: "Unable to parse data from Package.resolved.")
            }
        } else if let packageData = manager.contents(atPath: "\(manager.currentDirectoryPath)/Package.pins") {
            if let packageJson = try packageData.json()?["pins"] as? [[String: AnyObject]] {
                fetchingDataBar.finish()
                for package in packageJson {
                    console.output("\(package["package"] ?? "N/A" as AnyObject): ", style: .success, newLine: false)
                    console.output("v\(package["version"] ?? "N/A" as AnyObject)", style: .plain, newLine: true)
                }
            } else {
                throw fail(bar: fetchingDataBar, with: "Unable to parse data from Package.pins.")
            }
        } else {
            throw fail(bar: fetchingDataBar, with: "Make sure you are in the root of an SPM project.")
        }
    }
}
