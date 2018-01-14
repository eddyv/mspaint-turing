%Author: Edward Vaisman
%File Name: Paint.t
%Project Name: Games
%Creation Date: March 1, 2013
%Modified Date: March 22, 2013
%Description: The purpose of this program is to demonstrate what i have learned
%from Turing by creating a simple version of microsoft paint
%%%%%%%%%%%%%%%%%%WHAT ADVANCED STUFF I HAVE LEARNED FORM THIS PROJECT%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
- Records
- Flexible Arrays
- Stacks/Queues
- Mouse Interaction
- GUI STUFF(getting a colour from a mouseclick)
*/ 


View.Set ("graphics:max;max")
%Needed to remove flickering when redrawing the screen
View.Set ("offscreenonly")
%isGameDone remains false for the entire life of the program until the user is ready to quit
var isGameDone : boolean := false

%%this will track the users X,Y mouse position
var mouseX : int
var mouseY : int
var lastMouseX : int
var lastMouseY : int
var numBoxs : int := 1
var numCircles : int := 1
var numSemiCircles : int := 1
%%user input
var key : string (1)

%%this will determine weither or not to draw a box
var isBoxBeingDrawn : boolean := false
var isCircleBeingDrawn : boolean := false
var isSemiCircleBeingDrawn : boolean := false
var isStarBeingDrawn : boolean := false
var isLineBeingDrawn : boolean := false
var isTextBoxBeingDrawn : boolean := false
var isDrawing : boolean := false
var setUpHud : boolean := false
var actionChoice : int := 0
%% users color choice
var colorChoice : int := 255

%%this will determine which button is pressed
var mouseMode : int := 0
var lastMouseMode : int := 0
var mouseUpDown : int
var lastMouseUpDown : int

%%this will be the records that hold the values stored in a rectangle
type rectangle :
    record
	x1 : int
	y1 : int
	x2 : int
	y2 : int
	colorNum : int
	fillNum : int
    end record

%used for HUD
var colorBoxs : array 1 .. 256 of rectangle
var hudBackRound : array 1 .. 2 of rectangle
var actionBoxs : array 1 .. 6 of rectangle

%%this will be the records that hold the values stored in a circle
type circle :
    record
	x1 : int
	y1 : int
	xRadius : int
	yRadius : int
	colorNum : int
    end record


%%this will be the records that hold the values stored in a line
type line :
    record
	x1 : int
	y1 : int
	x2 : int
	y2 : int
	colorNum : int
    end record


%%this will be the records that hold the values stored in a semiCircle
type semiCircle :
    record
	x1 : int
	y1 : int
	xRadius : int
	yRadius : int
	colorNum : int
    end record

%%this will be the records that hold the values stored in a star
type star :
    record
	x1 : int
	y1 : int
	x2 : int
	y2 : int
	colorNum : int
    end record


type shape :
    record
	%if its value is 0 = rectangle, 1 = circle, 2 = semiCircle, 3 = star, 4 = lines
	shapeNum : int
	rectangle : rectangle
	circle : circle
	semiCircle : semiCircle
	star : star
	line : line
	%This is used for the undo feature of every shape.
	lastFillNum : array 1 .. 1000 of int
	numFillChanges : int
    end record


