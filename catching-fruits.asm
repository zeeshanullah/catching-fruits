TITLE MASM Template    					(main.asm)

include irvine32.inc

.data
basket byte "|___|",0
EmptyBasket byte "     ", 0
BasketX byte 20
BasketY byte 23

Character byte "O",0
EmptyCharacter byte " ",0
CharacterX byte ?
CharacterY byte 1 


leftBoundry equ 2
rightBoundry equ 40
lowerBoundry equ 24
HorizontalBoundrychar byte "-",0
VerticalBoundrychar byte "|",0

scoreMsgString BYTE "Score:",0
score BYTE 0
levelMsgString BYTE "Level:",0
level BYTE 1
lifemsgString BYTE "Lives remaining:",0
life BYTE 3

gameOverString BYTE "                 GAME OVER",0
newGameString BYTE "Do you want to play again?",0
yourScoreString BYTE "Your Score:",0

gameTitle BYTE "Catching Balls",0
askForInstruction BYTE "Do you want to read Instructions?",0
instructionString BYTE "INSTRUCTIONS:							"
				  BYTE "1)  Press A or S to move the basket left or right, respectively."
				  BYTE "			2)  After every 10 score, you will be moved to next level."
				  BYTE "			3)  You can play now. GOOD LUCK!",0


pauseString BYTE "GAME PAUSED",0
clearPauseString BYTE "           ",0

background BYTE	" "
backgroundColor DWORD (lightgray*16)+red
frontColorMask BYTE 0Fh

char BYTE "/",0



.code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   BASKET  HANDLING   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayBasket proc                      ; DISPLAY BASKET
	mov dh,basketY
	mov dl,basketX
	call gotoxy
	mov edx, offset basket
	call writeString
	ret
DisplayBAsket endp



pauseGame PROC uses edx
	mov dl, 16
	mov dh, 10
	call gotoxy
	mov edx, offset pauseString
	call writeString
notP:
	call readchar
	cmp al, 'p'
	jne notP
	mov dl, 16
	mov dh, 10
	call gotoxy
	mov edx, offset clearPauseString
	call writeString
	ret
pauseGame ENDP



TakeInputFromKeyBoard proc               ; INPUT FROM KEY BOARD
	;mov eax,150
	call delay
	call ReadKey
	cmp al,'a'
	je Backward
	cmp al,'s'
	je Forward
	cmp al,'p'
	je Paused
	jmp quit
Backward:
	call moveBasketBackward
	jmp quit
Forward:
	call moveBasketForward
	jmp quit
Paused:
	call pauseGame
quit:
	ret
TakeInputFromKeyBoard endp



RemoveBasket proc                    ; REMOVE OLD BASKET POSITION
	mov dh,basketY
	mov dl,basketX
	call gotoxy

	mov edx, offset Emptybasket
	call writeString
	ret
RemoveBasket endp


MoveBasketForward proc                ; MOVE BASKET RIGHT
	call removeBasket
	cmp BasketX, 34
	jae stay
	add BasketX, 1
stay:
	call DisplayBasket
	ret
MoveBasketForward endp

MoveBasketBackward proc              ; MOVE BASKET LEFT
	call removeBasket
	cmp BasketX, leftboundry
	jbe stay1
	sub BasketX, 1
stay1:
	call DisplayBasket
	ret
MoveBasketBackward endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     CHARACTER  HANDLING    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


DisplayCharacter proc                  ;  DISPLAY CHARACTER (FALLING OBJECTS)
	mov dh,CharacterY
	mov dl,CharacterX
	call gotoxy
	mov edx, offset Character
	call writeString
	ret
DisplayCharacter endp



MoveCharacterOneStepDown PROC           ;  MOVE OBJECT ONE STEP DOWN
	call RemoveCharacter
	mov al, characterY
	cmp al, 23
	je generateNewCharacter
	inc CharacterY
	mov dl, characterY
	mov dh, characterX

	;je generateNewCharacter
	;inc CharacterY

	call DisplayCharacter
	jmp endz

	generateNewCharacter:
		call collisionDetection
		call CreateCharacter
	endz:
	ret
MoveCharacterOneStepDown ENDP


collisionDetection PROC

	NextCondition:
		mov ecx, 5
		mov al, characterX
		mov bl, basketX
		L3:
		cmp al, BasketX
		je scoreInc
		inc basketX
		loop L3
		dec life
		jmp atEnd

	scoreInc:
		inc score
		mov ecx, 0

	atEnd:
		mov basketX, bl
		call checkLife
		call displayBasket

	ret
collisionDetection ENDP




CreateCharacter proc							;  CREATE OBJECT
	call generateRandom
	mov dl, al
	mov characterX, dl
	mov dh, 1
	mov CharacterY, dh
	call gotoxy
	mov edx, offset Character
	call writestring
	ret
CreateCharacter endp


