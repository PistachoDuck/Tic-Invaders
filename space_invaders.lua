-- title:  space_invaders
-- author: Pistacho
-- desc:   Lmao
-- input:  keyboard
-- script: lua

gameInitialised = false
-- Posicion inicial
ini_pos_x = 120
ini_pos_y = 128

x = ini_pos_x
y = ini_pos_y

-- Variables PlayerShip
ship_speed  = 1.2
ship_sprite = 0

scn_size_x  = 240
scn_size_y  = 136

playerShip = {
	position  = { x=ini_pos_x, y=ini_pos_y },

	speed     = 1,

	sprite        	= 2,
	sprite_size_x 	= 8,
	sprite_size_y 	= 8,
	anchura 		= 8,
	altura			= 8,
	
	bulletOffset = {
		x = 3,
		y = 2
	}
}

-- Balas de jugador y Misiles de aliens
playerBullets		= {}
maxPlayerBullets 	= 2

alienmissiles		= {}
maxAlienMissiles	= 10

-- Variables para los aliens
aliens 	= {}
alienRows       	= 6
alienColumns    	= 8
alienHSpacing   	= 12
alienVSpacing   	= 12
alienDirection  	= 1
alienSpeed      	= 4
alienVSpeed     	= 8
alienMaxX       	= scn_size_x - 8
alienMinX       	= 8
alienMaxY       	= 0
alienMinY       	= 0
alienDelay      	= 30
alienCounter    	= alienDelay
alienVOffset		= 6

-- Animacion Aliens
alienMovNumFrames 		= 2
alienMovFrameCounter	= 0

alienStepSoundNote		= 4
alienStepSoundCounter	= 0
alienStepSoundBaseNote	= 10


alienRowTypes = {}

alienRowTypes[1] = {baseSprite = 16}
alienRowTypes[2] = {baseSprite = 16}
alienRowTypes[3] = {baseSprite = 32}
alienRowTypes[4] = {baseSprite = 32}
alienRowTypes[5] = {baseSprite = 48}
alienRowTypes[6] = {baseSprite = 48}
-- Tabla con explosiones
explosions = {}

-- Elementos de la UI
playerScore = 0
playerLives	= 3
-- Valores del gamestate
stateStartGame		= 0
statePlayGame		= 1
stateNewLife		= 2
stateGameOver		= 3
stateAllAliensDead	= 4
stateInitGame		= 5

gameState = stateInitGame

alienNumbers = 0
-- Time generico
timer = 0

function TIC()
	if 		(	gameState 	== stateStartGame 		) then
		startGameTIC()
	elseif 	( 	gameState	== statePlayGame 		) then
		playGameTIC()
	elseif 	( 	gameState	== stateNewLife 		) then
		newLifeTIC()
	elseif 	( 	gameState	== stateGameOver		) then
		gameOverTIC()
	elseif	(	gameState	== stateAllAliensDead	) then
		allAlliensDeadTIC()
	elseif (	gameState	== stateInitGame		) then
		initGame()
	end
end
function initGame()
	cls()
	print("Presioan 'Z'",60,scn_size_y/2)

	if (btnp(4)) then
		music(0,0,-1,true)
		gameState = stateStartGame
	end
end
function allAlliensDeadTIC()
	timer = timer + 1
	cls()
	if ( timer < 180 ) then
	-- esperar a que la explosion termine
	print("SIGUIENTE RONDA!!!",80,scn_size_y/2)
	else
		-- resetear grid de aliens
		initAliens()
		alienNumbers = 0
		gameState = statePlayGame
	end -- if

	-- Dibujar lo que seguira en pantalla
	drawPlayerShip()
	moveAlienMissiles()
	checkMissileCollision()
	drawScoreBoard()
	drawExplosions()
end -- allAliensDeadTIC()


function startGameTIC()
	cls()
	print("SPACE INVADER",0,20,11,0,3)
	print("Presiona Z para empezar",10,40)
	print("Z : Disparar",80,90,12)
	print("<- -> : Moverse",66,100,12)
	print("By: PistachoDuck",150,120,7)
	if (btnp(4)) then
		gameState = statePlayGame
	end