%this will hold all the shapes that the user has drawn. this is so we can draw the shapes in the correct order
var userShapes : flexible array 1 .. 0 of shape
%This variable is used to keep track when the user has changed a shape so it could then undo it in the proper order. ex if the user creates two shapes and then changes the colour of the first shape it should go in the order of
%Undo Fill on shape 1, Undo shape creation on shape 2, undo shape creation on shape 3 (think of it as numbers CREATE (1) CREATE (2) FILL (1) remove = (REMOVE FILL(1) REMOVE CREATE(2) REMOVE CREATE(1)
var undoStack : array 1 .. 1000 of int
var numUndoElements : int := 0

%Pre: none
%Post: will check if the user has clicked the mouse anywhere and if the user has it will draw a box that will 'drag' the box
%Description: will check if the user has clicked or not and if it has it will start drawing a box
procedure DrawBox ()
    %checks if the box has began drawing
    if (isBoxBeingDrawn = true) then
	%checks if the mouse is clicked and will draw a box folowing the initial click and the current mouse
	if (mouseMode = 1) then
	    %%Draws the box with a black outline as you are drawing
	    Draw.Box (lastMouseX, lastMouseY, mouseX, mouseY, 255)
	    %once the mouse click is realeased it will then finish drawing the last position and stop finding the second x,y fot the box
	else
	    if (mouseX not= lastMouseX| mouseY not= lastMouseY) then
		%%Draws the box with a black outline as you are drawing
		Draw.Box (lastMouseX, lastMouseY, mouseX, mouseY, 255)
		%%will stop drawing the box after this point so the user could do other things
		isBoxBeingDrawn := false
		isDrawing := false
		%used to be stored into a record of shapes
		var newRectangle : rectangle

		%increases size of the array
		new userShapes, upper (userShapes) + 1

		%properties of a rectangle to be given
		newRectangle.x1 := lastMouseX
		newRectangle.x2 := mouseX
		newRectangle.y1 := lastMouseY
		newRectangle.y2 := mouseY
		newRectangle.colorNum := colorChoice
		%userRectangles (upper (userRectangles)) := newRectangle
		userShapes (upper (userShapes)).shapeNum := 0
		userShapes (upper (userShapes)).rectangle := newRectangle
		%upon creation it will give a default value to all elements indicating that it had no previous fill value (any value below 0 will be considered as if it's fill has not been changed)
		for i : 1 .. 1000
		    userShapes (upper (userShapes)).lastFillNum (i) := -1
		end for
		%this will set default values such as it has never changed its fill colour before
		userShapes (upper (userShapes)).numFillChanges := 0
		%increases this value and adds it to the stack where it could be removed if desired
		numUndoElements := numUndoElements + 1
		undoStack (numUndoElements) := upper (userShapes)

	    end if
	end if
    else
	%checks if the mouse has been clicked and then sets the values to prepare for the drawing of the box
	if (mouseMode = 1) then
	    lastMouseX := mouseX
	    lastMouseY := mouseY
	    lastMouseMode := mouseMode
	    isBoxBeingDrawn := true
	    isDrawing := true
	end if
    end if
end DrawBox
%Pre: gets the possition of the mouse and the color chosen
%Post: Gets the initial click from the user starting at the center and gets the end of it
%Description: Will create a circle starting at the midpoint and expanding based on the radius given
procedure DrawCircle ()
    %checks if a circle has began drawing
    if (isCircleBeingDrawn = true) then
	%constantly checks for a new radius of the circle
	var xRadius := (mouseX - lastMouseX)
	var yRadius := (mouseY - lastMouseY)
	%checks to see if the mouse is clicked and will draw a circle at the centre
	if (mouseMode = 1) then
	    %draws the circle while the mouse is clicked
	    Draw.Oval (lastMouseX, lastMouseY, xRadius, yRadius, 255)
	else
	    %%THE BELOW BEHAVES THE EXACT SAME AS A RECTANGLE. REFER TO RECTANGLE COMMENTS, ONLY DIFFERENCE IS THE X2,Y2 IS DETERMINED BY THE RADIUS NOT X2,Y2
	    if (mouseX not= lastMouseX| mouseY not= lastMouseY) then
		Draw.Oval (lastMouseX, lastMouseY, xRadius, yRadius, 255)
		isCircleBeingDrawn := false
		isDrawing := false
		%stores it into the dynamic array
		var newCircle : circle

		new userShapes, upper (userShapes) + 1

		newCircle.x1 := lastMouseX
		newCircle.y1 := lastMouseY
		newCircle.xRadius := xRadius
		newCircle.yRadius := yRadius
		newCircle.colorNum := colorChoice
		%userCircles (upper (userCircles)) := newCircle
		userShapes (upper (userShapes)).shapeNum := 1
		userShapes (upper (userShapes)).circle := newCircle
		for i : 1 .. 1000
		    userShapes (upper (userShapes)).lastFillNum (i) := -1
		end for
		userShapes (upper (userShapes)).numFillChanges := 0
		numUndoElements := numUndoElements + 1
		undoStack (numUndoElements) := upper (userShapes)


	    end if
	end if
    else
	%checks to see if the mouse has been clicked and then sets the values to prepare for the drawing of the circle
	if (mouseMode = 1) then
	    lastMouseX := mouseX
	    lastMouseY := mouseY
	    lastMouseMode := mouseMode
	    isCircleBeingDrawn := true
	    isDrawing := true
	end if
    end if
end DrawCircle
%Pre: none
%Post: Gets the initial click from the user starting at the center and gets the end of it but only draws half of the circle
%Description: Behaves much like a circle except on draws half of the circle
procedure DrawSemiCircle ()
    var xRadius := (mouseX - lastMouseX)
    var yRadius := (mouseY - lastMouseY)
    if (isSemiCircleBeingDrawn = true) then
	%checks to see if the mouse is clicked and will draw a semi circle starting at the centre
	if (mouseMode = 1) then
	    Draw.Arc (lastMouseX, lastMouseY, xRadius, yRadius, 0, 180, 255)
	else
	    if (mouseX not= lastMouseX| mouseY not= lastMouseY) then
		%%THE BELOW BEHAVES THE EXACT SAME AS A CIRCLE. REFER TO RECTANGLE COMMENTS, ONLY DIFFERENCE IS THE X2,Y2 IS DETERMINED BY THE RADIUS NOT X2,Y2 AND ONLY DRAWS HALF A CIRCLE.
		%%SEMICIRCLES AND LINES LINES TO NOT CHANGE COLOUR
		Draw.Arc (lastMouseX, lastMouseY, xRadius, yRadius, 0, 180, 255)
		isSemiCircleBeingDrawn := false
		isDrawing := false
		%stores it into the dynamic array
		var newSemiCircle : semiCircle
		%new userSemiCircles, upper (userSemiCircles) + 1
		var newShape : shape
		new userShapes, upper (userShapes) + 1
		newSemiCircle.x1 := lastMouseX
		newSemiCircle.y1 := lastMouseY
		newSemiCircle.xRadius := xRadius
		newSemiCircle.yRadius := yRadius
		newSemiCircle.colorNum := colorChoice
		%userSemiCircles (upper (userSemiCircles)) := newSemiCircle
		userShapes (upper (userShapes)).shapeNum := 2
		userShapes (upper (userShapes)).semiCircle := newSemiCircle
		userShapes (upper (userShapes)).numFillChanges := 0
		numUndoElements := numUndoElements + 1
		undoStack (numUndoElements) := upper (userShapes)

	    end if
	end if
    else
	%checks to see if the mouse has been clicked and then sets the values to prepare for the drawing of the circle
	if (mouseMode = 1) then
	    lastMouseX := mouseX
	    lastMouseY := mouseY
	    lastMouseMode := mouseMode
	    isSemiCircleBeingDrawn := true
	    isDrawing := true
	end if
    end if
end DrawSemiCircle
%Pre: None
%Post: Draws a star, saves its properties
%Description: Draws a star, saves its properties
procedure DrawStar ()
    %checks if the box has began drawing
    if (isStarBeingDrawn = true) then
	%checks if the mouse is clicked and will draw a box folowing the initial click and the current mouse
	if (mouseMode = 1) then
	    Draw.Star (lastMouseX, lastMouseY, mouseX, mouseY, 255)
	    %once the mouse click is realeased will then finish drawing the last position and stop finding the second x,y for the Star
	else
	    if (mouseX not= lastMouseX| mouseY not= lastMouseY) then
		Draw.Star (lastMouseX, lastMouseY, mouseX, mouseY, 255)
		isStarBeingDrawn := false
		isDrawing := false
		%stores it into the dynamic array
		var newStar : star
		%new userStars, upper (userStars) + 1
		var newShape : shape
		new userShapes, upper (userShapes) + 1
		newStar.x1 := lastMouseX
		newStar.x2 := mouseX
		newStar.y1 := lastMouseY
		newStar.y2 := mouseY
		newStar.colorNum := colorChoice
		%userStars (upper (userStars)) := newStar
		userShapes (upper (userShapes)).shapeNum := 3
		userShapes (upper (userShapes)).star := newStar
		for i : 1 .. 1000
		    userShapes (upper (userShapes)).lastFillNum (i) := -1
		end for
		userShapes (upper (userShapes)).numFillChanges := 0
		numUndoElements := numUndoElements + 1
		undoStack (numUndoElements) := upper (userShapes)

	    end if

	end if
    else
	%checks if the mouse has been clicked and then sets the values to prepare for the drawing of the Star
	if (mouseMode = 1) then
	    lastMouseX := mouseX
	    lastMouseY := mouseY
	    lastMouseMode := mouseMode
	    isStarBeingDrawn := true
	    isDrawing := true
	end if
    end if
end DrawStar
%Pre: None
%Post: Draws a line, saves its properties
%Description: Draws a line, saves its properties
procedure DrawLine ()
    %checks if the box has began drawing
    if (isLineBeingDrawn = true) then
	%checks if the mouse is clicked and will draw a box folowing the initial click and the current mouse
	if (mouseMode = 1) then
	    Draw.Line (lastMouseX, lastMouseY, mouseX, mouseY, 255)
	    %once the mouse click is realeasedwill then finish drawing the last position and stop finding the second x,y fot the box
	else
	    %%THE BELOW BEHAVES THE EXACT SAME AS A CIRCLE. REFER TO RECTANGLE COMMENTS
	    %%SEMICIRCLES AND LINES LINES TO NOT CHANGE COLOUR
	    Draw.Line (lastMouseX, lastMouseY, mouseX, mouseY, 255)
	    isLineBeingDrawn := false
	    isDrawing := false

	    % this is a temporary variable that will be used to store in the array of shapes later
	    var newLine : line
	    var newShape : shape
	    new userShapes, upper (userShapes) + 1

	    % properties of a line
	    newLine.x1 := lastMouseX
	    newLine.x2 := mouseX
	    newLine.y1 := lastMouseY
	    newLine.y2 := mouseY
	    newLine.colorNum := colorChoice

	    %stores it into the shapes array and sets the number to 4 to indicate that its a line
	    userShapes (upper (userShapes)).shapeNum := 4
	    userShapes (upper (userShapes)).line := newLine
	    userShapes (upper (userShapes)).numFillChanges := 0
	    numUndoElements := numUndoElements + 1
	    undoStack (numUndoElements) := upper (userShapes)

	end if
    else
	%checks if the mouse has been clicked and then sets the values to prepare for the drawing of the box
	if (mouseMode = 1) then
	    lastMouseX := mouseX
	    lastMouseY := mouseY
	    lastMouseMode := mouseMode
	    isLineBeingDrawn := true
	    isDrawing := true
	end if
    end if
end DrawLine

%Pre: None
%Post: Checks every shape to see if the mouse has been clicked in its area. from here it will change the shapes colour and will add it to the undo array
%Description: Changes a shapes colour
procedure FillBox ()

    %if mouse has been clicked then
    if (mouseMode = 1) then
	%loops through all shapes
	for decreasing i : upper (userShapes) .. 1
	    %if its a rectangle
	    if (userShapes (i).shapeNum = 0) then
		%checks if its in its area
		if (mouseX > userShapes (i).rectangle.x1 & mouseX < userShapes (i).rectangle.x2) then

		    if (mouseY > userShapes (i).rectangle.y1 & mouseY < userShapes (i).rectangle.y2) then
			%Starts at the beginning of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).rectangle.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%changes the shapes colour
			userShapes (i).rectangle.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit

		    elsif (mouseY > userShapes (i).rectangle.y2 & mouseY < userShapes (i).rectangle.y1) then
			%Starts at the beginning of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).rectangle.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%changes the shapes colour
			userShapes (i).rectangle.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    end if
		    %checks if its in its area
		elsif (mouseX < userShapes (i).rectangle.x1 & mouseX > userShapes (i).rectangle.x2) then

		    if (mouseY > userShapes (i).rectangle.y1 & mouseY < userShapes (i).rectangle.y2) then
			%Starts at the beginning of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).rectangle.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%changes the shapes colour
			userShapes (i).rectangle.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    elsif (mouseY > userShapes (i).rectangle.y2 & mouseY < userShapes (i).rectangle.y1) then
			%Starts at the beginning of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).rectangle.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%changes the shapes colour
			userShapes (i).rectangle.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    end if
		end if

	    elsif (userShapes (i).shapeNum = 1) then
		%checks if its in its area
		if (mouseX > userShapes (i).circle.x1 + userShapes (i).circle.xRadius & mouseX < userShapes (i).circle.x1 - userShapes (i).circle.xRadius) then
		    put mouseY;
		    put userShapes(i).circle.y1;
		    put (userShapes (i).circle.y1 + userShapes (i).circle.yRadius) ;
		    put (userShapes (i).circle.y1 - userShapes (i).circle.yRadius) ;
		    if (mouseY < userShapes (i).circle.y1 + userShapes (i).circle.yRadius & mouseY > userShapes (i).circle.y1 - userShapes (i).circle.yRadius) then
			%%Starts at the end of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).circle.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%changes the shapes colour
			userShapes (i).circle.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    end if
		    %checks if its in its area
		elsif (mouseX < userShapes (i).circle.x1 + userShapes (i).circle.xRadius & mouseX > userShapes (i).circle.x1 - userShapes (i).circle.xRadius) then

		    if (mouseY > userShapes (i).circle.y1 + userShapes (i).circle.yRadius & mouseY < userShapes (i).circle.y1 - userShapes (i).circle.yRadius) then
			%%Starts at the end of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).circle.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%changes the shapes colour
			userShapes (i).circle.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    end if
		end if
	    elsif (userShapes (i).shapeNum = 3) then
		%checks if its in its area
		if (mouseX > userShapes (i).star.x1 & mouseX < userShapes (i).star.x2) then

		    if (mouseY > userShapes (i).star.y1 & mouseY < userShapes (i).star.y2) then
			%%Starts at the end of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).star.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%%changes the shapes colour
			userShapes (i).star.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    elsif (mouseY > userShapes (i).star.y2 & mouseY < userShapes (i).star.y1) then
			%%Starts at the end of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).star.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%%changes the shapes colour
			userShapes (i).star.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    end if
		    %checks if its in its area
		elsif (mouseX < userShapes (i).star.x1 & mouseX > userShapes (i).star.x2) then

		    if (mouseY > userShapes (i).star.y1 & mouseY < userShapes (i).star.y2) then
			%%Starts at the end of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).star.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%%changes the shapes colour
			userShapes (i).star.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
			exit
		    elsif (mouseY > userShapes (i).star.y2 & mouseY < userShapes (i).star.y1) then
			%%Starts at the end of the array
			for k : 1 .. upper (userShapes (i).lastFillNum)
			    %finds an element that doesnt have a color value in it (0-255)
			    if (userShapes (i).lastFillNum (k) = -1) then
				%saves the last colour the shape had and increases the number of times it has changed colours
				userShapes (i).lastFillNum (k) := userShapes (i).star.colorNum
				userShapes (i).numFillChanges := userShapes (i).numFillChanges + 1
				exit
			    end if
			end for
			%%changes the shapes colour
			userShapes (i).star.colorNum := colorChoice
			numUndoElements := numUndoElements + 1
			undoStack (numUndoElements) := i
		    end if

		end if
	    end if
	end for
    end if