generateRandom PROC                             ;  RANDOM NUMBER GENERATOR
begin:
	mov eax, 37
	call Randomize
	call Randomrange
	cmp al, 0
	je begin
	cmp al, 1
	je begin
	cmp al, 2
	je begin
	ret
generateRandom endp


RemoveCharacter proc							 ;  REMOVE OBJECT'S PREVIOUS LOCATION
	mov dh,CharacterY
	mov dl,CharacterX
	call gotoxy
	mov edx, offset EmptyCharacter
	call writeString
	ret
RemoveCharacter endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     SET  BOUNDRY     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayBoundry PROC                    ;   DISPLAY  BOUNDRY
	mov ecx, 25
	mov dl,0
	mov dh,0
	firstcolumn:
		call gotoxy
		pushad
		mov edx, offset VerticalBoundrychar
		call writestring
		popad
		inc dh
	loop firstcolumn

	mov ecx, 25
	mov dl, rightboundry
	inc dl
	mov dh, 0
	secondcolumn:
		call gotoxy
		pushad
		mov edx, offset VerticalBoundrychar
		call writestring
		popad
		inc dh
	loop secondcolumn

	mov ecx, 40
	mov dl, 1
	mov dh, 0
	upperRow:
		call gotoxy
		pushad
		mov edx, offset HorizontalBoundrychar
		call writestring
		popad
		inc dl
	loop upperRow
	ret
DisplayBoundry ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     SCORE DISPLAY    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scoreMsg Proc
	mov dl, 53
	mov dh, 3
	call gotoxy
	mov edx, offset scoreMsgString
	call writestring
	ret
scoreMsg ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    LEVEL HANDLING     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

levelMsg Proc							; DISLAY LEVEL STRING
	mov dl, 53
	mov dh, 10
	call gotoxy
	mov edx, offset levelMsgString
	call writestring
	ret
levelMsg ENDP



checkLevel Proc	
	mov al, score					    ;  LEVEL CHECKER
	cmp al, 20
	jae level3
	mov al, score
	cmp al, 10
	jae level2
	jmp return
	level2:
		mov eax, 100
		mov level, 2
		jmp return1
	level3:
		mov eax, 50
		mov level, 3
		jmp return1
	return:
		mov eax, 150
	return1:
	ret	
checkLevel ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     SET BACK-GROUND COLOR    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

setBackground PROc
pushad
	mov eax, backgroundColor
	call SetTextColor
	mov dh, 0
	mov dl, 0
	mov bx, dx
	mov eax, 80
	mov ecx, eax
L0:	
	mov eax, ecx
	mov ecx, 25
L1:
	mov dx, bx	
	call Gotoxy
	mov edx, offset background
	call WriteString
	inc bh
	loop L1
	mov bh, 0
	inc bl
	mov ecx, eax
	loop L0
	popad
	ret
setBackground ENDP



printScoreAndLevel PROC uses eax
	mov dl, 61
	mov dh, 3
	call gotoxy
	mov al, score
	call writeDec

	mov dl, 61
	mov dh, 10
	call gotoxy
	mov al, level
	call writeDec
	call lifeDisplay

	ret
printscoreAndLevel ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  LIFE HANDLING  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lifeMsg PROC
	mov dh, 17
	mov dl, 48
	call gotoxy
	mov edx, offset lifeMsgString
	call writestring
	ret
lifeMsg ENDP



lifeDisplay PROC
	mov dh, 17
	mov dl, 65
	call gotoxy
	mov eax, 0
	mov al, life
	call writeDec
	ret
lifeDisplay ENDP



checkLife PROC
	mov eax, 0
	mov al, life
	cmp al, 0
	jne gameNotEnd
	jmp endGame

	gameNotEnd:
	ret
checkLife ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   GAME STARTING ENDING BOX HANDLING   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gameOver PROC									 ;END GAME BOX
endGame::
	call clrscr
	mov dh, 10
	mov dl, 25
	call gotoxy
	mov edx, offset yourScoreString
	call writestring
	mov dl, 38
	mov al, score
	call writedec

	mov ebx, offset gameOverString
	mov edx, offset newGameString
	call msgboxask
	cmp al, 6
	je start
	jmp quitTheGame
	ret
gameOver ENDP



gameStart PROC									;GAME START BOX
	mov ebx, offset GameTitle
	mov edx, offset askForInstruction
	call msgboxask
	cmp al, 6
	jne START
	mov edx, offset instructionString
	call msgbox
	ret
gameStart ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      MAIN FUNCTION        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main PROC

call gameStart

START::
	mov score, 0
	mov level, 1
	mov life, 3
	call setBackground
	call scoreMsg
	call levelMsg
	call lifeMsg
	call DisplayBoundry
	call DisplayBasket
	call CreateCharacter
	mov eax,150
	
StartGame:
	call TakeInputFromKeyBoard
	call MoveCharacterOneStepDown
	call checkLevel
	call printscoreAndLevel
	jmp StartGame

quitTheGame::

	invoke ExitProcess,0

	exit
main ENDP

END main
