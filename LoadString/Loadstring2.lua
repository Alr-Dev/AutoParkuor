-- Variáveis globais
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local waypoints = {}
local currentRouteIndex = 1
local currentWaypointIndex = 1
local isIAActive = false
local humanoid = nil
local tween = nil
local buttonGui = nil

-- Tempo de movimento entre waypoints (em segundos)
local moveTime = 1  -- Altere conforme necessário