end FillBox
%Pre: none
%Post: will check if the user has clicked the mouse inside any of the boxs
%Description: will check if the user has clicked a box or not
procedure CheckMouseCollisions ()
    %Looks for the mouse position and sees if it is clicked
    Mouse.Where (mouseX, mouseY, mouseMode)
    %if it's clicked it by default checks if it has been clicked in a box that will allow the user to select a certain operation
    if (mouseMode = 1) then
	if (mouseX > 5 & mouseX < 70) then
	    if (mouseY > maxy - 75 & mouseY < maxy - 25) then
		actionChoice := 0 % rectangle option
	    elsif (mouseY > maxy - 150 & mouseY < maxy - 100) then
		actionChoice := 1 % Circle
	    elsif (mouseY > maxy - 225 & mouseY < maxy - 175) then
		actionChoice := 2 %semiCircle
	    elsif (mouseY > maxy - 300 & mouseY < maxy - 250) then
		actionChoice := 3 %Star
	    elsif (mouseY > maxy - 375 & mouseY < maxy - 325) then
		actionChoice := 4 %Line
	    elsif (mouseY > maxy - 450 & mouseY < maxy - 400) then
		actionChoice := 5 %filling
	    end if
	end if
	%checks if it has clicked the color pallet and changes the colour selected if they did
	if (mouseX > colorBoxs (1).x1 & mouseX < colorBoxs (255).x2) then
	    if (mouseY > colorBoxs (1).y1 & mouseY < colorBoxs (1).y2) then

		colorChoice := whatdotcolour (mouseX, mouseY)
	    end if
	end if
    end if
