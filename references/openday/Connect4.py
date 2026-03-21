
# import the opencv library
import cv2
import numpy as np
import random, copy,time
import matlab.engine
print("LOADING MATLAB ENGINE")
eng = matlab.engine.start_matlab()
print("LOADED MATLAB ENGINE")




BOARDWIDTH = 7
BOARDHEIGHT = 5 
DIFFICULTY = 2
RED = 'red'
BLUE = 'blue'
EMPTY = None
HUMAN = 'human'
COMPUTER = 'computer'

totalBlueCount = 0

print(random.randint(0,1))
if (random.randint(0,1) == 1):
    turn = HUMAN
else:
    turn = COMPUTER



DEBUG = True



def makeMove(board, player, column):
    lowest = getLowestEmptySpace(board, column)
    if lowest != -1:
        board[column][lowest] = player

def getNewBoard():
    board = []
    for x in range(BOARDWIDTH):
        board.append([EMPTY] * BOARDHEIGHT)
    return board

def getComputerMove(board):
    potentialMoves = getPotentialMoves(board, BLUE, DIFFICULTY)
    # get the best fitness from the potential moves
    bestMoveFitness = -1
    for i in range(BOARDWIDTH):
        if potentialMoves[i] > bestMoveFitness and isValidMove(board, i):
            bestMoveFitness = potentialMoves[i]
    # find all potential moves that have this best fitness
    bestMoves = []
    for i in range(len(potentialMoves)):
        if potentialMoves[i] == bestMoveFitness and isValidMove(board, i):
            bestMoves.append(i)
    return random.choice(bestMoves)


def getPotentialMoves(board, tile, lookAhead):
    if lookAhead == 0 or isBoardFull(board):
        return [0] * BOARDWIDTH

    if tile == RED:
        enemyTile = BLUE
    else:
        enemyTile = RED

    # Figure out the best move to make.
    potentialMoves = [0] * BOARDWIDTH
    for firstMove in range(BOARDWIDTH):
        dupeBoard = copy.deepcopy(board)
        if not isValidMove(dupeBoard, firstMove):
            continue
        makeMove(dupeBoard, tile, firstMove)
        if isWinner(dupeBoard, tile):
            # a winning move automatically gets a perfect fitness
            potentialMoves[firstMove] = 1
            break # don't bother calculating other moves
        else:
            # do other player's counter moves and determine best one
            if isBoardFull(dupeBoard):
                potentialMoves[firstMove] = 0
            else:
                for counterMove in range(BOARDWIDTH):
                    dupeBoard2 = copy.deepcopy(dupeBoard)
                    if not isValidMove(dupeBoard2, counterMove):
                        continue
                    makeMove(dupeBoard2, enemyTile, counterMove)
                    if isWinner(dupeBoard2, enemyTile):
                        # a losing move automatically gets the worst fitness
                        potentialMoves[firstMove] = -1
                        break
                    else:
                        # do the recursive call to getPotentialMoves()
                        results = getPotentialMoves(dupeBoard2, tile, lookAhead - 1)
                        potentialMoves[firstMove] += (sum(results) / BOARDWIDTH) / BOARDWIDTH
    return potentialMoves


def getLowestEmptySpace(board, column):
    # Return the row number of the lowest empty row in the given column.
    for y in range(BOARDHEIGHT-1, -1, -1):
        if board[column][y] == EMPTY:
            return y
    return -1


def isValidMove(board, column):
    # Returns True if there is an empty space in the given column.
    # Otherwise returns False.
    if column < 0 or column >= (BOARDWIDTH) or board[column][0] != EMPTY:
        return False
    return True


def isBoardFull(board):
    # Returns True if there are no empty spaces anywhere on the board.
    for x in range(BOARDWIDTH):
        for y in range(BOARDHEIGHT):
            if board[x][y] == EMPTY:
                return False
    return True


def isWinner(board, tile):
    # check horizontal spaces
    for x in range(BOARDWIDTH - 3):
        for y in range(BOARDHEIGHT):
            if board[x][y] == tile and board[x+1][y] == tile and board[x+2][y] == tile and board[x+3][y] == tile:
                return True
    # check vertical spaces
    for x in range(BOARDWIDTH):
        for y in range(BOARDHEIGHT - 3):
            if board[x][y] == tile and board[x][y+1] == tile and board[x][y+2] == tile and board[x][y+3] == tile:
                return True
    # check / diagonal spaces
    for x in range(BOARDWIDTH - 3):
        for y in range(3, BOARDHEIGHT):
            if board[x][y] == tile and board[x+1][y-1] == tile and board[x+2][y-2] == tile and board[x+3][y-3] == tile:
                return True
    # check \ diagonal spaces
    for x in range(BOARDWIDTH - 3):
        for y in range(BOARDHEIGHT - 3):
            if board[x][y] == tile and board[x+1][y+1] == tile and board[x+2][y+2] == tile and board[x+3][y+3] == tile:
                return True
    return False


def displayBoard(b):
    print(f"|0|1|2|3|4|5|6|")

    for i in range (0,BOARDHEIGHT):
        string  = "|"
        for j in range (0,BOARDWIDTH):
            if (b[j][i] == None):
                string = string + " "
            else:
                if (b[j][i] == 'blue'):
                    string = string + 'h'
                else:
                    string = string + 'c'
            string = string + "|"
        print(string)

    print(f" --------------")



