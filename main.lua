local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local waypoints = {}  -- Lista de rotas definidas pelo jogador
local currentRouteIndex = 1
local currentWaypointIndex = 1
local isIAActive = false
local isMoving = false
local humanoid = nil
local tween = nil

local function moveToNextWaypoint()
    if currentWaypointIndex <= #waypoints[currentRouteIndex] then
        local targetPosition = waypoints[currentRouteIndex][currentWaypointIndex]
        local character = player.Character
        if character and character:IsDescendantOf(game) then
            humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                tween = TweenService:Create(humanoid, TweenInfo.new(1, Enum.EasingStyle.Linear), {MoveTo = targetPosition})
                tween:Play()
                tween.Completed:Connect(function()
                    currentWaypointIndex = currentWaypointIndex + 1
                    moveToNextWaypoint()
                end)
            end
        end
    else
        currentWaypointIndex = 1
        print("Rota concluída!")
    end
end

local function toggleIA()
    isIAActive = not isIAActive
    if isIAActive then
        if #waypoints == 0 then
            warn("Defina a rota clicando no local onde você quer ir.")
            isIAActive = false
        else
            moveToNextWaypoint()
        end
    else
        if tween then
            tween:Cancel()
            tween = nil
        end
        currentWaypointIndex = 1
        print("Movimento da IA interrompido.")
    end
end

local function onCharacterAdded(character)
    local function onTouch(hit)
        if hit:IsDescendantOf(game.Workspace) then
            -- Lógica de detecção de obstáculos avançada (a ser implementada)
            -- Por enquanto, apenas paramos a IA ao tocar em algo
            print("Obstáculo detectado! Parando IA.")
            toggleIA()
        end
    end
    character.Humanoid.Touched:Connect(onTouch)
end

-- Verifica se o jogador local já está no jogo
if player.Character then
    onCharacterAdded(player.Character)
end

-- Conecta o evento CharacterAdded para lidar com novos personagens
player.CharacterAdded:Connect(onCharacterAdded)

-- Interface gráfica para controlar a IA
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 50)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = screenGui

local button = Instance.new("TextButton")
button.Name = "IAButton"
button.Text = "Ativar IA"
button.Size = UDim2.new(1, -20, 0.5, -10)
button.Position = UDim2.new(0, 10, 0, 10)
button.Parent = frame

button.MouseButton1Click:Connect(toggleIA)

-- Função para adicionar uma nova rota
local function addRoute(routeName, waypointsList)
    if not waypoints[routeName] then
        waypoints[routeName] = waypointsList
    else
        warn("Já existe uma rota com esse nome.")
    end
end

-- Exemplo: Adicionando rotas
addRoute("Rota 1", {
    Vector3.new(10, 0, 0),
    Vector3.new(0, 0, 10),
    Vector3.new(-10, 0, 0),
})

addRoute("Rota 2", {
    Vector3.new(-10, 0, 0),
    Vector3.new(0, 0, -10),
    Vector3.new(10, 0, 0),
})

-- Função para mudar entre rotas
local function changeRoute(routeIndex)
    if routeIndex > 0 and routeIndex <= #waypoints then
        currentRouteIndex = routeIndex
        print("Mudando para rota " .. currentRouteIndex)
        currentWaypointIndex = 1
        if isIAActive then
            toggleIA()
            toggleIA() -- Reinicia a IA para iniciar a nova rota
        end
    else
        warn("Rota não encontrada.")
    end
end

-- Exemplo: Mudando para a primeira rota
changeRoute(1)
