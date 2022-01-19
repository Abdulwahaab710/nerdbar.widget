#
# ──────────────────────────────────────────────── II ──────
#   :::::: I N F O : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────
#

  #
  # ─── ALL COMMANDS ───────────────────────────────────────────────────────────
  #

  commands =
    battery:  "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto " +
              "| cut -f1 -d';'"
    time:     "date +\"%I:%M %p\""
    wifi:     "/System/Library/PrivateFrameworks/Apple80211.framework/" +
              "Versions/Current/Resources/airport -I | " +
              "sed -e \"s/^ *SSID: //p\" -e d"
    volume:   "osascript -e 'output volume of (get volume settings)'"
    charging: "pmset -g batt"
    weather: "curl -s 'https://wttr.in/?format=%c%t&period=60&City=Ottawa' || true"
    cpu: "ESC=$(printf \"\e\"); ps -A -o %cpu | awk '{s+=$1} END {a=sprintf(\"%.0f\", s/4); print a \"%\"}'"
    network: "$HOME/Library/Application\\ Support/Übersicht/widgets/networktraffic"
    # cpuTemp: "[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby \"$@\"; } && chruby 2.7.1 && /Users/abdulwahaabahmed/.gem/ruby/2.7.1/bin/istats cpu | grep -o '\d*\.\d*°C' | cat"

  #
  # ─── COLORS ─────────────────────────────────────────────────────────────────
  #

  colors =
    black:   "#1d2021"
    grey:    "#a89984"
    red:     "#fb4924"
    green:   "#b8bb26"
    yellow:  "#fabd2f"
    blue:    "#458588"
    magenta: "#b16286"
    cyan:    "#689d6a"
    white:   "#ebdbb2"

  #
  # ─── COMMAND ────────────────────────────────────────────────────────────────
  #

  command: "echo " +
           "$(#{ commands.battery }):::" +
           "$(#{ commands.time }):::" +
           "$(#{ commands.wifi }):::" +
           "$(#{ commands.volume }):::" +
           "$(#{ commands.charging }):::" +
           "$(#{ commands.weather }):::" +
           "$(#{ commands.cpu }):::" +
           "$(#{ commands.network }):::" # +
           # "$(#{ commands.cpuTemp }):::"

  #
  # ─── REFRESH ────────────────────────────────────────────────────────────────
  #

  refreshFrequency: 1000

  #
  # ─── RENDER ─────────────────────────────────────────────────────────────────
  #

  render: ( ) ->
    """
    <link rel="stylesheet" href="./font-awesome/font-awesome.min.css" />
    <div class="info-item down">
      <div class="icon"><i class="fa fa-arrow-down"></i></div>
      <span class="down-output"></span>
    </div>
    <div class="info-item up">
      <div class="icon"><i class="fa fa-arrow-up"></i></div>
      <span class="up-output"></span>
    </div>
    <div class="info-item memory">
      <div class="icon"><i class="fa fa-memory"></i></div>
      <span class="cpu-output"></span>
    </div>
    <div class="info-item cpu">
      <div class="icon"><i class="fa fa-microchip"></i></div>
      <span class="cpu-output"></span>
    </div>
    <div class="info-item weather">
      <!--<div class="icon weather-icon-output"></div>-->
      <div class="icon"><i id="weather-icon-fa" class="fa"></i></div>
      <span class="weather-output"></span>
    </div>
    <div class="info-item volume">
      <div class="icon"><span class="volume-icon"></span></div>
      <span class="volume-output"></span>
    </div>
    <div class="info-item wifi">
      <div class="icon"><i class="fa fa-wifi"></i></div>
      <span class="wifi-output"></span>
    </div>
    <div class="info-item battery">
      <div class="icon"><span class="battery-icon"></span></div>
      <span class="battery-output"></span>
    </div>
    <div class="info-item time">
      <div class="icon"><i class="fa fa-clock"></i></div>
      <span class="time-output"></span>
    </div>
    """

  #
  # ─── RENDER ─────────────────────────────────────────────────────────────────
  #

  update: ( output ) ->
    output = output.split( /:::/g )

    battery  = output[ 0 ]
    time     = output[ 1 ]
    wifi     = output[ 2 ]
    volume   = output[ 3 ]
    charging = output[ 4 ]
    weather = output[ 5 ]
    cpu = output[ 6 ]
    network = output[ 7 ].split('@')
    down = @convertBytes(network[0])
    up = @convertBytes(network[1])
    # cpuTemp = output[ 8 ]

    weatherIcon = weather?.slice(0, 1)
    weatherOutputInC = weather.slice(2, -1).replace(/\+/g, "")
    weatherOutput = if weatherOutputInC == "" then "?" else weatherOutputInC

    $( ".battery-output" ) .text( "#{ battery }" )
    $( ".time-output" )    .text( "#{ time }" )
    $( ".wifi-output" )    .text( "#{ wifi }" )
    $( ".volume-output" )  .text( "#{ volume }%" )
    # $( ".weather-icon-output" )  .text( "#{ weatherIcon }%" )
    $( ".weather-output" ) .text( "#{ weatherOutput }" )
    $( ".cpu-output" )  .text( "#{ cpu }" )
    # $( ".cpu-temp-output" )  .text( "#{ cpuTemp }" )
    $( ".up-output" )  .text( "#{ up }" )
    $( ".down-output" )  .text( "#{ down }" )
    $("#weather-icon-fa").addClass("fa-#{@getWeatherIcon(weatherIcon?.codePointAt(0)?.toString(16))}")

    @handleBattery(
      Number( battery.replace( /%/g, "" ) ),
      !charging.indexOf( "discharging" ) >= 0
    )
    @handleVolume( Number( volume ) )

  getWeatherIcon: (icon) ->
    debugger
    icons =
      "2728": "cloud",
      "2601": "cloud",
      "1d32b": "water",
      "2744": "snow",
      "1f326": "cloud-sun-rain",
      "1f327": "cloud-rain",
      "1f328": "snow",
      "26c5": "cloud-sun",
      "2600": "sun",
      "1f329": "bolt",
      "26c8": "bolt",
    _icon = if icons[icon] then icons[icon] else 'cloud'
    _icon



    # "Unknown":             "✨"
    # "Cloudy":              "☁️"
    # "Fog":                 "🌫"
    # "HeavyRain":           "🌧"
    # "HeavyShowers":        "🌧"
    # "HeavySnow":           "❄️"
    # "HeavySnowShowers":    "❄️"
    # "LightRain":           "🌦"
    # "LightShowers":        "🌦"
    # "LightSleet":          "🌧"
    # "LightSleetShowers":   "🌧"
    # "LightSnow":           "🌨"
    # "LightSnowShowers":    "🌨"
    # "PartlyCloudy":        "⛅️"
    # "Sunny":               "☀️"
    # "ThunderyHeavyRain":   "🌩"
    # "ThunderyShowers":     "⛈"
    # "ThunderySnowShowers": "⛈"
    # "VeryCloudy": "☁️"

  #
  # ─── HANDLE BATTERY ─────────────────────────────────────────────────────────
  #

  handleBattery: ( percentage, charging ) ->
    batteryIcon = switch
      when charging          then "fa-bolt"
      when percentage <=  12 then "fa-battery-0"
      when percentage <=  25 then "fa-battery-1"
      when percentage <=  50 then "fa-battery-2"
      when percentage <=  75 then "fa-battery-3"
      when percentage <= 100 then "fa-battery-4"
    $( ".battery-icon" ).html( "<i class=\"fa #{ batteryIcon }\"></i>" )

    color = if percentage < 25 then colors.red else colors.green
    $( ".battery .icon" ).css( "background-color", color )

  #
  # ─── HANDLE VOLUME ──────────────────────────────────────────────────────────
  #

  handleVolume: ( volume ) ->
    volumeIcon = switch
      when volume ==   0 then "fa-volume-off"
      when volume <=  50 then "fa-volume-down"
      when volume <= 100 then "fa-volume-up"
    $( ".volume-icon" ).html( "<i class=\"fa #{ volumeIcon }\"></i>" )

  #
  # ─── STYLE ──────────────────────────────────────────────────────────────────
  #

  style: """
    .battery .icon
      background-color: #{ colors.green }
    .time .icon
      background-color: #{ colors.magenta }
    .wifi .icon
      background-color: #{ colors.grey }
    .volume .icon
      background-color: #{ colors.cyan }
    .weather .icon
      background-color: #{ colors.magenta }
    .cpu .icon
      background-color: #{ colors.yellow }
    .memory .icon
      background-color: #{ colors.blue }
    .down .icon
      background-color: #{ colors.magenta }
    .up .icon
      background-color: #{ colors.green }

    .info-item
      display: flex
      padding: 0 5px 0 0
      background-color: #{ colors.white }
      margin-right: 15px
      .icon
        padding: 1px 5px
        margin-right: 5px

    display: flex

    top: 3.5px
    right: 0px
    font-family: 'PragmataPro Liga'
    font-size: 13px
    font-smoothing: antialiasing
    z-index: 0
  """

# ──────────────────────────────────────────────────────────────────────────────
  convertBytes: (bytes) ->
    kb = bytes / 1024
    return @usageFormat(kb)

  usageFormat: (kb) ->
      mb = kb / 1024
      if mb < 0.01
        return "0.00mb"
      return "#{parseFloat(mb.toFixed(2))}MB"
