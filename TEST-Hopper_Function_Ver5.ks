lock truealt to alt:radar - exalt.
local boostbackturn to true.

function startup {
    set runmode to 1.
    set steeringmanager:rollts to 50.
    set terminal:width to 37.
    set terminal:height to 9.
    clearscreen.
    core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
    print "Press 1 to launch" at (2, 1).

    //pidloop
    set boostbackyaw to pidloop(0.1, 0.1, 0.01, -10, 10).
    set entryyaw to pidloop(20, 15, 250, -60, 60).
    set entrypitch to pidloop(20, 15, 250, -60, 60).
    set glidyaw to pidloop(60, 25, 8000, -45, 45).
    set glidpitch to pidloop(60, 25, 8000, -45, 45).
    set landyaw to pidloop(80, 60, 6500, -35, 35).
    set landpitch to pidloop(80, 60, 6500, -35, 35).
    set landth to pidloop(0.05, 0.1, 0.006, 0, 1).

    set boostbackyaw:setpoint to 0.
    set entryyaw:setpoint to 0.
    set entrypitch:setpoint to 0.
    set glidyaw:setpoint to 0.
    set glidpitch:setpoint to 0.
    set landyaw:setpoint to 0.
    set landpitch:setpoint to 0.
}

function thrott {
    if runmode = 2 {
        return ascentth.
    }
    else if runmode = 3 {
        if boostbackturn = true {
            return 0.
        }
        else {
            if errordiff() < 30000 {
                return errordiff() / 30000.
            }
            else {
                return 1.
            }
        }
    }
    else if runmode = 4 {
        if ship:altitude < 50000 {
            return entryth.
        }
    }
    else if runmode = 5 {
        return 0.
    }
    else if runmode = 6 {
        landthpid().
        if landthpoint < - ldlim {
            set landth:setpoint to landthpoint.
        }
        else {
            set landth:setpoint to - ldlim.
        }

        return landth:update(time:seconds, ship:verticalspeed).
    }
    else if runmode = 7 {
        return 0.
    }
}

function steer {
    if runmode = 2 {
        if ship:airspeed > 100 {
            if pitchangle() > 0 {
               return heading(90, 90 - (ship:apoapsis / 1000), 0).
            }
            else {
                return heading(90, 0, 0).
            }
        }
        else return heading(90, 90, 0).
    }
    else if runmode = 3 {
        if boostbackturn = true {
            if pitchangle() > 165 {
                set boostbackturn to false.
            }
            if pitchangle() + 10 < 165 {
                return heading(90, pitchangle() + 10, 0).
            }
            else {
                return heading(90, 165, 0).
            }
        }
        else {
            return heading(90, 165, 0) - boostbackpid().
        }
    }
    else if runmode = 4 {
        if ship:altitude < 50000 {
            return entrypos - entrypid().
        }
        else if ship:altitude < 70000 {
            set entrypos to ship:srfretrograde.
            return ship:srfretrograde.
        }
        else {
            return heading(90, 90, 0).
        }
    }
    else if runmode = 5 {
        if ship:altitude < 30000 {
            return ship:srfretrograde + glidpid().
        }
        else {
            return ship:srfretrograde.
        }
    }
    else if runmode = 6 {
        if truealt > 500 {
            return ship:srfretrograde - landpid().
        }
        else {
            if truealt > 50 and ship:groundspeed > 0.5 {
                set steeringmanager:maxstoppingtime to 0.5.
                return ship:srfretrograde.
            }
            else {
                return heading(90,90,0).
            }
        }
    }
}

function pitchangle {
    return 90 - arctan2(vdot(vcrs(ship:up:vector, ship:north:vector), facing:forevector), vdot(ship:up:vector, facing:forevector)).
}

function impactpoint {
    if addons:tr:hasimpact {
        return addons:tr:impactpos.
    }
    else {
        return ship:geoposition.
    }
}

function lngerror {
    return impactpoint():lng - LZ:lng.
}

function laterror {
    return impactpoint():lat - LZ:lat.
}

