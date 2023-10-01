//"TEST-Hopper"
//scriot Ver "Hopper Computer v5"


//user setting
set countdowntime to 0.
set tgalt to 150000. //target altitude.
set ldlim to 1. //touchdown speed
set LZ to latlng(-0.117877,-74.548558).
set exalt to 28.3. //ship radar
set mecofuel to 24000.


//file loading
runoncepath("0:/TEST-Hopper_Function_Ver5.ks").


//main script
lock truealt to alt:radar - exalt.
startup().
wait until ag1.
screen().

until runmode = 0 {
    //screen log
    shiptime().
    print print_time + "     " at (17, 5).
    shipspeed().
    print print_speed + " (km/h)     " at (17, 6).
    shipaltitude().
    print print_altitude + " (km)     " at (17, 7).
    shiprunmode().
    print print_runmode at (17, 4).

    if runmode = 1 { //countdown
        if countdowntime = 0 {
            stage.
            set nowtime to sessiontime.
            set ascentth to (20 / acc()).
            set runmode to 2.
            lock throttle to thrott().
            lock steering to steer().
        }
        else {
            set countdowntime to countdowntime - 1.
            wait 1.
        }
    }
    else if runmode = 2 { //ascent
        if ship:liquidfuel < mecofuel {
            rcs on.
            brakes on.
            set runmode to 3.
        }
    }
    else if runmode = 3 { //boost back
        if errordiff() < 50 {
            set entryth to (55.2 / acc()).
            set runmode to 4.
        }
    }
    else if runmode = 4 { //entry
        if ship:altitude < 50000 and ship:verticalspeed > -300 {
            ag2 on.
            rcs off.
            set runmode to 5.
        }
    }
    else if runmode = 5 { //gliding
        if alt:radar < 4000 {
            set runmode to 6.
        }
    }
    else if runmode = 6 { //landing
        if not gear and truealt < 100 {
            gear on.
        }
        if ship:verticalspeed > - 300 and throttle < 0.35 {
            ag3 on.
        }
        if ship:status = "landed" or ship:status = "splashed" {
            set runmode to 7.
        }
    }
    else if runmode = 7 { //touch down
        unlock steering.
    }
}