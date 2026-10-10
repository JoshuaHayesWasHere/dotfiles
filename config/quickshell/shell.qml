//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

// The workspace overview (Super+A). It shows the focused monitor's ten
// workspaces as a grid of miniatures, each window drawn where it really is.
// Click a window to go to it, click a workspace or press its number to switch,
// Escape to leave. Hyprland owns the key: binds.lua fires the global shortcut
// "quickshell:overviewToggle".

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets

ShellRoot {
    id: root

    property bool open: false

    // Catppuccin Mocha, the same values as hypr/theme.lua.
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color subtext: "#a6adc8"
    readonly property color text: "#cdd6f4"
    readonly property color blue: "#89b4fa"
    readonly property color sapphire: "#74c7ec"

    // workspaces.lua gives every monitor a block of this many workspaces.
    readonly property int block: 10
    readonly property int columns: 5

    function show(workspace) {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspace} })`);
        root.open = false;
    }

    function visit(address) {
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address}" })`);
        root.open = false;
    }

    onOpenChanged: if (open) Hyprland.refreshToplevels()

    GlobalShortcut {
        name: "overviewToggle"
        description: "Toggle the workspace overview"
        onPressed: root.open = !root.open
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData
            readonly property var monitor: Hyprland.monitorFor(modelData)
            // First workspace of this monitor's block, minus one.
            readonly property int offset: monitor && monitor.activeWorkspace
                ? Math.floor((monitor.activeWorkspace.id - 1) / root.block) * root.block : 0

            screen: modelData
            visible: root.open && monitor !== null && Hyprland.focusedMonitor === monitor
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(root.crust.r, root.crust.g, root.crust.b, 0.6)
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.open = false;
                    } else if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                        const digit = event.key - Qt.Key_0;
                        root.show(panel.offset + (digit === 0 ? root.block : digit));
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.open = false
                }

                Rectangle {
                    id: board

                    readonly property real gap: 14
                    // A cell keeps the monitor's shape; the board takes most of its width.
                    readonly property real cellWidth: (panel.width * 0.82 - gap * (root.columns + 1)) / root.columns
                    readonly property real cellHeight: cellWidth * panel.height / panel.width

                    anchors.centerIn: parent
                    width: root.columns * cellWidth + (root.columns + 1) * gap
                    height: grid.height + 2 * gap
                    radius: 16
                    color: root.base
                    border.width: 2
                    border.color: root.sapphire

                    // Swallow clicks between cells so they do not close the overview.
                    MouseArea {
                        anchors.fill: parent
                    }

                    Grid {
                        id: grid

                        x: board.gap
                        y: board.gap
                        columns: root.columns
                        spacing: board.gap

                        Repeater {
                            model: root.block

                            Rectangle {
                                id: cell

                                required property int index
                                readonly property int workspace: panel.offset + index + 1
                                readonly property bool current: panel.monitor && panel.monitor.activeWorkspace
                                    && panel.monitor.activeWorkspace.id === workspace
                                readonly property real ratio: board.cellWidth / panel.width

                                width: board.cellWidth
                                height: board.cellHeight
                                radius: 10
                                color: root.mantle
                                border.width: 2
                                border.color: current ? root.blue : root.surface0
                                clip: true

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.show(cell.workspace)
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: cell.index + 1
                                    color: root.surface1
                                    font.family: "MesloLGS Nerd Font"
                                    font.bold: true
                                    font.pixelSize: cell.height * 0.45
                                }

                                Repeater {
                                    model: Hyprland.toplevels

                                    Rectangle {
                                        id: miniature

                                        required property var modelData
                                        readonly property var info: modelData.lastIpcObject
                                        readonly property bool here: modelData.workspace !== null
                                            && modelData.workspace.id === cell.workspace
                                            && info.at !== undefined
                                        readonly property var entry: here ? DesktopEntries.heuristicLookup(info.class) : null

                                        visible: here
                                        x: here ? (info.at[0] - panel.modelData.x) * cell.ratio : 0
                                        y: here ? (info.at[1] - panel.modelData.y) * cell.ratio : 0
                                        width: here ? info.size[0] * cell.ratio : 0
                                        height: here ? info.size[1] * cell.ratio : 0
                                        radius: 6
                                        color: hover.containsMouse ? root.surface1 : root.surface0
                                        border.width: 1
                                        border.color: hover.containsMouse ? root.blue : root.surface1
                                        clip: true

                                        ScreencopyView {
                                            anchors.fill: parent
                                            anchors.margins: 1
                                            captureSource: miniature.here && root.open ? miniature.modelData.wayland : null
                                            live: true
                                        }

                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.bottom: parent.bottom
                                            anchors.margins: 4
                                            width: Math.min(parent.width - 8, label.implicitWidth + icon.width + 16)
                                            height: 22
                                            radius: 6
                                            color: Qt.rgba(root.crust.r, root.crust.g, root.crust.b, 0.85)
                                            visible: miniature.width > 70 && miniature.height > 40

                                            IconImage {
                                                id: icon

                                                anchors.left: parent.left
                                                anchors.leftMargin: 5
                                                anchors.verticalCenter: parent.verticalCenter
                                                implicitSize: 14
                                                visible: miniature.entry !== null
                                                source: miniature.entry ? Quickshell.iconPath(miniature.entry.icon, true) : ""
                                            }

                                            Text {
                                                id: label

                                                anchors.left: icon.right
                                                anchors.leftMargin: 5
                                                anchors.right: parent.right
                                                anchors.rightMargin: 5
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: miniature.here ? (miniature.info.title || miniature.info.class) : ""
                                                color: root.text
                                                elide: Text.ElideRight
                                                font.family: "MesloLGS Nerd Font"
                                                font.pixelSize: 11
                                            }
                                        }

                                        MouseArea {
                                            id: hover

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.visit(miniature.info.address)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