end
function gameOverTIC()
	cls()
	print("GAMEOVER",90,60)
	print("Presiona Z para empezar de nuevo",20,80)
	
	if (btnp(4)) then
		restartGame()
	end
	
	drawAliens()
	drawScoreBoard()
end -- end gameOverTIC()

function restartGame()
	gameInitialised = false
	alienNumbers = 0
	playerShip.position.x = ini_pos_x
	gameState = statePlayGame
end

function newLifeTIC()
	timer = timer + 1

	if ( timer < 120 ) then
	-- esperar a que la explosion termine
	drawPlayerShip()
	else
		-- Que pasara despues del tiempo
		if ( playerLives == 0 ) then
			-- GameOver
			gameState = stateGameOver
		else
			-- Reanudar Partida
			playerShip.position.x = ini_pos_x
			for bullet = 1, maxPlayerBullets do
				playerBullets[bullet].active = false
			end -- end for
			for index, missl in ipairs(alienmissiles) do
					table.remove( alienmissiles, index )
			end -- for

			gameState = statePlayGame
		end
	end

	cls()

	drawScoreBoard()
	drawExplosions()
end -- end newLifeTIC()

function playGameTIC()
	-- Revisamos si las variables se han inicializado
	if (gameInitialised == false) then
		initialiseGame()
	end
	-- Update
	cls()

	movePlayerShip()
	moveAliens()

	checkPlayerFire()
	movePlayerBullet()
	moveAlienMissiles()
	checkBulletCollision()
	checkMissileCollision()
	-- Render
	drawScoreBoard()
	drawPlayerBullet()
	drawPlayerShip()
	drawAliens()
	drawExplosions()
	drawAlienMissile()
	

end -- end TIC

function movePlayerShip()

	--INPUTS DEL JUGADOR
	if ( btn(2) ) then
		playerShip.position.x =
			playerShip.position.x - playerShip.speed
			playerShip.sprite = 3
	elseif ( btn(3) ) then
	playerShip.position.x =
			playerShip.position.x + playerShip.speed
			playerShip.sprite = 4
	else
		playerShip.sprite = 2
	end
	-- LIMITES DEL JUGADOR
	playerShip.position.x = checkLimits( playerShip.position.x, 0, scn_size_x - playerShip.sprite_size_x )

end --end movePlayerShip

function checkPlayerFire()

	local bulletFired = false
	local bullet = 1

	-- Ver si se presiona el boton
	if ( btnp(4) ) then
	--Revisar cada slot
		repeat
			-- Si no esta activa entonces:
			if (not	BulletFired ) then
			--Si la bala a disparar no esta activa entonces:
				if ( 	not playerBullets[bullet].active ) then
					-- Que la posicion de la bala se vaya hacia las posicion del jugador
					--Ergo, que se dispare
					playerBullets[bullet].position = {
						x = playerShip.position.x + playerShip.bulletOffset.x,
						y = playerShip.position.y + playerShip.bulletOffset.y
					}
					-- Declaramos el estado de la bala seleccionada como "activa" pues se esta disparando actualmente
					playerBullets[bullet].active = true
					-- Evitamos que se disparen mas balas
					bulletFired = true
					sfx(1,40,10,2)
				end -- not playerBullets[bullet].active
			end -- bulletFired == false
			bullet = bullet + 1	
		until (bullet > maxPlayerBullets) or (bulletFired)
	
	else

	end --button end
end -- checkPlayerFire

function movePlayerBullet()
	-- Por cada bala...
	for bullet = 1, maxPlayerBullets do
		if (playerBullets[bullet].active) then
		-- Mover la bala hacia arriba
		playerBullets[bullet].position.y = playerBullets[bullet].position.y - playerBullets[bullet].speed
		end -- playerBullet.active

		-- Checamos si la bala pasa la pantalla en y
		-- si pasa se vuelve "inactiva"
		if (playerBullets[bullet].position.y < 0) then
			playerBullets[bullet].active = false
		end -- if
	end -- for
