function M = jh_typeCastMatrix(M, type)

currentShape = num2cell(size(M));
M = reshape( typecast(M(:), type), [], currentShape{2:end} );

end