end CheckMouseCollisions

%Pre: none
%Post: All images, objects and stats will be updated
%Description: Update the locations, frames for all images as well as any stats
procedure Update ()
    %The grey backround boxs
    if (setUpHud = false) then
	hudBackRound (1).x1 := 0
	hudBackRound (1).x2 := 75
	hudBackRound (1).y1 := 0
	hudBackRound (1).y2 := maxy
	hudBackRound (1).colorNum := 255
	hudBackRound (1).fillNum := 138

	hudBackRound (2).x1 := 75
	hudBackRound (2).x2 := maxx
	hudBackRound (2).y1 := 0
	hudBackRound (2).y2 := 76
	hudBackRound (2).colorNum := 255
	hudBackRound (2).fillNum := 138
	%the boxs that contain options such as draw rectangle
	for i : 1 .. 6
	    actionBoxs (i).x1 := 5
	    actionBoxs (i).x2 := 70
	    actionBoxs (i).y1 := maxy - (75 * (i))
	    actionBoxs (i).y2 := actionBoxs (i).y1 + 50
	    actionBoxs (i).colorNum := 255

	    setUpHud := true
	end for


    end if

    %only looks for mouse collisions when the user isnt drawing anything
    if (isDrawing = false) then
	CheckMouseCollisions ()
    else
	Mouse.Where (mouseX, mouseY, mouseMode)
    end if