end -- movePlayerBullet

function drawPlayerBullet()
	-- Por cada bala hacemos:
	for bullet = 1, maxPlayerBullets do
	-- Dibujar la bala del jugador
	-- line(startX,startY,endX,endY,color)
		if (playerBullets[bullet].active) then
			line(
			playerBullets[bullet].position.x,
			playerBullets[bullet].position.y,
			playerBullets[bullet].position.x,
			playerBullets[bullet].position.y + playerBullets[bullet].lenght,
			playerBullets[bullet].color
			)
		end -- if
	end -- end for
end -- drawPlayerBullet

function initPlayerBullets()
	-- Declaramos las balas con un arreglo for
	for bullet = 1,maxPlayerBullets do
		playerBullets[bullet] = {
		position = {x = 0, y = 0},
			lenght 	= 5,
			color  	= 14,
			speed  	= 2,
			active 	= false,
			altura 	= 5,
			anchura	= 1
			}
	end
end -- initPlayerBullets
function drawPlayerShip()

	--Dibujar la nave del jugador
	spr(playerShip.sprite,
		playerShip.position.x,
		playerShip.position.y,0 -- El Cero es para que sea transparente
		)

end -- end drawPlayerShip

function checkLimits(valor,minimo,maximo)

	if ( valor > maximo ) then
		valor = maximo
	elseif ( valor < minimo ) then
		valor = minimo
	else 
		valor = valor
	end

	return valor

end --end checkLimits

function initialiseGame()
	initPlayerBullets()
	initAliens()
	alienVSpeed = 8
	alienmissiles = {}
	playerScore = 0
	playerLives = 3
	gameInitialised = true
end

function initAliens()
	--crear la columna de los aliens	
	for row = 1,alienRows do
		aliens[row] = {}
		-- crear una fila de aliens
		for column = 1,alienColumns do
			aliens[row][column] = {}
			-- crear el alien
			aliens[row][column] = {
				position = {
					x = ( column - 1) * alienHSpacing,
					y = ( row - 1 ) * alienVSpacing + alienVOffset
				},
				alive = true,
				sprite = alienRowTypes[row].baseSprite,
				color = 0,
				altura	= 8,
				anchura	= 8,
				value	= 5
			}
		end	-- end fila
	end -- end columna
end

function drawAliens()
	-- Por cada fila de aliens
	for row = 1,alienRows do
		-- Por cada columna de alies
		for column = 1,alienColumns do
			-- Si el alien esta vivo entonces lo dibujamos en pantalla
			if ( aliens[row][column].alive ) then
				spr(aliens[row][column].sprite + alienMovFrameCounter,
					aliens[row][column].position.x,
					aliens[row][column].position.y,
					aliens[row][column].color)
				
				-- Que el alien dispare
				if (math.random(50) == 1 ) then
					spawnAlienMissile(aliens[row][column].position)
				end
			end -- if alien.alive		
		end -- for column
	end -- for row
end -- drawAliens

