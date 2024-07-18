-- Função para exibir uma tela de carregamento
local function showLoadingScreen()
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "LoadingGui"
    loadingGui.Parent = game.Players.LocalPlayer.PlayerGui

    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    loadingFrame.BackgroundTransparency = 0.7
    loadingFrame.Parent = loadingGui

    local loadingText = Instance.new("TextLabel")
    loadingText.Text = "Auto Parkour IA\nLoading..."
    loadingText.Size = UDim2.new(0.8, 0, 0.2, 0)
    loadingText.Position = UDim2.new(0.1, 0, 0.4, 0)
    loadingText.Font = Enum.Font.SourceSansBold
    loadingText.TextSize = 24
    loadingText.TextColor3 = Color3.new(1, 1, 1)
    loadingText.Parent = loadingFrame
end

-- Função para criar uma GUI de botões
local function createButtonGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    local activateButton = Instance.new("TextButton")
    activateButton.Name = "ActivateButton"
    activateButton.Text = "Activate AI"
    activateButton.Size = UDim2.new(1, -20, 0.5, -10)
    activateButton.Position = UDim2.new(0, 10, 0, 10)
    activateButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    activateButton.Parent = frame

    local deactivateButton = Instance.new("TextButton")
    deactivateButton.Name = "DeactivateButton"
    deactivateButton.Text = "Deactivate AI"
    deactivateButton.Size = UDim2.new(1, -20, 0.5, -10)
    deactivateButton.Position = UDim2.new(0, 10, 0.5, 5)
    deactivateButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    deactivateButton.Parent = frame

    return activateButton, deactivateButton
end

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

-- Função para mover para o próximo waypoint
local function moveToNextWaypoint()
    if currentWaypointIndex <= #waypoints[currentRouteIndex] then
        local targetPosition = waypoints[currentRouteIndex][currentWaypointIndex]
        local character = player.Character
        if character and character:IsDescendantOf(game) then
            humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                tween = TweenService:Create(humanoid, TweenInfo.new(moveTime, Enum.EasingStyle.Linear), {Position = targetPosition})
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

-- Função para alternar a IA entre ativa e inativa
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

-- Função para adicionar uma nova rota
local function addRoute(routeName, waypointsList)
    if not waypoints[routeName] then
        waypoints[routeName] = waypointsList
    else
        warn("Já existe uma rota com esse nome.")
    end
end

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

-- Função para lidar com a adição do personagem
local function onCharacterAdded(character)
    local function onTouch(hit)
        if hit:IsDescendantOf(game.Workspace) then
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

-- Cria a interface gráfica de botões
buttonGui = createButtonGui()

-- Conecta os eventos de clique dos botões
buttonGui[1].MouseButton1Click:Connect(toggleIA)
buttonGui[2].MouseButton1Click:Connect(toggleIA)

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
