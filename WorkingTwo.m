clc;
clear;

%  Plays selected music
bgMusic = audioplayer(audioread('Perfection(chosic.com).mp3'), 44100); % Loads the mp3 file into the built in autoplayer in MATLAB
play(bgMusic); % Plays the loaded music
 
% Function for Start Screen Poker 
function startScreen
    % This function creates the start screen UI for the Texas Hold'em game.
   
    % Create a UI figure for the start screen, setting its name and position on the screen
    startfigure = uifigure('Name', 'Texas Hold''Em', 'Position', [300, 150, 800, 600]);
 
    % Adds a background image to the UI figure
    backgroundStart = uiimage(startfigure);
    backgroundStart.ImageSource = 'texas-holdem-1.png'; % Specify the image file for the background
    backgroundStart.Position = [0, 0, startfigure.Position(3), startfigure.Position(4)]; % Scale the image to cover the entire UI figure

    % Adds a label to prompt the user to choose a card color
    cardColorLabel = uilabel(startfigure, 'Text', 'Choose Card Color:', 'Position', [350, 375, 100, 25], 'FontColor',[1, 1, 1], 'FontSize', 8);

    % Adds a dropdown menu for selecting the card color
    cardColorDropdown = uidropdown(startfigure, 'Position', [350, 350, 100, 25], ...
                                   'Items', {'Red', 'Blue', 'Green', 'Purple'}, ... % Options for card colors
                                   'Value', 'Red');  % Set the default selection to 'Red'

    % Creates a Start button to begin the game
    startButton = uibutton(startfigure, 'push', 'Text', 'Start', 'Position', [350, 275, 100, 50], ...
                           'ButtonPushedFcn', @(btn, event) startButtonPushed()); % Specify a callback function to execute when the button is pressed

    % Nested function that executes when the Start button is pressed
    function startButtonPushed()
        % Retrieve the selected card color from the dropdown menu
        selectedColor = cardColorDropdown.Value;

        % Displays an alert to indicate that the game is starting
        uialert(startfigure, 'Game Starting...', 'Please Wait');
        
        pause(2); % Adds a brief delay before starting the game
        
        close(startfigure); % Closes the start screen figure
        
        MainGame(selectedColor); % Calls the MainGame function and pass the selected card color
    end
end

% Calls the startScreen function to display the start screen
startScreen;
function MainGame(cardColor)
    % Changes the card color based on dropdown choice
    switch cardColor
        case 'Red'
            cardColorValue = 3; % Red corresponds to card number 3
        case 'Blue'
            cardColorValue = 5; % Blue corresponds to card number 5
        case 'Green'
            cardColorValue = 7; % Green corresponds to card number 7
        case 'Purple'
            cardColorValue = 9; % Purple corresponds to card number 9
        otherwise
            cardColorValue = 3; % Default to Red if something goes wrong
    end
    
% Load the card scene
cardScene = simpleGameEngine('retro_cards.png', 16, 16, 5, [144, 238, 144]);

spriteMin = 21; % Lower bound of the range
spriteMax = 72; % Upper bound of the range
n = 13;         % Number of cards to generate

cardNumbers = randperm(spriteMax - spriteMin + 1, n) + spriteMin - 1;

% Set face-down sprite number
faceDownSprite = cardColorValue;

%% Display Table

% Define the background as a 9x9 matrix filled with "1"
background = ones(9,9);

[finalScene, dealerFlop,  dealerTurn, dealerRiver]= drawHands(cardScene, faceDownSprite, background, cardNumbers);

% Setting the dealer cards back to their non hidden numbers
dealerFlop(5, 2) = cardNumbers(7);
dealerFlop(5, 3) = cardNumbers(8);
dealerFlop(5, 4) = cardNumbers(9);
dealerTurn(5, 6) = cardNumbers(11);
dealerRiver(5, 8) = cardNumbers(13);

% Text under the figures
text(60, 0, 'Texas Hold''Em Two Player Game', 'FontSize', 10, 'FontWeight', 'bold'); % Title of the figure
text(270, 50, 'Player 1''s hand', 'FontSize', 9, 'FontWeight', 'bold');   % first hand (bottom row)
text(270, 600, 'Player 2''s hand', 'FontSize', 9, 'FontWeight', 'bold');   % second hand (top row)
text(60, 300, 'Dealer''s hand', 'FontSize', 9, 'FontWeight', 'bold'); % dealer flop (center)
text(410, 300, 'Turn', 'FontSize', 9, 'FontWeight', 'bold'); % dealer turn (center)
text(570, 300, 'River', 'FontSize', 9, 'FontWeight', 'bold'); % dealer river (center)