end Update

%Pre: none
%Post: Will draw the options the user can have
%Description: Draws the user interface
procedure SetupHud ()
    for i : 1 .. 2
	%%creates the hud
	Draw.Box (hudBackRound (i).x1, hudBackRound (i).y1, hudBackRound (i).x2, hudBackRound (i).y2, hudBackRound (i).colorNum)
	Draw.Fill (hudBackRound (i).x1 + 1, hudBackRound (i).y1 + 1, hudBackRound (i).fillNum, hudBackRound (i).colorNum)
    end for

    for i : 1 .. 6
	Draw.Box (actionBoxs (i).x1, actionBoxs (i).y1, actionBoxs (i).x2, actionBoxs (i).y2, actionBoxs (i).colorNum)
    end for
    %%Draws text on a box
    Font.Draw ("Draw Box", 5, maxy - 50, Font.New ("serif:12"), 16)

    %%Draws text on a box
    Font.Draw ("Draw Circle", 7, maxy - 130, Font.New ("serif:10"), 14)

    %%Draws text on a box
    Font.Draw ("Draw Star", 7, maxy - 210, Font.New ("serif:12"), 16)

    %%Draws text on a box
    Font.Draw ("Draw Semi", 7, maxy - 275, Font.New ("serif:10"), 16)

    %%Draws text on a box
    Font.Draw ("Circle", 7, maxy - 290, Font.New ("serif:10"), 16)

    %%Draws text on a box
    Font.Draw ("Draw Line", 7, maxy - 360, Font.New ("serif:12"), 16)

    %%Draws a text on a box
    Font.Draw ("Fill", 25, actionBoxs (6).y1 + 15, Font.New ("serif:12"), 16)

    %put upper (userShapes)
    var colorX : int := 100
    var colorY : int := 75
    var colorWidth : int := maxx div 255
    %%These are very small boxs that will represent the colors the user may use
    for i : 0 .. 255
	if (i = 0) then
	    Draw.Box (colorX, 0, colorX + colorWidth, colorY, i)
	    colorBoxs (i + 1).x1 := colorX
	    colorBoxs (i + 1).x2 := colorX + colorWidth
	    colorBoxs (i + 1).y1 := 0
	    colorBoxs (i + 1).y2 := colorY
	else
	    colorX := colorX + colorWidth
	    Draw.Box (colorX, 0, colorX + colorWidth, colorY, i)
	    colorBoxs (i + 1).x1 := colorX
	    colorBoxs (i + 1).x2 := colorX + colorWidth
	    colorBoxs (i + 1).y1 := 0
	    colorBoxs (i + 1).y2 := colorY
	end if
	Draw.FillBox (colorX + 1, 1, colorX + colorWidth - 1, colorY - 1, i)
    end for

    Font.Draw ("Color Selected:", 1, 60, Font.New ("serif:12"), 14)

    Draw.FillBox (1, 10, 50, 50, colorChoice)

