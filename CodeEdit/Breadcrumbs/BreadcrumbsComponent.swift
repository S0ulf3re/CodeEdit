//
//  BreadcrumbsComponent.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 18.03.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences

struct BreadcrumbsComponent: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @ObservedObject
    var workspace: WorkspaceDocument

    private let fileItem: WorkspaceClient.FileItem

    @State
    var position: NSPoint?

    init(_ workspace: WorkspaceDocument, fileItem: WorkspaceClient.FileItem) {
        self.workspace = workspace
        self.fileItem = fileItem
    }

    private var image: String {
        fileItem.parent == nil ? "square.dashed.inset.filled" : fileItem.systemImage
    }

    /// If current `fileItem` has no parent, it's the workspace root directory
    /// else if current `fileItem` has no children, it's the opened file
    /// else it's a folder
    private var color: Color {
        fileItem.parent == nil
        ? .accentColor
        : fileItem.children?.isEmpty ?? true
        ? fileItem.iconColor
        : .secondary
    }

    var body: some View {
        HStack(alignment: .center) {
            /// Get location in window
            /// Can't use it outside `HStack` becuase it'll make the whole `BreadcrumsComponent` flexiable.
            GeometryReader { geometry in
                HStack {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                        .foregroundStyle(prefs.preferences.general.fileIconStyle == .color ? color : .secondary)
                        .onAppear {
                            self.position = NSPoint(
                                x: geometry.frame(in: .global).minX,
                                y: geometry.frame(in: .global).midY
                            )
                        }
                }.frame(height: geometry.size.height)
            }
            Text(fileItem.fileName)
                .foregroundStyle(.primary)
                .font(.system(size: 11))
        }
        .onTapGesture {
            if let siblings = fileItem.parent?.children?.sortItems(foldersOnTop: true), !siblings.isEmpty {
                let menu = BreadcrumsMenu(siblings, workspace: workspace)
                if let position = position,
                   let windowHeight = NSApp.keyWindow?.contentView?.frame.height {
                    let pos = NSPoint(x: position.x, y: windowHeight - 72) // 72 = offset from top to breadcrumbs bar
                    menu.popUp(positioning: menu.item(withTitle: fileItem.fileName),
                               at: pos,
                               in: NSApp.keyWindow?.contentView)
                }
            }
        }
    }
}