% Intializing bet variables
player1Bank = 95; % Handles money in banks 100 for starting value - initial bet
player2Bank = 90;
player1Bet = 5; % Creating initial bets
player2Bet = 10;
pot = player1Bet + player2Bet; % pot is the combination of all bets
bigBlind = 1; % Setting up blind labels. These are set up for the next hand
smallBlind = 2;
buyIn = 10; % The amount needed to play any one hand to force investment
            % Because of the way raises are coded 10 is also the minimum
            % bet

playerBets = [player1Bet, player2Bet]; % Combining blinds and bets into arrays
playerBanks = [player1Bank, player2Bank]; % For easy access

whosTurn = 1; % turn tracker
opponent = 2; % opponent tracker
cardsRevealed = [0,0,0]; % tracks which phase the game is in
%{
  1, 0, 0 post flop
  1, 1, 0 post turn
  1, 1, 1 post turn
%}

turnsTaken = [0,0]; % tracks turns taken 1, 1 is ready for next phase
% Hiding players hand cards
finalScene(9, 4) = faceDownSprite;
finalScene(9, 6) = faceDownSprite;
finalScene(2, 4) = faceDownSprite;
finalScene(2, 6) = faceDownSprite;
cardScene.drawScene(finalScene);
% Setting up a couple of variables to avoid errors 
bankText1 = '';
bankText2 = '';
betText1 = '';
betText2 = '';
potText = '';
gameOver = 0; % Tracks if the game is still going

