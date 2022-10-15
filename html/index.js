let resname = "Fly_PlatescannerV2"
$(function () {

    function displayPlate(bool) {
        if (bool) {
            $("#Kennzeichenscanner").show();
        } else {
            $("#Kennzeichenscanner").hide();
        }
    };

    function displayLog(bool) {
        if (bool) {
            $("#logDiv").show();
        } else {
            $("#logDiv").hide();
        }
    };

    function displaySpeed(bool) {
        if (bool) {
            $("#speedDiv").show();
        } else {
            $("#speedDiv").hide();
        }
    };

    displayPlate(false)
    displayLog(false)
    displaySpeed(false)

    

    window.addEventListener('message', function(event) {
        var item = event.data;

        //Plate
        if (item.type == "plateVisible") {
            if (item.status == true) {
                displayPlate(true)
            } else {
                displayPlate(false)
            }
            return
        }

        //Speed
        if (item.type == "speedVisible") {
            if (item.status == true) {
                displaySpeed(true)
            } else {
                displaySpeed(false)
            }
            return
        }



        //Log
        if (item.type == "logVisible") {
            if (item.status == true) {
                displayLog(true)
            } else {
                displayLog(false)
            }
            return
        }

        if (item.type == "logAddEntry") {
            var htmlCode = '<p class="logentry" id=' + item.id + '><br><span id="logName">NAME: ' + item.Name + '</span> <span id="logFine">FINE: ' + item.Fine + '€</span><br><span id="logDate">DATE: ' + item.Date + '</span><br><span id="logSpeed">SPEED: ' + item.Speed + '</span><br><button id="logRevoke" onclick="revoke(' + item.id + ')">REVOKE</button></p>'
            $('#logDiv').append(htmlCode);
        }

        if (item.type == "logReload") {
            $(".logentry").remove();
        }

    });

    $(document).keyup(function(e) {
        if (e.key == "Escape") {
            $.post('http://' + resname +'/exit', JSON.stringify({}));
       }
    });



})

function revoke(index) {
    $.post('http://' + resname + '/revoke', JSON.stringify({
        id: index
    }));
}

function setSpeed() {
    let inputValue = $("#speedField").val()
    $.post('http://' + resname + '/setspeed', JSON.stringify({
        speed: inputValue
    }));
}

function speedClose() {
    $.post('http://' + resname +'/exit', JSON.stringify({}));
}

function speedStart() {
    $.post('http://' + resname + '/setActive', JSON.stringify({
        state: true
    }));
}

function speedStop() {
    $.post('http://' + resname + '/setActive', JSON.stringify({
        state: false
    }));
}