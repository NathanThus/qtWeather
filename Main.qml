import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtGraphs

ApplicationWindow {
    id: window
    width: 1280
    height: 820
    visible: true
    title: "QtWeather (Magic Mirror)"

    // ---------------------------------------------------------------
    // Dark palette used throughout the UI
    // ---------------------------------------------------------------
    readonly property color bgColor: "#121212"
    readonly property color surfaceColor: "#1E1E1E"
    readonly property color surfaceAltColor: "#262626"
    readonly property color borderColor: "#333333"
    readonly property color textPrimary: "#F2F2F2"
    readonly property color textSecondary: "#A0A0A0"
    readonly property color accentColor: "#4FC3F7"

    // Series color palette (also used for the checkbox swatches)
    readonly property var seriesColors: ({
        temperature: "#FF7043",
        apparentTemperature: "#FFCA28",
        precipitation: "#42A5F5",
        windspeed: "#66BB6A",
        winddirection: "#AB47BC",
        visibility: "#26C6DA",
        weathercode: "#EC407A"
    })

    background: Rectangle { color: bgColor }

    property var hourlyLabels: []
    property var hourlyTemperature: []
    property var hourlyApparentTemperature: []
    property var hourlyPrecipitation: []
    property var hourlyWindspeed: []
    property var hourlyWinddirection: []
    property var hourlyVisibility: []
    property var hourlyWeathercode: []

    property var dailyLabels: ["Today", "Tomorrow", "Day 3"]
    property var dailyUvIndexMax: [6.2, 3.8, 8.6]

    property real seed: 42

    function pseudoRandom(i) {
        var x = Math.sin((i + seed) * 12.9898) * 43758.5453
        return x - Math.floor(x) // [0,1)
    }

    function generateDummyData() {
        var hours = 48
        var codes = [0, 1, 2, 3, 45, 61, 63, 80, 95]

        var labels = []
        var temp = []
        var apparent = []
        var precip = []
        var wind = []
        var windDir = []
        var vis = []
        var wcode = []

        var now = new Date()
        now.setMinutes(0, 0, 0)

        for (var i = 0; i < hours; i++) {
            var t = new Date(now.getTime() + i * 3600 * 1000)
            var hh = ("0" + t.getHours()).slice(-2)
            var dayLabel = i % 24 === 0 ? (Qt.formatDate(t, "ddd") + " ") : ""
            labels.push(dayLabel + hh + ":00")

            // Smooth daily cycle + a little noise
            var dayCurve = Math.sin((i / 24) * Math.PI * 2 - Math.PI / 2)
            var baseTemp = 17 + dayCurve * 6 + pseudoRandom(i) * 1.5
            temp.push(Math.round(baseTemp * 10) / 10)
            apparent.push(Math.round((baseTemp - 1.5 + pseudoRandom(i + 100) * 1.5) * 10) / 10)

            var rain = pseudoRandom(i + 200)
            precip.push(rain > 0.75 ? Math.round(rain * 8 * 10) / 10 : 0)

            wind.push(Math.round((8 + pseudoRandom(i + 300) * 20) * 10) / 10)
            windDir.push(Math.round(pseudoRandom(i + 400) * 360))
            vis.push(Math.round((6 + pseudoRandom(i + 500) * 18) * 10) / 10)

            var codeIndex = Math.floor(pseudoRandom(i + 600) * codes.length)
            wcode.push(codes[codeIndex])
        }

        hourlyLabels = labels
        hourlyTemperature = temp
        hourlyApparentTemperature = apparent
        hourlyPrecipitation = precip
        hourlyWindspeed = wind
        hourlyWinddirection = windDir
        hourlyVisibility = vis
        hourlyWeathercode = wcode

        chart.rebuildSeries()
    }

    Component.onCompleted: generateDummyData()

    // ---------------------------------------------------------------
    // Toolbar
    // ---------------------------------------------------------------
    header: ToolBar {
        height: 56
        background: Rectangle { color: surfaceColor; border.color: borderColor; border.width: 1 }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Label {
                text: "🌤️  Open-Meteo Weather"
                color: textPrimary
                font.pixelSize: 18
                font.bold: true
            }

            Label {
                text: "(Data)"
                color: textSecondary
                font.pixelSize: 12
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "🔀 Shuffle"
                onClicked: { seed = Math.random() * 1000; generateDummyData() }
                background: Rectangle {
                    color: parent.down ? Qt.darker(accentColor, 1.3) : accentColor
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "#0B1A21"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // ---------------------------------------------------------------
    // Main content
    // ---------------------------------------------------------------
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // -------- Left column: Daily UV Index Max cards --------------
        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: surfaceColor
            radius: 10
            border.color: borderColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Label {
                    text: "☀️ Daily UV Index Max"
                    color: textPrimary
                    font.pixelSize: 15
                    font.bold: true
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: borderColor }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: dailyUvIndexMax

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 72
                        radius: 8
                        color: surfaceAltColor
                        border.color: uvColor(modelData)
                        border.width: 1

                        function uvColor(v) {
                            if (v < 3) return "#66BB6A"
                            if (v < 6) return "#FFCA28"
                            if (v < 8) return "#FF7043"
                            if (v < 11) return "#EC407A"
                            return "#AB47BC"
                        }

                        function uvRiskLabel(v) {
                            if (v < 3) return "Low"
                            if (v < 6) return "Moderate"
                            if (v < 8) return "High"
                            if (v < 11) return "Very High"
                            return "Extreme"
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2

                            Label {
                                text: index < dailyLabels.length ? dailyLabels[index] : ("Day " + (index + 1))
                                color: textSecondary
                                font.pixelSize: 12
                            }

                            RowLayout {
                                spacing: 6
                                Label {
                                    text: modelData.toFixed(1)
                                    color: uvColor(modelData)
                                    font.pixelSize: 22
                                    font.bold: true
                                }
                                Label {
                                    text: uvRiskLabel(modelData)
                                    color: textSecondary
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }
        }

        // -------- Right column: legend + hourly graph -----------------
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // Series toggles - plain checkboxes, no
            Flow {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    spacing: 4
                    CheckBox {
                        id: toggleTemp
                        checked: true
                        onToggled: chart.applyVisibility()
                        indicator: Rectangle {
                            implicitWidth: 16; implicitHeight: 16
                            x: toggleTemp.leftPadding; y: (toggleTemp.height - height) / 2
                            radius: 3
                            color: surfaceAltColor
                            border.color: seriesColors.temperature
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: seriesColors.temperature
                                visible: toggleTemp.checked
                            }
                        }
                    }
                    Label { text: "🌡️ Temperature (°C)"; color: textPrimary; font.pixelSize: 13 }
                }

                RowLayout {
                    spacing: 4
                    CheckBox {
                        id: toggleApparent
                        checked: true
                        onToggled: chart.applyVisibility()
                        indicator: Rectangle {
                            implicitWidth: 16; implicitHeight: 16
                            x: toggleApparent.leftPadding; y: (toggleApparent.height - height) / 2
                            radius: 3
                            color: surfaceAltColor
                            border.color: seriesColors.apparentTemperature
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: seriesColors.apparentTemperature
                                visible: toggleApparent.checked
                            }
                        }
                    }
                    Label { text: "🤔 Apparent Temp (°C)"; color: textPrimary; font.pixelSize: 13 }
                }

                RowLayout {
                    spacing: 4
                    CheckBox {
                        id: togglePrecip
                        checked: true
                        onToggled: chart.applyVisibility()
                        indicator: Rectangle {
                            implicitWidth: 16; implicitHeight: 16
                            x: togglePrecip.leftPadding; y: (togglePrecip.height - height) / 2
                            radius: 3
                            color: surfaceAltColor
                            border.color: seriesColors.precipitation
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: seriesColors.precipitation
                                visible: togglePrecip.checked
                            }
                        }
                    }
                    Label { text: "🌧️ Precipitation (mm)"; color: textPrimary; font.pixelSize: 13 }
                }

                RowLayout {
                    spacing: 4
                    CheckBox {
                        id: toggleWind
                        checked: true
                        onToggled: chart.applyVisibility()
                        indicator: Rectangle {
                            implicitWidth: 16; implicitHeight: 16
                            x: toggleWind.leftPadding; y: (toggleWind.height - height) / 2
                            radius: 3
                            color: surfaceAltColor
                            border.color: seriesColors.windspeed
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: seriesColors.windspeed
                                visible: toggleWind.checked
                            }
                        }
                    }
                    Label { text: "💨 Windspeed (km/h)"; color: textPrimary; font.pixelSize: 13 }
                }

                RowLayout {
                    spacing: 4
                    CheckBox {
                        id: toggleWindDir
                        checked: false
                        onToggled: chart.applyVisibility()
                        indicator: Rectangle {
                            implicitWidth: 16; implicitHeight: 16
                            x: toggleWindDir.leftPadding; y: (toggleWindDir.height - height) / 2
                            radius: 3
                            color: surfaceAltColor
                            border.color: seriesColors.winddirection
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: seriesColors.winddirection
                                visible: toggleWindDir.checked
                            }
                        }
                    }
                    Label { text: "🧭 Wind Direction (°)"; color: textPrimary; font.pixelSize: 13 }
                }

                RowLayout {
                    spacing: 4
                    CheckBox {
                        id: toggleVisibility
                        checked: false
                        onToggled: chart.applyVisibility()
                        indicator: Rectangle {
                            implicitWidth: 16; implicitHeight: 16
                            x: toggleVisibility.leftPadding; y: (toggleVisibility.height - height) / 2
                            radius: 3
                            color: surfaceAltColor
                            border.color: seriesColors.visibility
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: seriesColors.visibility
                                visible: toggleVisibility.checked
                            }
                        }
                    }
                    Label { text: "👁️ Visibility (km)"; color: textPrimary; font.pixelSize: 13 }
                }

                RowLayout {
                    spacing: 4
                    CheckBox {
                        id: toggleWeatherCode
                        checked: false
                        onToggled: chart.applyVisibility()
                        indicator: Rectangle {
                            implicitWidth: 16; implicitHeight: 16
                            x: toggleWeatherCode.leftPadding; y: (toggleWeatherCode.height - height) / 2
                            radius: 3
                            color: surfaceAltColor
                            border.color: seriesColors.weathercode
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8; height: 8; radius: 2
                                color: seriesColors.weathercode
                                visible: toggleWeatherCode.checked
                            }
                        }
                    }
                    Label { text: "☁️ Weather Code"; color: textPrimary; font.pixelSize: 13 }
                }
            }

            // ---- The chart itself --------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: surfaceColor
                radius: 10
                border.color: borderColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    Label {
                        text: "Hourly Forecast"
                        color: textPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }

                    GraphsView {
                        id: chart
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        theme: GraphsTheme {
                            colorScheme: GraphsTheme.ColorScheme.Dark
                            backgroundVisible: false
                            plotAreaBackgroundVisible: false
                            gridVisible: true
                            grid.mainColor: window.borderColor
                            grid.subColor: window.borderColor
                            axisX.mainColor: window.borderColor
                            axisX.labelTextColor: window.textSecondary
                            axisY.mainColor: window.borderColor
                            axisY.labelTextColor: window.textSecondary
                        }

                        axisX: BarCategoryAxis {
                            id: axisX
                            labelsAngle: -90
                        }

                        axisY: ValueAxis {
                            id: axisY
                            min: 0
                            max: 10
                        }

                        LineSeries {
                            id: tempSeries
                            name: "Temperature (°C)"
                            color: seriesColors.temperature
                            width: 2
                        }
                        LineSeries {
                            id: apparentSeries
                            name: "Apparent Temperature (°C)"
                            color: seriesColors.apparentTemperature
                            width: 2
                        }
                        LineSeries {
                            id: precipSeries
                            name: "Precipitation (mm)"
                            color: seriesColors.precipitation
                            width: 2
                        }
                        LineSeries {
                            id: windSeries
                            name: "Windspeed (km/h)"
                            color: seriesColors.windspeed
                            width: 2
                        }
                        LineSeries {
                            id: windDirSeries
                            name: "Wind Direction (°)"
                            color: seriesColors.winddirection
                            width: 2
                            visible: false
                        }
                        LineSeries {
                            id: visibilitySeries
                            name: "Visibility (km)"
                            color: seriesColors.visibility
                            width: 2
                            visible: false
                        }
                        LineSeries {
                            id: weatherCodeSeries
                            name: "Weather Code"
                            color: seriesColors.weathercode
                            width: 2
                            visible: false
                        }

                        // Rebuilds every series from the dummy hourly arrays.
                        function rebuildSeries() {
                            var labels = window.hourlyLabels
                            var n = labels.length
                            if (n === 0)
                                return

                            // Thin the x-axis labels so they don't overlap:
                            // show roughly one label every 4 hours.
                            var step = Math.max(1, Math.round(n / 24))
                            var categories = []
                            for (var i = 0; i < n; i++)
                                categories.push(i % step === 0 ? labels[i] : "")
                            axisX.categories = categories

                            fillSeries(tempSeries, window.hourlyTemperature)
                            fillSeries(apparentSeries, window.hourlyApparentTemperature)
                            fillSeries(precipSeries, window.hourlyPrecipitation)
                            fillSeries(windSeries, window.hourlyWindspeed)
                            fillSeries(windDirSeries, window.hourlyWinddirection)
                            fillSeries(visibilitySeries, window.hourlyVisibility)
                            fillSeries(weatherCodeSeries, window.hourlyWeathercode)

                            applyVisibility()
                        }

                        function fillSeries(series, values) {
                            series.clear()
                            for (var i = 0; i < values.length; i++)
                                series.append(i, values[i])
                        }

                        // Applies checkbox state to series visibility and
                        // recomputes the Y-axis range from the visible data.
                        function applyVisibility() {
                            tempSeries.visible = toggleTemp.checked
                            apparentSeries.visible = toggleApparent.checked
                            precipSeries.visible = togglePrecip.checked
                            windSeries.visible = toggleWind.checked
                            windDirSeries.visible = toggleWindDir.checked
                            visibilitySeries.visible = toggleVisibility.checked
                            weatherCodeSeries.visible = toggleWeatherCode.checked

                            var activeArrays = []
                            if (tempSeries.visible) activeArrays.push(window.hourlyTemperature)
                            if (apparentSeries.visible) activeArrays.push(window.hourlyApparentTemperature)
                            if (precipSeries.visible) activeArrays.push(window.hourlyPrecipitation)
                            if (windSeries.visible) activeArrays.push(window.hourlyWindspeed)
                            if (windDirSeries.visible) activeArrays.push(window.hourlyWinddirection)
                            if (visibilitySeries.visible) activeArrays.push(window.hourlyVisibility)
                            if (weatherCodeSeries.visible) activeArrays.push(window.hourlyWeathercode)

                            var lo = 0, hi = 10
                            var first = true
                            for (var a = 0; a < activeArrays.length; a++) {
                                var arr = activeArrays[a]
                                for (var i = 0; i < arr.length; i++) {
                                    var v = arr[i]
                                    if (first) { lo = v; hi = v; first = false }
                                    else { if (v < lo) lo = v; if (v > hi) hi = v }
                                }
                            }
                            if (first) { lo = 0; hi = 10 }
                            var pad = Math.max(1, (hi - lo) * 0.1)
                            axisY.min = lo - pad
                            axisY.max = hi + pad
                        }
                    }
                }
            }
        }
    }
}