%% Betting, Turn, and Input system
while ~gameOver
    % Deleting previos lines of text so they are not written over
    delete(bankText1)
    delete(bankText2)
    delete(betText1)
    delete(betText2)
    delete(potText)

    % Creating strings by concating to use in the text function
    Player1BankText = "Player 1's bank: $" + playerBanks(1); % Text for bank display
    Player2BankText = "Player 2's bank: $" + playerBanks(2);
    Player1BetText = "Player 1's bet: $" + playerBets(1); % Text for bet display
    Player2BetText = "Player 2's bet: $" + playerBets(2);
    potText = "Pot: $" + pot; % Text for display of pot
    % Displays All bank, bet, and pot related text
    bankText1 = text(500, 100, Player1BankText, 'FontSize', 8, 'FontWeight', 'bold');
    bankText2 = text(500, 500, Player2BankText, 'FontSize', 8, 'FontWeight', 'bold');
    betText1 = text(500, 150, Player1BetText, 'FontSize', 8, 'FontWeight', 'bold');
    betText2 = text(500, 450, Player2BetText, 'FontSize', 8, 'FontWeight', 'bold');
    potText = text(50, 60, potText, 'FontSize', 8, 'FontWeight', 'bold');

    folded = 0; % Tracks if a player has folded (Must reset after each loop)
 
    % Printing to display the turn and waiting for an input
    % This ensure that a hand wont be accidentally revealed
    turnText = "Player " + whosTurn + "'s turn (press any to start)";
    xlabel(turnText)
    waitforbuttonpress()

    % Reveal the players cards after the turn has been confirmed
    if whosTurn == 2
    finalScene(9, 4) = cardNumbers(2); % First Hand Card
    finalScene(9, 6) = cardNumbers(4); % First Hand Card
    else
    finalScene(2, 4) = cardNumbers(3); % Second Hand Card
    finalScene(2, 6) = cardNumbers(5); % Second Hand Card
    end
    cardScene.drawScene(finalScene);

    % If statement that checks if the player is on bet or beneath
    % If a players bet is under they are given the option to raise, call, or
    % fold
    % Otherwise they can raise, check, or fold
    if(playerBets(whosTurn) < playerBets(opponent))
        % Calculating difference in players bets
        % This will always be positive due to the preceding if
        betDifference = playerBets(opponent) - playerBets(whosTurn);
        % Displaying the players option in the window
        xlabel('Actions = Raise:J | Call:Space | Fold:F')
        % wait for an input
        input = getKeyboardInput(cardScene);
        switch input
            case "j" % If J is pressed go through raise options
                xlabel('Press a number key the raise is the highest bet + input x 10')
                % Takes a keyboard string input and converts it to a double
                input = str2double(getKeyboardInput(cardScene));
                % Checks if the input is not nan(a letter) or an imaginary
                % number(i)
                if isnan(input) || input == 1i
                    xlabel('Please enter a valid input(Any key to continue)')
                    waitforbuttonpress()
                    continue
                end
                % Assigns the planned raise ammount
                % If amount is over players bank player is all in
                input = input * 10;
                if input > playerBanks(whosTurn)
                    playerBets(whosTurn) = playerBanks(whosTurn) + playerBets(whosTurn);
                    playerBanks(whosTurn) = 0;
                else
                    playerBets(whosTurn) = playerBets(whosTurn) + betDifference + input;
                    playerBanks(whosTurn) = playerBanks(whosTurn) - betDifference - input;
                end
                % Setting turn tracker to one turn taken
                % The opponent will always recieve an action after a raise
                % is made
                turnsTaken = [1,0];
            case "space" % If space is pressed call the player up to the bet
                % If the call is greater than players bank they are all in
                if betDifference > playerBanks(whosTurn)
                    playerBets(whosTurn) = playerBanks(whosTurn) + playerBets(whosTurn);
                    playerBanks(whosTurn) = 0;
                else
                    playerBets(whosTurn) = playerBets(whosTurn) + betDifference;
                    playerBanks(whosTurn) = playerBanks(whosTurn) - betDifference;
                end
                % Increments turns taken
                turnsTaken(1+turnsTaken(1)) = 1;
            case "f" % If f is pressed player has folded and forfeights the hand
                folded = 1;
                % Granting pot to opponent displaing the amount won an
                % waiting for input
                playerBanks(opponent) = playerBanks(opponent) + pot;
                foldText = "player " + opponent + " wins $" + pot + " (Press any button)";
                xlabel(foldText)
                waitforbuttonpress()

            otherwise
                % If the wrong button is pressed display an error and
                % return to the begining of the loop keeping the active
                % player the same
                xlabel('Please choose a valid option(press anything to continue)')
                waitforbuttonpress()
                continue

        end
    else % Case for Equal bet amounts
         % A player with a greater bet should never be on action
        xlabel('Action = Raise:J | Check:Space | Fold:F')
        input = getKeyboardInput(cardScene);
        switch input
            case "j" % Handles raising no difference is used
                xlabel('Press a number key the raise is input x 10')
                input = str2double(getKeyboardInput(cardScene));
                if isnan(input) || input == 1i
                    xlabel('Please enter a valid input(Any key to continue)')
                    waitforbuttonpress()
                    continue
                end
                input = input * 10;
                % If amount is greater than players bank they are all in
                if input > playerBanks(whosTurn)
                    playerBets(whosTurn) = playerBanks(whosTurn) + playerBets(whosTurn);
                    playerBanks(whosTurn) = 0;
                else
                    playerBets(whosTurn) = playerBets(whosTurn) + input;
                    playerBanks(whosTurn) = playerBanks(whosTurn) - input;
                end
                % Sets turns taken to ensure the opponent is given action
                turnsTaken = [1,0];
            case "space" % Handles check simply increments turn counter
                turnsTaken(1+turnsTaken(1)) = 1;

            case "f" % Handles hand forfeighting
                     % (With the option to check this is usually a bad play)
                folded = 1;
                playerBanks(opponent) = playerBanks(opponent) + pot;
                foldText = "player " + opponent + " wins $" + pot + " (Press any button)";
                xlabel(foldText)
                waitforbuttonpress()

            otherwise % Handles an unexpected input
                xlabel('Please choose a valid option(press anything to continue)')
                waitforbuttonpress()
                continue
        end

    end
    if folded % if the current player has folded enforce blinds and start a new hand
       if playerBanks(1) && playerBanks(2) % If neither player is at zero
           % Checking that the big blind can afford to buy in
           % If not they are all in for the hand
           if playerBanks(bigBlind) < buyIn
                playerBets(bigBlind) = playerBanks(bigBlind);
                playerBanks(bigBlind) = 0;
           else 
               playerBets(bigBlind) = buyIn;
               playerBanks(bigBlind) = playerBanks(bigBlind) - buyIn;
           end
           % Check is not made for smallblind as due to how the logic and
           % raises are made if both players can play they can always
           % afford the blind
           playerBets(smallBlind) = buyIn/2;
           playerBanks(smallBlind) = playerBanks(smallBlind) - buyIn/2;
           % First turn is always given to the small blind
           whosTurn = smallBlind;
           opponent = bigBlind;
           % Changing who the blinds will be next round
           temp = bigBlind;
           bigBlind = smallBlind;
           smallBlind = temp;
           % Reset turn and card trackers
           turnsTaken = [0,0];
            cardsRevealed = [0,0,0];
           % Generate a new array and create a new board for the next hand
           cardNumbers = randperm(spriteMax - spriteMin + 1, n) + spriteMin - 1;
           [finalScene, dealerFlop,  dealerTurn, dealerRiver] = drawHands(cardScene, faceDownSprite, background, cardNumbers);
           % After a new hand is generated rese dealer cards back to non
           % hidden numbers
            dealerFlop(5, 2) = cardNumbers(7);
            dealerFlop(5, 3) = cardNumbers(8);
            dealerFlop(5, 4) = cardNumbers(9);
            dealerTurn(5, 6) = cardNumbers(11);
            dealerRiver(5, 8) = cardNumbers(13);
       else
           gameOver = 1;
           continue
       end
       % If all cards are reveled or either player bank is empty and both
       % players have taken action go through the end of hand actions
       elseif cardsRevealed(3) == 1 || playerBanks(1) == 0 || playerBanks(2) == 0 && turnsTaken(2) == 1
         finalScene(9, 4) = cardNumbers(2); % First Hand Card
        finalScene(9, 6) = cardNumbers(4); % First Hand Card
        finalScene(2, 4) = cardNumbers(3); % Second Hand Card
        finalScene(2, 6) = cardNumbers(5); % Second Hand Card
        finalScene(5, 2) = dealerFlop(5, 2); % Reveal Flop 1
        finalScene(5, 3) = dealerFlop(5, 3); % Reveal Flop 2
        finalScene(5, 4) = dealerFlop(5, 4); % Reveal Flop 3
        finalScene(5, 6) = dealerTurn(5, 6); % Reveal Turn
        finalScene(5, 8) = dealerRiver(5, 8); % Reveal River
        
        % Preparing to redisplay all lines of text to account for calls
        delete(bankText1)
        delete(bankText2)
        delete(betText1)
        delete(betText2)
        delete(potText)
        pot = sum(playerBets);

        % Redisplaying current pot information
        Player1BankText = "Player 1's bank: $" + playerBanks(1); % Text for bank display
        Player2BankText = "Player 2's bank: $" + playerBanks(2);
        Player1BetText = "Player 1's bet: $" + playerBets(1); % Text for bet display
        Player2BetText = "Player 2's bet: $" + playerBets(2);
        potText = "Pot: $" + pot; % Text for display of pot
        bankText1 = text(500, 50, Player1BankText, 'FontSize', 9, 'FontWeight', 'bold');
        bankText2 = text(500, 600, Player2BankText, 'FontSize', 9, 'FontWeight', 'bold');
        betText1 = text(500, 70, Player1BetText, 'FontSize', 9, 'FontWeight', 'bold');
        betText2 = text(500, 570, Player2BetText, 'FontSize', 9, 'FontWeight', 'bold');
        potText = text(50, 60, potText, 'FontSize', 9, 'FontWeight', 'bold');

        cardScene.drawScene(finalScene);
        
        % Combine each player's hand with the dealer's hand
        firstPlayerHand = [finalScene(2, 4), finalScene(2, 6), dealerFlop(5, 2), dealerFlop(5, 3), dealerFlop(5, 4), dealerTurn(5, 6), dealerRiver(5, 8)];
        secondPlayerHand = [finalScene(9, 4), finalScene(9, 6), dealerFlop(5, 2), dealerFlop(5, 3), dealerFlop(5, 4), dealerTurn(5, 6), dealerRiver(5, 8)];
        % Evaluate both hands
        [firstHandType, firstHandRank, firstTie] = evaluatePokerHand(firstPlayerHand);
        [secondHandType, secondHandRank, secondTie] = evaluatePokerHand(secondPlayerHand);
        
        % Display the evaluation results
        player1Text = "Player 1 Hand Type: " + firstHandType + "(Rank: " + firstHandRank + ")";
        player2Text = "Player 2 Hand Type: " + secondHandType + "(Rank: " + secondHandRank + ")";
        title(player1Text);
        xlabel(player2Text);
        waitforbuttonpress()
        title('Press any button to start next hand')
        % Determine the winner
        % The winner will be given the pot
        if firstHandRank > secondHandRank
            xlabel('Player 1 has the higher hand!');
            playerBanks(1) = playerBanks(1) + pot;
        elseif firstHandRank < secondHandRank
            xlabel('Player 2 has the higher hand!');
            playerBanks(2) = playerBanks(2) + pot;
        else % the tie conditions check the highest card available in for each player
            if firstTie > secondTie
                xlabel('Player 1 has the higher hand!');
                playerBanks(1) = playerBanks(1) + pot;
            elseif firstTie < secondTie
                xlabel('Player 2 has the higher hand!');
                playerBanks(2) = playerBanks(2) + pot;
            else
                % In the case of a tie the pot is split evenly or "Chopped"
                xlabel('It''s a tie!');
                playerBanks(1) = playerBanks(1) + pot/2;
                playerBanks(2) = playerBanks(2) + pot/2;
            end
        end
        waitforbuttonpress()
        % If neither player has an empty bank set up for the next hand
        if playerBanks(1) && playerBanks(2)
            title('')
            % If big blind cannot afford buy in they are all in
            if playerBanks(bigBlind) < buyIn
                playerBets(bigBlind) = playerBanks(bigBlind);
                playerBanks(bigBlind) = 0;
           else 
               playerBets(bigBlind) = buyIn;
               playerBanks(bigBlind) = playerBanks(bigBlind) - buyIn;
            end
            % Check does not happen for small blind
            playerBets(smallBlind) = buyIn/2;
            playerBanks(smallBlind) = playerBanks(smallBlind) - buyIn/2;
            % setting turns and blinds
            whosTurn = smallBlind;
            opponent = bigBlind;
            temp = bigBlind;
            bigBlind = smallBlind;
            smallBlind = temp;
            % Resseting trackers
            turnsTaken = [0,0];
            cardsRevealed = [0,0,0];
            % Dealing new hand
            cardNumbers = randperm(spriteMax - spriteMin + 1, n) + spriteMin - 1;
            [finalScene, dealerFlop,  dealerTurn, dealerRiver] = drawHands(cardScene, faceDownSprite, background, cardNumbers);
            % Setting the dealer cards back to their non hidden numbers
            dealerFlop(5, 2) = cardNumbers(7);
            dealerFlop(5, 3) = cardNumbers(8);
            dealerFlop(5, 4) = cardNumbers(9);
            dealerTurn(5, 6) = cardNumbers(11);
            dealerRiver(5, 8) = cardNumbers(13);
        else
           gameOver = 1;
           continue
       end
    elseif turnsTaken(2) == 1 % If turns are done reveal cards
        if cardsRevealed(1) == 0 % No cards revealed show the flop (first 3)
            finalScene(5, 2) = dealerFlop(5, 2); % Reveal Flop 1
            finalScene(5, 3) = dealerFlop(5, 3); % Reveal Flop 2
            finalScene(5, 4) = dealerFlop(5, 4); % Reveal Flop 3
            cardsRevealed(1) = 1;
        elseif cardsRevealed(2) == 0 % After flop reveal one more card
            finalScene(5, 6) = dealerTurn(5, 6); % Reveal Turn
            cardsRevealed(2) = 1;
        else % Finally reveal the final card
            finalScene(5, 8) = dealerRiver(5, 8); % Reveal River
            cardsRevealed(3) = 1;
        end
        % Setting turn always starting with small blind
        whosTurn = bigBlind; % setting to opposite as blinds store for next hand
        opponent = smallBlind;
        cardScene.drawScene(finalScene);
        turnsTaken = [0,0];
    else % If all other cases fail simply swap the players turns
        temp = whosTurn;
        whosTurn = opponent;
        opponent = temp;
    end
    % Updating the pot
    pot = sum(playerBets);
    % Hiding all players cards before the start of the next turn
    finalScene(9, 4) = faceDownSprite;
    finalScene(9, 6) = faceDownSprite;
    finalScene(2, 4) = faceDownSprite;
    finalScene(2, 6) = faceDownSprite;
    cardScene.drawScene(finalScene);