end SetupHud

%pre: none
%post : takes information from an array and decides what shape needs to be drawn
%description : draws all the shapes that the user has entered
procedure DrawAllUserShapes ()
    if (upper (userShapes) > 0) then
	put "test " + intstr (upper (userShapes))

	for i : 1 .. upper (userShapes)
	    %locatexy(0,i * 20)
	    %put "test " + intstr(upper (userShapes))
	    if (userShapes (i).shapeNum = 0) then
		Draw.Box (userShapes (i).rectangle.x1, userShapes (i).rectangle.y1, userShapes (i).rectangle.x2, userShapes (i).rectangle.y2, userShapes (i).rectangle.colorNum)
		Draw.FillBox (userShapes (i).rectangle.x1, userShapes (i).rectangle.y1, userShapes (i).rectangle.x2, userShapes (i).rectangle.y2, userShapes (i).rectangle.colorNum)
	    elsif (userShapes (i).shapeNum = 1) then
		Draw.Oval (userShapes (i).circle.x1, userShapes (i).circle.y1, userShapes (i).circle.xRadius, userShapes (i).circle.yRadius, userShapes (i).circle.colorNum)
		Draw.FillOval (userShapes (i).circle.x1, userShapes (i).circle.y1, userShapes (i).circle.xRadius, userShapes (i).circle.yRadius, userShapes (i).circle.colorNum)
	    elsif (userShapes (i).shapeNum = 2) then
		Draw.Arc (userShapes (i).semiCircle.x1, userShapes (i).semiCircle.y1, userShapes (i).semiCircle.xRadius, userShapes (i).semiCircle.yRadius, 0, 180,
		    userShapes (i).semiCircle.colorNum)
	    elsif (userShapes (i).shapeNum = 3) then
		Draw.Star (userShapes (i).star.x1, userShapes (i).star.y1, userShapes (i).star.x2, userShapes (i).star.y2, userShapes (i).star.colorNum)
		Draw.FillStar (userShapes (i).star.x1, userShapes (i).star.y1, userShapes (i).star.x2, userShapes (i).star.y2, userShapes (i).star.colorNum)
	    elsif (userShapes (i).shapeNum = 4) then
		Draw.Line (userShapes (i).line.x1, userShapes (i).line.y1, userShapes (i).line.x2, userShapes (i).line.y2, userShapes (i).line.colorNum)
	    end if
	end for
    end if
