% debug RDK
% draw RDK based on the matrices saved
figure
for ii = 1:size(dots.position, 2)
    plot(dots.position{ii}(:, 1), dots.position{ii}(:, 2), 'o')
    axis([-400 400 -400 400])
    pause
end