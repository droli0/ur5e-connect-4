function [column, score] = minimax(board, depth, isMaximizing)
    % MINIMAX - Determines best move for Connect 4 using minimax algorithm
    % Parameters:
    %   board - 5x7 matrix where 0=empty, 1=robot(red), 2=opponent(blue)
    %   depth - Search depth for the algorithm
    %   isMaximizing - true if maximizing player (robot), false otherwise
    %
    % Returns:
    %   column - Best column to drop piece (1-7)
    %   score - Score of the chosen move
    
    % Define player pieces
    ai_piece = 1;      % Robot/AI piece (red)
    human_piece = 2;   % Human player piece (blue)
    
    % Position weights for board evaluation
    position_weights = [
        3 4 5 7 5 4 3;
        4 6 8 10 8 6 4;
        5 8 11 13 11 8 5;
        4 6 8 10 8 6 4;
        3 4 5 7 5 4 3;
    ];
    
    % Check for winning move immediately - this ensures we prioritize immediate wins
    valid_moves = findValidMoves(board);
    if isMaximizing
        % Check if AI can win in the next move
        for i = 1:length(valid_moves)
            col = valid_moves(i);
            new_board = makeMove(board, col, ai_piece);
            if checkWin(new_board, ai_piece)
                column = col;
                score = 1000000; % Very high score for winning move
                return;
            end
        end
    else
        % Check if human can win in the next move
        for i = 1:length(valid_moves)
            col = valid_moves(i);
            new_board = makeMove(board, col, human_piece);
            if checkWin(new_board, human_piece)
                column = col;
                score = -1000000; % Very low score for opponent winning move
                return;
            end
        end
    end
    
    % If at terminal depth or board is full, evaluate and return
    if depth == 0 || isFullBoard(board)
        score = evaluateBoard(board, position_weights, ai_piece, human_piece);
        column = -1; % No column chosen at leaf nodes
        return;
    end
    
    if isempty(valid_moves)
        % No valid moves available
        score = evaluateBoard(board, position_weights, ai_piece, human_piece);
        column = -1;
        return;
    end
    
    if isMaximizing
        % Maximizing player (robot/AI)
        best_score = -Inf;
        best_column = valid_moves(1); % Default to first valid move
        
        for i = 1:length(valid_moves)
            col = valid_moves(i);
            % Make the move
            new_board = makeMove(board, col, ai_piece);
            
            % Recursive minimax call
            [~, move_score] = minimax(new_board, depth-1, false);
            
            % Update best score
            if move_score > best_score
                best_score = move_score;
                best_column = col;
            end
        end
        
        column = best_column;
        score = best_score;
    else
        % Minimizing player (human opponent)
        best_score = Inf;
        best_column = valid_moves(1); % Default to first valid move
        
        for i = 1:length(valid_moves)
            col = valid_moves(i);
            % Make the move
            new_board = makeMove(board, col, human_piece);
            
            % Recursive minimax call
            [~, move_score] = minimax(new_board, depth-1, true);
            
            % Update best score
            if move_score < best_score
                best_score = move_score;
                best_column = col;
            end
        end
        
        column = best_column;
        score = best_score;
    end
end

function valid_moves = findValidMoves(board)
    % Find columns that still have empty spaces
    valid_moves = find(board(1, :) == 0);
end

function new_board = makeMove(board, column, piece)
    % Create a copy of the board
    new_board = board;
    
    % Find the lowest empty position in the selected column
    row = find(board(:, column) == 0, 1, 'last');
    if isempty(row)
        return;
    end
    new_board(row, column) = piece;
end

function is_full = isFullBoard(board)
    % Check if the board is full (no empty spaces)
    is_full = ~any(board(:) == 0);
end

function score = evaluateBoard(board, position_weights, ai_piece, human_piece)
    % Evaluate the board position based on position weights, center control,
    % and potential winning connections
    
    % Initialize score
    score = 0;
    
    % Apply position weights for both players
    for row = 1:size(board, 1)
        for col = 1:size(board, 2)
            if board(row, col) == ai_piece
                % Add weight for AI pieces
                score = score + position_weights(row, col);
            elseif board(row, col) == human_piece
                % Subtract weight for opponent pieces
                score = score - position_weights(row, col);
            end
        end
    end
    
    % Add center column bias
    center_col = floor(size(board, 2) / 2) + 1;
    center_array = board(:, center_col);
    center_count = sum(center_array == ai_piece);
    score = score + center_count * 6; % Boost for owning center
    
    % Check horizontal windows
    for row = 1:size(board, 1)
        for col = 1:size(board, 2)-3
            window = board(row, col:col+3);
            score = score + evaluate_window(window, ai_piece, human_piece);
        end
    end
    
    % Check vertical windows
    for col = 1:size(board, 2)
        for row = 1:size(board, 1)-3
            window = board(row:row+3, col);
            score = score + evaluate_window(window, ai_piece, human_piece);
        end
    end
    
    % Check positive diagonal windows (/)
    for row = 4:size(board, 1)
        for col = 1:size(board, 2)-3
            window = [board(row, col), board(row-1, col+1), board(row-2, col+2), board(row-3, col+3)];
            score = score + evaluate_window(window, ai_piece, human_piece);
        end
    end
    
    % Check negative diagonal windows (\)
    for row = 1:size(board, 1)-3
        for col = 1:size(board, 2)-3
            window = [board(row, col), board(row+1, col+1), board(row+2, col+2), board(row+3, col+3)];
            score = score + evaluate_window(window, ai_piece, human_piece);
        end
    end
end

function score = evaluate_window(window, ai_piece, opp_piece)
    % Evaluate a window of 4 positions
    score = 0;

    if sum(window == ai_piece) == 4
        score = score + 100000;
    elseif sum(window == ai_piece) == 3 && sum(window == 0) == 1
        score = score + 100;
    elseif sum(window == ai_piece) == 2 && sum(window == 0) == 2
        score = score + 10;
    end

    if sum(window == opp_piece) == 4
        score = score - 100000;
    elseif sum(window == opp_piece) == 3 && sum(window == 0) == 1
        score = score - 80;
    end
end

function has_won = checkWin(board, piece)
    % Check if the given piece has a winning condition on the board
    
    % Check horizontal
    for row = 1:size(board, 1)
        for col = 1:size(board, 2)-3
            if all(board(row, col:col+3) == piece)
                has_won = true;
                return;
            end
        end
    end
    
    % Check vertical
    for col = 1:size(board, 2)
        for row = 1:size(board, 1)-3
            if all(board(row:row+3, col) == piece)
                has_won = true;
                return;
            end
        end
    end
    
    % Check positive diagonal (/)
    for row = 4:size(board, 1)
        for col = 1:size(board, 2)-3
            if board(row, col) == piece && board(row-1, col+1) == piece && ...
               board(row-2, col+2) == piece && board(row-3, col+3) == piece
                has_won = true;
                return;
            end
        end
    end
    
    % Check negative diagonal (\)
    for row = 1:size(board, 1)-3
        for col = 1:size(board, 2)-3
            if board(row, col) == piece && board(row+1, col+1) == piece && ...
               board(row+2, col+2) == piece && board(row+3, col+3) == piece
                has_won = true;
                return;
            end
        end
    end
    
    has_won = false;
end