end
% After the game is over check who still has money that player is declared
% the winner
if playerBanks(1)
    title('Game over. Player 1 wins!')
    xlabel('Thanks for playing!')
elseif playerBanks(2)
    title('Game over. Player 2 wins!')
    xlabel('Thanks for playing!')
end

%% Hand Comparison System
% Function to evaluate poker hands and return the hand rank
function [handType, handRank, tieBreaker] = evaluatePokerHand(hand)
    % Helper function to extract suit and rank
    getSuit = @(card) floor((card - 21) / 13) + 1; 
    %function that finds the suit number by dividing it by 13 and then
    %assigning hearts to 0, diamonds to 1, clubs to 2, spades to 3, floor
    %rounds a number down to the nearest integer 

    getRank = @(card) mod(card - 21, 13) + 1; 
    %subtracts 21 every  13 and converts the numbers to cards, 1 = ace etc
    % Extract suits and ranks from the hand

    handRanks = arrayfun(getRank, hand);
    handSuits = arrayfun(getSuit, hand);
    %uses arrayfun to apply it to every card in the function 

    % Sort ranks for easier pattern matching
    sortedRanks = sort(handRanks);
    tieBreaker = sortedRanks(end);

    % Check for winning hands
    isFlush = numel(unique(handSuits)) == 1; %handSuits is an array containg the number of the suit 
    %nume1 unique finds if all the numbers are the same 
   
    isStraight = all(diff(sortedRanks) == 1); %sorted ranks is an array containing the card ranks
    %diff finds the difference between the ascending numbers, if 1 1 1 1 1,
    %then straight, all finds if all of them are

    isRoyal = isequal(sortedRanks, [10, 11, 12, 13, 1]); 
    % if the ranks are sequential and the arrays are identical

    uniqueRanks = unique(handRanks);%finds the unique array [2, 3, 4, 2, 3] =[2, 3, 4]
    rankCounts = histc(handRanks, uniqueRanks); %histc finds the amount of times rank occurs in the hand
    fprintf('%g, ', rankCounts)
    fprintf('\n')

    % Assign hand ranks (higher is better)
    if isFlush && isRoyal
        handType = 'Royal Flush';
        handRank = 10;
    elseif isFlush && isStraight
        handType = 'Straight Flush';
        handRank = 9;
    elseif any(rankCounts == 4)
        handType = 'Four of a Kind';
        handRank = 8;
    elseif any(rankCounts == 3) && any(rankCounts == 2)
        handType = 'Full House';
        handRank = 7;
    elseif isFlush
        handType = 'Flush';
        handRank = 6;
    elseif isStraight
        handType = 'Straight';
        handRank = 5;
    elseif any(rankCounts == 3)
        handType = 'Three of a Kind';
        handRank = 4;
    elseif sum(rankCounts == 2) == 2
        handType = 'Two Pair';
        handRank = 3;
    elseif any(rankCounts == 2)
        handType = 'One Pair';
        handRank = 2;
    else
        handType = 'High Card';
        handRank = 1;
    end
