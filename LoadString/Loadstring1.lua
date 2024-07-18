local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local waypoints = {}  -- List of routes defined by the player
local currentRouteIndex = 1
local currentWaypointIndex = 1
local isIAActive = false
local isMoving = false
local humanoid = nil
local tween = nil

local auto = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alr-Dev/AutoParkuor/main/main.lua",true))()
auto = true
