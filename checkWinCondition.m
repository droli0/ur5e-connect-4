function winner = checkWinCondition(board)
    winner = 0;
    [rows, cols] = size(board);
    
    % Directions: [row_delta, col_delta]
    directions = [0 1; 1 0; 1 1; -1 1]; % horizontal, vertical, diag down, diag up

    for r = 1:rows
        for c = 1:cols
            player = board(r, c);
            if player == 0
                continue
            end
            for d = 1:size(directions,1)
                dr = directions(d,1);
                dc = directions(d,2);
                count = 1;
                for k = 1:3
                    rr = r + k*dr;
                    cc = c + k*dc;
                    if rr >= 1 && rr <= rows && cc >= 1 && cc <= cols && board(rr,cc) == player
                        count = count + 1;
                    else
                        break
                    end
                end
                if count == 4
                    winner = player;
                    return
                end
            end
        end
    end
end
