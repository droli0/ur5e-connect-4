function [x, y] = getCoordinate(index, numRows, numCols, deltaRows, deltaCols, row0, col0)
    % Calculate row and column based on the index
    row = floor(index / numRows)
    col = mod(index, numRows)

    % Calculate x and y coordinates
    y = col * deltaCols + col0;
    x = row * deltaRows + row0;
end