function moveAliens()
	calcAlienSpeed()
	-- Hacer que el contador baje 1 por cada fotograma
	alienCounter = alienCounter - 1
	-- Si el contador es igual a 0 que el alien pueda moverse
	if ( alienCounter <= 0 ) then
		
		

		alienMovFrameCounter = alienMovFrameCounter + 1
		alienMovFrameCounter = alienMovFrameCounter % alienMovNumFrames
		-- Cambiar pitch cada paso del aliens
		alienStepSoundCounter = alienStepSoundCounter + 1
		alienStepSoundCounter = alienStepSoundCounter % alienStepSoundNote

		-- Reproducir "step" sound
		sfx(0,alienStepSoundBaseNote - alienStepSoundCounter,10,0,8)
		-- Cada vez que alienMovFrameCounter llegue a su numMax, vuelve a 0
		
		if ( aliensAtEdge() ) then
			-- mover los aliens 1 "tile" abajo
			for row = 1,alienRows do
				-- Por cada columna de alies
				for column = 1,alienColumns do
					if ( aliens[row][column].alive ) then
						aliens[row][column].position.y = 
							aliens[row][column].position.y + 
							(alienVSpeed)
						if ( aliens[row][column].position.y > scn_size_y ) then
							gameState = stateGameOver
						end
					end
				end -- for column
			end -- for row

			alienDirection = -alienDirection
		else
			for row = 1,alienRows do
				-- Por cada columna de alies
				for column = 1,alienColumns do
					-- Mover aliens derecha/izquierda dependiendo su direccion
					if ( aliens[row][column].alive ) then 
						aliens[row][column].position.x = 
							aliens[row][column].position.x + 
							(alienSpeed * alienDirection)
						--aliensAlive = aliensAlive + 1
					end
				end -- for column
			end -- for row
		end -- if aliensAtEdge
		alienCounter = alienDelay

		if ( alienNumbers == 48 ) then
			timer = 0
			gameState = stateAllAliensDead
		end
	end -- if alienCounter
end -- moveAliens

function calcAlienSpeed()
	if ( alienNumbers == 0 ) then
		alienDelay = 30
	elseif ( alienNumbers == 15 ) then
		alienDelay = 20
	elseif ( alienNumbers == 30 ) then
		alienDelay = 10
	elseif ( alienNumbers == 40 ) then
		alienDelay 	= 3
		alienVSpeed = 12
	end
end

function aliensAtEdge()
	-- Por cada alien
	for row = 1,alienRows do
		for column = 1, alienColumns do
			-- Si el alien esta vivo
			if ( aliens[row][column].alive ) then
				-- Si el alien va a la derecha + 1
				if ( alienDirection == 1 ) then
					-- Si el alien + paso > tamaño de la pantalla entonces
					if ( aliens[row][column].position.x + alienSpeed > ( scn_size_x - 8 ) ) then
						return true
					end -- end if
				-- O, si el alien va a la izquierda
				else
					-- Si el alien - paso < tamaño minimo de pantalla entonces
					if ( aliens[row][column].position.x - alienSpeed < 0 ) then
						return true
					end
				end --end elseif position.x + 1
			end -- end if alien.alive
		end -- end for
	end -- end for

	return false 
end -- aliensAtEdge

function checkCollision( objeto1,objeto2 )

	local objeto1Left 	= objeto1.position.x
	local objeto1Right 	= objeto1.position.x + objeto1.anchura 	- 1
	local objeto1Top	= objeto1.position.y
	local objeto1Bottom	= objeto1.position.y + objeto1.altura 	- 1
	
	local objeto2Left 	= objeto2.position.x
	local objeto2Right 	= objeto2.position.x + objeto2.anchura	- 1
	local objeto2Top	= objeto2.position.y
	local objeto2Bottom	= objeto2.position.y + objeto2.altura 	- 1
	
	if 	(objeto1Left 	< objeto2Right	) 	and
		(objeto1Right 	> objeto2Left	) 	and
		(objeto1Bottom 	> objeto2Top	)	and
		(objeto1Top 	< objeto2Bottom)	then
		return true
	else
		return false
	end -- if obj1 = obj2
end -- checkCollision()

function checkBulletCollision()

	local bulletHasHitAlien = false
	--Checamos cada bala
	for bullet = 1, maxPlayerBullets do
		-- Si la bala esta activa entonces...
		if (playerBullets[bullet].active) then
			-- Checamos todos los aliens
			for row = 1,alienRows do
				for column = 1,alienColumns do
					-- Si el alien esta vivo entonces verificamos si la bala ha colisionado
					if ( aliens[row][column].alive ) then
						bulletHasHitAlien = checkCollision( playerBullets[bullet], aliens[row][column] )
						-- Si la bala le dio al alien
						if ( bulletHasHitAlien ) then
							--hit
							sfx(2,10,40,3)
							alienNumbers = alienNumbers + 1
							playerScore = playerScore + aliens[row][column].value
							aliens[row][column].alive 		= false
							playerBullets[bullet].active	= false
							alienExplosion( aliens[row][column].position )
						end
					end -- end alien.alive
				end	-- end fila
			end -- for alienRows
		end -- if playerBullets.active
	end -- end for