end DrawAllUserShapes

%Pre: none
%Post: Draw all needed visible items on the screen
%Description: Using specific subprograms draw all needed items
procedure DrawProgram ()
    cls
    SetupHud ()

    DrawAllUserShapes ()
    %Draw Middleground (Characters, environment objects, etc.)
    if (mouseX > 75 & mouseX < maxx) then
	if (mouseY > 75 & mouseY < maxy) then
	    if (actionChoice = 0) then
		DrawBox ()
	    elsif (actionChoice = 1) then
		DrawCircle ()
	    elsif (actionChoice = 2) then
		DrawStar ()
	    elsif (actionChoice = 3) then
		DrawSemiCircle ()
	    elsif (actionChoice = 4) then
		DrawLine ()
	    elsif (actionChoice = 5) then
		FillBox ()
	    end if
	end if
    end if
    %Draw Foreground (Anything that should be drawn on top of the Middleground

    %Everything has been drawn, Update the screen (which will actually put everything on the screen)
    View.Update ()
end DrawProgram

%Pre: none
%Post: Removes the last colour change or a shape creation
%Description: Removes the last colour change or a shape creation
procedure Undo ()

    %will be used to exit the loops below
    var isUndoDone : boolean := false
    %%starts at the end of the number of changes
    for decreasing i : numUndoElements .. 1
	%looks to see if there is anything to undo here (-1 means it has nothing to undo)
	if (undoStack (i) not= -1) then
	    %checks to see if there is no colours to remove
	    if (userShapes (undoStack (i)).numFillChanges < 1) then
		%it then removes the last element and will exit the loops
		new userShapes, upper (userShapes) - 1
		numUndoElements := numUndoElements - 1
		isUndoDone := true

		%if there is elements to remove
	    else
		%starts at the end of the colours changed(most recent one that was changed)
		for decreasing k : userShapes (undoStack (i)).numFillChanges .. 1
		    %checks to see if its a rectangle
		    if (userShapes (undoStack (i)).shapeNum = 0) then
			%gives back the rectangles colour and reduces how many fill changes it has and reduces the number of undo's left in queue
			userShapes (undoStack (i)).rectangle.colorNum := userShapes (undoStack (i)).lastFillNum (k)
			userShapes (undoStack (i)).numFillChanges := userShapes (undoStack (i)).numFillChanges - 1
			numUndoElements := numUndoElements - 1
		    elsif (userShapes (undoStack (i)).shapeNum = 1) then
			%gives back the rectangles colour and reduces how many fill changes it has and reduces the number of undo's left in queue
			userShapes (undoStack (i)).circle.colorNum := userShapes (undoStack (i)).lastFillNum (k)
			userShapes (undoStack (i)).numFillChanges := userShapes (undoStack (i)).numFillChanges - 1
			numUndoElements := numUndoElements - 1
		    elsif (userShapes (undoStack (i)).shapeNum = 3) then
			%gives back the rectangles colour and reduces how many fill changes it has and reduces the number of undo's left in queue
			userShapes (undoStack (i)).star.colorNum := userShapes (undoStack (i)).lastFillNum (k)
			userShapes (undoStack (i)).numFillChanges := userShapes (undoStack (i)).numFillChanges - 1
			numUndoElements := numUndoElements - 1
		    end if
		    %exit loop
		    isUndoDone := true
		    if (isUndoDone = true) then
			exit
		    end if
		end for
	    end if
	end if
	%exits the loop
	if (isUndoDone = true) then
	    exit
	end if
    end for
end Undo

%Main Game Loop:
% 1. Clear the screen
% 2. Get user input
% 3. Update all items in the game
%   -Move items
%   -update stats like scores, etc.
%   -etc.
% 4. Check for collisions
% 5. Redraw the screen
% 6. Play any sounds that need to be played
% 7. Delay the loop enough time to result in an fps of 30
loop
    %1. Clear the screen
    %2. Get User Input and handle it (This is where you check for control)
    % hasch is a special command that check to see if the user has typed a letter
    % if they have then we will "getch" the letter and check to see what it is
    % and handle it appropriately
    if (hasch) then
	%read in the character the user typed and clear out any extra keys because of a held in key
	getch (key)
	Input.Flush
	%check to see what letter it is and handle it appropriately
	case key of

		%if the user entered "x" they want to exit
	    label "x" :
		isGameDone := true
	    label "a" :
		put "a"
	    label "c" :
		Draw.Cls
	    label "u" :
		Undo ()
	end case
    end if

    %Update all items and necessary inforamation of the program
    Update ()

    %ReDraw ALL items that need to be drawn on the screen
    DrawProgram ()


    %Delay enough time to force 30 fps, in Turing time is measured in milliseconds
    %There are 1000 milliseconds in 1 second, 1000/30 =  33 milliseconds
    %if you want to change your framerate just recalculate the math and change the delay
    delay (33)

    exit when isGameDone = true
end loop

quit