end

function [finalScene, dealerFlop, dealerTurn, dealerRiver] = drawHands(cardScene, faceDownSprite, background, cardNumbers)
        
    % Replace row 9, column 4 and 6 with first player cards
    firstHand(9, 4) = cardNumbers(2);
    firstHand(9, 6) = cardNumbers(4);

    % Replace row 2, column 4 and 6 with second player cards
    secondHand(2, 4) = cardNumbers(3);
    secondHand(2, 6) = cardNumbers(5);
    
    % Set the dealer's cards face down initially
    % Replace row 5, columns 2, 3, 4, 6, and 8 with face-down sprite
    dealerFlop = zeros(8);
    for col = [2, 3, 4, 6, 8] 
        dealerFlop(5, col) = faceDownSprite;
    end
        
    dealerTurn(5, 6) = faceDownSprite;
    dealerRiver(5, 8) = faceDownSprite;
    
    % Combine all elements into one final matrix
    finalScene = background;  % Start with the background
    
    % Add firstHand, secondHand, and dealer cards to the background
    finalScene(9, 4) = firstHand(9, 4); % First Hand Card
    finalScene(9, 6) = firstHand(9, 6); % First Hand Card
    
    finalScene(2, 4) = secondHand(2, 4); % Second Hand Card
    finalScene(2, 6) = secondHand(2, 6); % Second Hand Card
    
    % Dealer cards (face-down)
    finalScene(5, 2) = dealerFlop(5, 2);
    finalScene(5, 3) = dealerFlop(5, 3);
    finalScene(5, 4) = dealerFlop(5, 4);
    finalScene(5, 6) = dealerTurn(5, 6);
    finalScene(5, 8) = dealerRiver(5, 8);
    
    % Draw the combined scene with non-card places filled with 1
    cardScene.drawScene(finalScene);
end
end