function errorvector {
    return impactpoint():position - LZ:position.
}

function errordiff {
    return sqrt((errorvector():x) ^ 2 + (errorvector():z) ^ 2).
}

function boostbackpid {
    return r(boostbackyaw:update(time:seconds, laterror()), 0, 0).
}

function entrypid {
    return r(entryyaw:update(time:seconds, laterror()), entrypitch:update(time:seconds, lngerror()), 0).
}

function glidpid {
    return r(glidyaw:update(time:seconds, laterror()), glidpitch:update(time:seconds, lngerror()), 0).
}

function landpid {
    return r(landyaw:update(time:seconds, laterror()), landpitch:update(time:seconds, lngerror()), 0).
}

function landthpid {
    set landthpoint to - ((abs(truealt) ) / (sqrt(abs(ship:verticalspeed)))).
}

function acc {
    return ship:maxthrust / ship:mass.
}

function screen {
    print "MISSION NAME: " + "TEST-Hopper" at (2, 1).
    print "----------------------------------" at (2, 3).
    print "RUNMODE: "at (3, 4).
    print "MISSION TIME: " at (3, 5).
    print "SPEED: " at (3, 6).
    print "ALTITUDE: " at (3, 7).
    print "__________________________________" at (2, 8).
}

function shiptime {
    if runmode = 1 {
        set cdhour to floor(countdowntime / 3600).
            if cdhour < 10 {
                set print_cdhour to "0" + cdhour.
            }
            else {
                set print_cdhour to cdhour.
            }
        set cdminute to floor((countdowntime - cdhour * 3600) / 60).
            if cdminute < 10 {
                set print_cdminute to "0" + cdminute.
            }
            else {
                set print_cdminute to cdminute.
            }
        set cdsecond to floor(countdowntime - (cdhour * 3600 + cdminute * 60)).
            if cdsecond < 10 {
                set print_cdsecond to "0" + cdsecond.
            }
            else {
               set print_cdsecond to cdsecond.
            }
        set print_time to "T- " + print_cdhour + ":" + print_cdminute + ":" + print_cdsecond.
    }

    else if runmode > 1 {
        set ship_missiontime to sessiontime - nowtime.
        set hour to floor(ship_missiontime / 3600).
        if hour < 10 {
                set print_hour to "0" + hour.
            }
        else {
            set print_hour to hour.
        }
        set minute to floor((ship_missiontime - hour * 3600) / 60).
        if minute < 10 {
            set print_minute to "0" + minute.
        }
        else {
            set print_minute to minute.
        }
        set second to floor(ship_missiontime - (hour * 3600 + minute * 60)).
        if second < 10 {
            set print_second to "0" + second.
        }
        else {
            set print_second to second.
        }
        set print_time to "T+ " + print_hour + ":"+ print_minute + ":" + print_second.
    }
}

function shipspeed {
    set print_speed to round(ship:airspeed * 3.6).
}

function shipaltitude {
    if ship:altitude / 1000 >= 100 {
        set print_altitude to floor(ship:altitude / 1000).
    }
    else {
        set ship_altitude to floor(ship:altitude / 1000, 1).
        set few to (ship_altitude - floor(ship:altitude / 1000)).
        if few = 0 {
            set print_altitude to ship_altitude + ".0".
        }
        else {
            set print_altitude to ship_altitude.
        }
    }
}

function shiprunmode {
    if runmode = 1 {
        set print_runmode to "1: COUNTDOWN".
    }
    else if runmode = 2 {
        set print_runmode to "2: ASCENT   ".
    }
    else if runmode = 3 {
        set print_runmode to "3: BOOST BACK".
    }
    else if runmode = 4 {
        set print_runmode to "4: ENTRY     ".
    }
    else if runmode = 5 {
        set print_runmode to "5: GLIDING".
    }
    else if runmode = 6 {
        set print_runmode to "6: LANDING".
    }
    else if runmode = 7 {
        set print_runmode to "7: TOUCH DOWN".
    }
}