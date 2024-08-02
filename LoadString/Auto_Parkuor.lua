-- Início da medição de tempo
local startTime = os.clock()

-- Créditos
print('Loading..')
print('============\\============')
         print('CONTEXT = {')
         print('Author = alr_dev')
         print('Version = 0.1')
         print('Release = 02/08/2024')
print('}')

-- Variáveis principais
local player = game.Players.LocalPlayer
local PathfindingService = game:GetService("PathfindingService")
local waypoints = {} -- Armazena os pontos de interesse (waypoints)
local currentWaypointIndex = 1
local jumpForce = 200 -- Força do pulo
local walkSpeed = 16 -- Velocidade de movimento
local aiEnabled = false -- Habilita/desabilita a IA
local editMode = false -- Habilita/desabilita o modo de edição
local savedRoutes = {} -- Armazena as rotas salvas
local aiSkill = 5 -- Habilidade da IA (1 a 10)
local calculationInterval = 1 -- Tempo de cálculo em segundos
local language = "en-us" -- Idioma padrão, pode ser mudado para pt-br ou es-es e também en-us

-- Tabela de tradução
local translations = {
	["en-us"] = {
		["Edit Mode"] = "Edit Mode",
		["Done"] = "Done",
		["Save Route"] = "Save Route",
		["Load Route"] = "Load Route",
		["AI Skill: "] = "AI Skill: ",
		["Increase Skill"] = "Increase Skill",
		["Mode activated."] = "Edit mode activated.",
		["Mode deactivated."] = "Edit mode deactivated.",
		["Waypoint added: "] = "Waypoint added: "
	},
	["pt-br"] = {
		["Edit Mode"] = "Modo de Edição",
		["Done"] = "Concluído",
		["Save Route"] = "Salvar Rota",
		["Load Route"] = "Carregar Rota",
		["AI Skill: "] = "Habilidade da IA: ",
		["Increase Skill"] = "Aumentar Habilidade",
		["Mode activated."] = "Modo de edição ativado.",
		["Mode deactivated."] = "Modo de edição desativado.",
		["Waypoint added: "] = "Waypoint adicionado: "
	},
	["es-es"] = {
		["Edit Mode"] = "Modo de Edición",
		["Done"] = "Hecho",
		["Save Route"] = "Guardar Ruta",
		["Load Route"] = "Cargar Ruta",
		["AI Skill: "] = "Habilidad de la IA: ",
		["Increase Skill"] = "Aumentar Habilidad",
		["Mode activated."] = "Modo de edición activado.",
		["Mode deactivated."] = "Modo de edición desactivado.",
		["Waypoint added: "] = "Waypoint añadido: "
	}
}

-- Função para traduzir texto
local function translate(text)
	return translations[language][text] or text
end

-- Função para mover para o próximo waypoint
local function moveToNextWaypoint()
	if currentWaypointIndex <= #waypoints then
		local targetPosition = waypoints[currentWaypointIndex].Position
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid:MoveTo(targetPosition)
				humanoid.WalkSpeed = walkSpeed
				humanoid.JumpPower = jumpForce
			end
		end
	else
		print("Parkour concluído!")
		aiEnabled = false
	end
end

-- Função para verificar se o jogador está spawnado
local function checkPlayerSpawned()
	if player.Character then
		player.Character.Humanoid.MoveToFinished:Connect(function(reached)
			if reached then
				currentWaypointIndex = currentWaypointIndex + 1
				moveToNextWaypoint()
			end
		end)
	else
		wait(1) -- Aguarda 1 segundo antes de verificar novamente
		checkPlayerSpawned()
	end
end

checkPlayerSpawned()

-- Função para alternar a IA
local function toggleAI()
	aiEnabled = not aiEnabled
	if aiEnabled then
		currentWaypointIndex = 1
		moveToNextWaypoint()
		avoidObstacles()
	end
end

-- Função para evitar obstáculos
local function avoidObstacles()
	while aiEnabled do
		wait(calculationInterval) -- Intervalo de cálculo ajustado pela habilidade da IA

		-- Pega o waypoint atual
		local currentWaypoint = waypoints[currentWaypointIndex]
		if not currentWaypoint then return end -- Verifica se o waypoint atual existe

		-- Calcula um novo caminho que evita o obstáculo
		local character = player.Character
		if character and character.PrimaryPart then
			local path = PathfindingService:CreatePath({
				AgentRadius = 2, -- Ajuste conforme necessário
				AgentHeight = 5, -- Ajuste conforme necessário
				AgentCanJump = true,
				AgentJumpHeight = jumpForce / 10,
				AgentMaxSlope = 45
			})

			local success, errorMessage = pcall(function()
				path:ComputeAsync(character.PrimaryPart.Position, currentWaypoint.Position)
			end)

			if success and path.Status == Enum.PathStatus.Complete then
				-- Pega os novos waypoints
				local newWaypoints = path:GetWaypoints()

				-- Atualiza os waypoints
				waypoints = {}
				for _, waypoint in ipairs(newWaypoints) do
					table.insert(waypoints, { Position = waypoint.Position })
				end

				-- Move para o próximo waypoint
				currentWaypointIndex = 1
				moveToNextWaypoint()
			else
				print("Erro ao calcular o caminho: " .. errorMessage)
			end
		end
	end