end -- checkBulletcollision

function alienExplosion( explosionPosition )

	local explosion = {
		ticCounter	= 0,
		ticDelay 	= 30,
		position 	= { x=explosionPosition.x, y=explosionPosition.y },
		color		= 0,
		baseSprite	= 64,
		animFrames	= 4,
		animDelay	= 10,
		animCounter	= 0
		}
	table.insert( explosions, explosion )
end

function drawExplosions()
	-- Por cada explosion en la tabla explosiones
	-- Dibujamos una explosion
	for index, explosion in pairs(explosions) do
		-- Ejecutamos la funcion para animar la explosion
		explosion.animCounter = explosion.animCounter + 1
		explosion.animCounter = explosion.animCounter %  explosion.animFrames

		--print(explosion.ticCounter,0,0)
		spr( explosion.baseSprite + explosion.animCounter, explosion.position.x, explosion.position.y, explosion.color )
		-- Empezamos el contador para que desaparezca la explosion
		explosion.ticCounter = explosion.ticCounter + 1
		if ( explosion.ticCounter > explosion.ticDelay ) then
			table.remove(explosions,index)
			explosion.ticCounter = 0
		end
	end
end -- function

-- Funcion para manejar el Score Board
function drawScoreBoard()
	print("Score: "..playerScore,0,0)
	--print("Lives: "..playerLives,120,0)
	for i = 1, playerLives do
		spr(2,190 + ( i*12 ),-2,0)
	end
end -- drawScoreBoard

function spawnAlienMissile(alienPosition)
	-- si la cantidad de misiles en alienmissiles no pasa el maximo de misiles
	-- que se cree un nuevo misil
	if ( #alienmissiles < maxAlienMissiles ) then
		local missile = {
			position 	= {x=alienPosition.x+4, y=alienPosition.y+8},
			altura		= 5,
			anchura		= 1,
			colour		= 6,
			speed		= 1
		}

		table.insert(alienmissiles, missile) -- insertamos un missile a la tabla alienmissiles
	end -- if #alienmissiles
end -- spawnAlienMissile

function drawAlienMissile()
	-- por cada misil en "alienmissiles"
	-- dibujamos una linea debajo del alien
	for index, missl in ipairs(alienmissiles) do
		line(
			missl.position.x,
			missl.position.y,
			missl.position.x,
			missl.position.y + missl.altura,
			missl.colour
		)
	end
end -- drawAlienMissile

function moveAlienMissiles()
	-- Movemos cada uno de los misiles
	for index, missl in ipairs(alienmissiles) do
		missl.position.y = missl.position.y + missl.speed
		-- Si la bala del alien pasa la pantalla baja
		-- que se elimine y otra bala pueda ser disaparada
		if ( missl.position.y >= scn_size_y ) then
			table.remove( alienmissiles, index )
		end
	end
end -- moveAlienMissiles

function checkMissileCollision()
	-- checamos colision de cada misil del alien
	for index, missl in ipairs(alienmissiles) do
		-- si colisiona con el jugador entonces
		-- que inicialice una explosion
		if ( checkCollision(missl,playerShip)) then
			local explosion = {
				ticCounter	= 0,
				ticDelay 	= 60,
				position 	= playerShip.position,
				color		= 0,
				baseSprite	= 64,
				animFrames	= 4,
				animDelay	= 10,
				animCounter	= 0
				}
			-- que la explosion se ingrese en la tabla explosiones
			table.insert( explosions, explosion )
			-- que la bala que le dio al jugador desaparezca
			table.remove( alienmissiles,index )

			jumpToNewLifeState()

			sfx(2,10,100,3)
		end
	end
end

function jumpToNewLifeState()
	gameState = stateNewLife
	timer = 0
	playerLives = playerLives - 1
end