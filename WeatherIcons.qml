pragma Singleton
import QtQuick

QtObject {
    readonly property var codes: ({
        0:  { emoji: "☀️", label: "Clear sky" },
        1:  { emoji: "🌤️", label: "Mainly clear" },
        2:  { emoji: "⛅",  label: "Partly cloudy" },
        3:  { emoji: "☁️", label: "Overcast" },
        45: { emoji: "🌫️", label: "Fog" },
        48: { emoji: "🌫️", label: "Rime fog" },
        51: { emoji: "🌦️", label: "Light drizzle" },
        53: { emoji: "🌦️", label: "Drizzle" },
        55: { emoji: "🌧️", label: "Dense drizzle" },
        61: { emoji: "🌧️", label: "Slight rain" },
        63: { emoji: "🌧️", label: "Rain" },
        65: { emoji: "🌧️", label: "Heavy rain" },
        71: { emoji: "🌨️", label: "Slight snow" },
        73: { emoji: "🌨️", label: "Snow" },
        75: { emoji: "❄️",  label: "Heavy snow" },
        80: { emoji: "🌦️", label: "Rain showers" },
        81: { emoji: "🌧️", label: "Rain showers" },
        82: { emoji: "⛈️", label: "Violent showers" },
        85: { emoji: "🌨️", label: "Snow showers" },
        95: { emoji: "⛈️", label: "Thunderstorm" },
        96: { emoji: "⛈️", label: "Thunder + hail" },
        99: { emoji: "⛈️", label: "Thunder + hail" }
    })

    function emoji(code) {
        var c = nearest(code)
        return codes[c] !== undefined ? codes[c].emoji : "❓"
    }

    function describe(code) {
        var c = nearest(code)
        return codes[c] !== undefined ? codes[c].label : ("Code " + Math.round(code))
    }

    function nearest(code) {
        var target = Math.round(code)
        if (codes[target] !== undefined)
            return target
        var best = 0
        var bestDiff = Infinity
        for (var key in codes) {
            var diff = Math.abs(parseInt(key) - target)
            if (diff < bestDiff) { bestDiff = diff; best = parseInt(key) }
        }
        return best
    }
}
