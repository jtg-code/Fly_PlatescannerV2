Config = {}

Config.Locale = 'de'


--Global Config
Config.Menutype = 2 --1: ESX Menu --2: HTML Menu
Config.NeedJob = true --Need a job for this? (recommended)
Config.Notify = 2 -- 1: Native Notify, 2: ESX Notify, 3: Custom Notify

--Save Speedcamera settings
Config.SaveLog = true -- Save log in DB?
Config.SpeedMenu = "speedcamera" -- Speedcamera settings
Config.SpeedCamera = "prop_tv_cam_02" -- Speedcamera prop
Config.SetupTime = 5 * 1000 -- 5 Seconds
Config.Fine = 3 -- Dollor per KM/H too much

--Plate settings
Config.EnableScanner = "scanner" -- Start the Platescanner
Config.UseFlyGarage = false --Using my Fly Garage with Fly Vehicleshop? (Outdated)



--Jobs what are able to use it (Platescanner and Speedcamera)
Config.AllowedJobs = {
    "police",
    "fib"
}

--Cars what have the abbility for this (Platescaner)
Config.Cars = {
    "police",
    "police2",
    "police3"
}

--Default speed when the cam gets triggered
Config.DefaulSpeed = 10.0 --in KM/H

Config.NeedJob2 = true
Config.Billcommand = "bills" -- How to open the list of bills you received
Config.Checkplate = "checkplate"  -- To check a plate (only ESX Garage)
Config.Platelog = "platelog" -- To open the platelog where you can see the last plates