end

-- Função para salvar waypoints
local function saveWaypoints()
	local routeCode = ""
	for _, waypoint in ipairs(waypoints) do
		routeCode = routeCode .. waypoint.Position.X .. "," .. waypoint.Position.Y .. "," .. waypoint.Position.Z .. ";"
	end
	table.insert(savedRoutes, routeCode)
	print("Waypoints salvos com sucesso!")
end

-- Função para carregar waypoints
local function loadWaypoints(routeCode)
	waypoints = {}
	for waypoint in string.gmatch(routeCode, "([^;]+)") do
		local coords = {}
		for coord in string.gmatch(waypoint, "([^,]+)") do
			table.insert(coords, tonumber(coord))
		end
		local position = Vector3.new(coords[1], coords[2], coords[3])
		table.insert(waypoints, { Position = position })
	end
	print("Waypoints carregados com sucesso!")
end

-- UI para adicionar e editar waypoints
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
local editModeButton = Instance.new("TextButton", ScreenGui)
editModeButton.Size = UDim2.new(0, 100, 0, 50)
editModeButton.Position = UDim2.new(0, 0, 0, 0)
editModeButton.Text = translate("Edit Mode")

editModeButton.MouseButton1Click:Connect(function()
	editMode = not editMode
	if editMode then
		editModeButton.Text = translate("Done")
		-- Lógica para habilitar a edição de waypoints
		print(translate("Mode activated."))
	else
		editModeButton.Text = translate("Edit Mode")
		-- Lógica para desabilitar a edição de waypoints
		print(translate("Mode deactivated."))
	end
end)

local saveButton = Instance.new("TextButton", ScreenGui)
saveButton.Size = UDim2.new(0, 100, 0, 50)
saveButton.Position = UDim2.new(0, 100, 0, 0)
saveButton.Text = translate("Save Route")

saveButton.MouseButton1Click:Connect(function()
	saveWaypoints()
end)

local loadButton = Instance.new("TextButton", ScreenGui)
loadButton.Size = UDim2.new(0, 100, 0, 50)
loadButton.Position = UDim2.new(0, 200, 0, 0)
loadButton.Text = translate("Load Route")

loadButton.MouseButton1Click:Connect(function()
	if #savedRoutes > 0 then
		loadWaypoints(savedRoutes[1])
		toggleAI()
	end
end)

-- UI para ajustar a habilidade da IA
local skillLabel = Instance.new("TextLabel", ScreenGui)
skillLabel.Size = UDim2.new(0, 100, 0, 50)
skillLabel.Position = UDim2.new(0, 300, 0, 0)
skillLabel.Text = translate("AI Skill: ") .. aiSkill

local skillButton = Instance.new("TextButton", ScreenGui)
skillButton.Size = UDim2.new(0, 100, 0, 50)
skillButton.Position = UDim2.new(0, 400, 0, 0)
skillButton.Text = translate("Increase Skill")

skillButton.MouseButton1Click:Connect(function()
	aiSkill = math.min(aiSkill + 1, 10)
	calculationInterval = 1 / aiSkill
	skillLabel.Text = translate("AI Skill: ") .. aiSkill
end)

-- Botão para mudar o idioma
local languageButton = Instance.new("TextButton", ScreenGui)
languageButton.Size = UDim2.new(0, 100, 0, 50)
languageButton.Position = UDim2.new(0, 500, 0, 0)
languageButton.Text = "Language"

local function updateUIText()
	editModeButton.Text = translate("Edit Mode")
	saveButton.Text = translate("Save Route")
	loadButton.Text = translate("Load Route")
	skillLabel.Text = translate("AI Skill: ") .. aiSkill
	skillButton.Text = translate("Increase Skill")
end

languageButton.MouseButton1Click:Connect(function()
	if language == "en-us" then
		language = "pt-br"
	elseif language == "pt-br" then
		language = "es-es"
	else
		language = "en-us"
	end
	updateUIText()
end)

-- Adiciona eventos de clique para editar waypoints
ScreenGui.MouseButton1Click:Connect(function()
	if editMode then
		local mouse = player:GetMouse()
		local position = mouse.Hit.Position
		table.insert(waypoints, { Position = Vector3.new(position.X, position.Y, position.Z) })
		print(translate("Waypoint added: ") .. tostring(position))
	end
end)

-- Fim da medição de tempo
local endTime = os.clock()
local loadTime = endTime - startTime
print(string.format("Script carregado em %.2f segundos.", loadTime))

-- Inicialização das funções
toggleAI()