mainBoard = getNewBoard()

vid = cv2.VideoCapture(0)

lower_white = np.array([150,150,150])
upper_white = np.array([255,255,255])

lower_blue = np.array([50,0,0])
upper_blue = np.array([255,50,50])

lower_red = np.array([0,0,50])
upper_red = np.array([50,50,255])

lower_yellow = np.array([0, 70, 0])
upper_yellow = np.array([60, 255, 255])

totalBlueCount = 0

while(True):
    print(turn)
    mainBoard = getNewBoard()

    time.sleep(0.5)
    ret, frame = vid.read()
    cv2.imshow('video',frame)
    
    mask_colour = cv2.inRange(frame, lower_yellow, upper_yellow)
    
    kernel = np.ones((3, 3), np.uint8)
    mask_erosion = cv2.erode(mask_colour, kernel, iterations=3)
    mask_dilation = cv2.dilate(mask_erosion, kernel, iterations=7)

    if DEBUG:
        cv2.imshow('Yellow Mask raw',mask_colour)
        cv2.imshow('Yellow Mask eroded',mask_erosion)
        cv2.imshow('Yellow Mask dilalated',mask_dilation)


    height = mask_dilation.shape[0]
    width = mask_dilation.shape[1]
    heightInterval = int(height/5)
    widthInterval = int(width/7)

    topLeftImg = mask_dilation[0:int(height/2),0:int(width/2)]
    topRightImg = mask_dilation[0:int(height/2),int(width/2):width]
    botLeftImg = mask_dilation[int(height/2):height,0:int(width/2)]
    botRightImg = mask_dilation[int(height/2):height,int(width/2):width]
    
    topLeftPoint = [0,0]
    topRightPoint = [0,0]
    botLeftPoint = [0,0]
    botRightPoint = [0,0]

    foundAllPoints = False
    
    try:
        ret,thresh = cv2.threshold(topLeftImg,127,255,0)
        M = cv2.moments(thresh)
        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])
        topLeftPoint = [cX,cY]

        ret,thresh = cv2.threshold(topRightImg,127,255,0)
        M = cv2.moments(thresh)
        cX = int(M["m10"] / M["m00"] + width/2)
        cY = int(M["m01"] / M["m00"])
        topRightPoint = [cX,cY]

        ret,thresh = cv2.threshold(botLeftImg,127,255,0)
        M = cv2.moments(thresh)
        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"] + height/2)
        botLeftPoint = [cX,cY]

        ret,thresh = cv2.threshold(botRightImg,127,255,0)
        M = cv2.moments(thresh)
        cX = int(M["m10"] / M["m00"] + width/2)
        cY = int(M["m01"] / M["m00"] + height/2)
        botRightPoint = [cX,cY]

        foundAllPoints = True
    except:
        print("top left can't be seen")

    if(foundAllPoints):
        #print("found all points")

        pts2 = np.float32([[100, 100], [400, 100], [100, 400], [400, 400]])
        pts3 = np.float32([topLeftPoint,topRightPoint,botLeftPoint, botRightPoint])

            # Apply Perspective Transform Algorithm
        matrix = cv2.getPerspectiveTransform(pts3, pts2)

        result = cv2.warpPerspective(frame, matrix, (500, 600))
        result = result[10:500, 40:460]

        height = result.shape[0]
        width = result.shape[1]
        heightInterval = int(height/5)
        widthInterval = int(width/7)

        currentBlueCount = 0

        if DEBUG:
            cv2.imshow('Transformed and Zoomed',result)

            img_example = result.copy()
            for i in range(0,8):
                img_example = cv2.line(img_example, (widthInterval*i,0),  (widthInterval*i,height), (0,255,0), 3)
            for i in range (0,6):
                img_example = cv2.line(img_example, (0,heightInterval*i),  (width,heightInterval*i), (0,255,0), 3)

            cv2.imshow('Divisioned Grid', img_example)
                    

        for i in range(0,5):
            for j in range(0,7):
                img = result[heightInterval*(4-i):heightInterval*((4-i)+1),widthInterval*j:widthInterval*(j+1)]

                blueMask = cv2.inRange(img, lower_blue, upper_blue)
                redMask = cv2.inRange(img, lower_red, upper_red)

                if(np.mean(blueMask) > 45):
                    makeMove(mainBoard, BLUE, int(j))
                    currentBlueCount = currentBlueCount + 1

                if(np.mean(redMask) > 45):
                    makeMove(mainBoard, RED, int(j))

                #cv2.imshow('closeup', img)
                #cv2.waitKey(0)
        print("board")
        displayBoard(mainBoard)

        if isWinner(mainBoard,BLUE):
            print("human wins")
            break

        if isWinner(mainBoard, RED):
            print("computer wins")
            break

        if isBoardFull(mainBoard):
            print("tie")
            break
    

        if (currentBlueCount > totalBlueCount):
            totalBlueCount = currentBlueCount
            #print("computer turn")
            turn = COMPUTER

    
        if (turn == COMPUTER):
            column = getComputerMove(mainBoard)


            #print("column the robot is wishing to move from the left")
            #print(column)
            #print("colum the robot is moving to from the right")


            output = eng.moveRobot(7-column,nargout=0)
            makeMove(mainBoard, RED, column)
            turn = HUMAN


    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
  

vid.release()
cv2.destroyAllWindows()
