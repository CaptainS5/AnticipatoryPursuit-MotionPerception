% scatter plots for all kinds of comparisons...
initializeParas;
probCon{1} = [50 70 90];
probCon{2} = [50 90];

% load data
cd(RFolder)
cd('Exp1')
aspData{1} = readtable(['dataAPvelX_exp1.csv']);
pseData{1} = readtable(['dataPercept_exp1.csv']);
cd ..
aspData{2} = readtable(['aspVel_exp1vs2.csv']);
pseData{2} = readtable(['PSE_exp1vs2.csv']);
aspData{3} = readtable(['aspVel_exp1vs3.csv']);
pseData{3} = readtable(['PSE_exp1vs3.csv']);
cd(analysisFolder)

%% correlation of asp and PSE
% for experiment 1
% fit linear mixed-effects model
% sort data into a table
correlationData = table();
count = 1;
for subN = 1:10
    for probN = 2:3
        correlationData.sub(count, 1) = subN;
        correlationData.prob(count, 1) = probCon{1}(probN);
        
        idxB = find(aspData{1}.sub==subN & aspData{1}.prob==probCon{1}(1));
        idxT = find(aspData{1}.sub==subN & aspData{1}.prob==probCon{1}(probN));
        correlationData.asp(count, 1) = aspData{1}.measure(idxT, 1)-aspData{1}.measure(idxB, 1);
        
        idxB = find(pseData{1}.sub==subN & pseData{1}.prob==probCon{1}(1));
        idxT = find(pseData{1}.sub==subN & pseData{1}.prob==probCon{1}(probN));
        correlationData.PSE(count, 1) = pseData{1}.PSE(idxT, 1)-pseData{1}.PSE(idxB, 1);
        count = count+1;
    end
end

% save in csv for analysis in R
cd(RFolder)
writetable(correlationData, ['eyeVSperceptDiff_exp1.csv'])

% % reorganize the data for plotting
% for subN = 1:10
%     for probN = 1:3
%         idxT = find(aspData{1}.sub==subN & aspData{1}.prob==probCon{1}(probN));
%         aspPlot(subN, probN) = aspData{1}.measure(idxT, 1);
%         
%         idxT = find(pseData{1}.sub==subN & pseData{1}.prob==probCon{1}(probN));
%         psePlot(subN, probN) = pseData{1}.PSE(idxT, 1);
%     end
% end
% 
% % figure
% % hold on
% % for subN = 1:10
% %     fS{subN, 1} = plot(psePlot(subN, 1), aspPlot(subN, 1), '.', 'color', markerC(subN, :), 'markerSize', 25);
% %     fS{subN, 2} = plot(psePlot(subN, 2), aspPlot(subN, 2), 'p', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 10);
% %     fS{subN, 3} = plot(psePlot(subN, 3), aspPlot(subN, 3), '^', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
% % end
% % axis square
% % xlabel('PSE')
% % ylabel('Anticipatory pursuit velocity (deg/s)')
% % legend([fS{3, :}], {'50%', '70%', '90%'}, 'box', 'off', 'location', 'northwest')
% % % ah1=axes('position',get(gca,'position'), 'visible', 'off');
% % % legend(ah1, [fS{:, 1}], nameSets{1}, 'box', 'off', 'location', 'northeast')
% % cd(correlationFolder)
% % saveas(gcf, ['PSEvsASP_exp1_all.pdf'])
% 
% figure
% hold on
% for subN = 1:10
%     fS{subN, 1} = plot(psePlot(subN, 2)-psePlot(subN, 1), aspPlot(subN, 2)-aspPlot(subN, 1), 's', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
%     fS{subN, 2} = plot(psePlot(subN, 3)-psePlot(subN, 1), aspPlot(subN, 3)-aspPlot(subN, 1), '.', 'color', markerC(subN, :), 'markerSize', 25);
% end
% axis square
% xlabel('PSE bias')
% ylabel('Anticipatory pursuit velocity difference (deg/s)')
% legend([fS{3, :}], {'exp1-70%', 'exp1-90%'}, 'box', 'off', 'location', 'northwest')
% % ah1=axes('position',get(gca,'position'), 'visible', 'off');
% % legend(ah1, [fS{:, 1}], nameSets{1}, 'box', 'off', 'location', 'northeast')
% cd(correlationFolder)
% saveas(gcf, ['PSEvsASP_diff_exp1_all.pdf'])
%%
% clear aspPlot psePlot
% % experiment 1 & 3
% for subN = 1:9
%     for expN  =1:2
%         if expN==1
%             exp=1;
%         else
%             exp=3;
%         end
%         for probN = 1:2
%             idxT = find(aspData{3}.sub==subN & aspData{3}.prob==probCon{2}(probN) & aspData{3}.exp==exp);
%             aspPlot(subN, 2*(expN-1)+probN) = aspData{3}.measure(idxT, 1);
%             
%             idxT = find(pseData{3}.sub==subN & pseData{3}.prob==probCon{2}(probN) & pseData{3}.exp==exp);
%             psePlot(subN, 2*(expN-1)+probN) = pseData{3}.PSE(idxT, 1);
%         end
%     end
% end
% 
% % figure
% % hold on
% % for subN = 1:9
% %     fS{subN, 1} = plot(psePlot(subN, 1), aspPlot(subN, 1), '.', 'color', markerC(subN, :), 'markerSize', 25);
% %     fS{subN, 2} = plot(psePlot(subN, 2), aspPlot(subN, 2), '^', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
% %     fS{subN, 3} = plot(psePlot(subN, 3), aspPlot(subN, 3), 'd', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
% %     fS{subN, 4} = plot(psePlot(subN, 4), aspPlot(subN, 4), 's', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 8);
% % end
% % axis square
% % xlabel('PSE')
% % ylabel('Anticipatory pursuit velocity (deg/s)')
% % legend([fS{3, :}], probNames12{2}, 'box', 'off', 'location', 'northwest')
% % % ah1=axes('position',get(gca,'position'), 'visible', 'off');
% % % legend(ah1, [fS{:, 1}], names2, 'box', 'off', 'location', 'northeast')
% % cd(correlationFolder)
% % saveas(gcf, ['PSEvsASP_exp1vs3_all.pdf'])
% 
% figure
% hold on
% for subN = 1:9
%     fS{subN, 1} = plot(psePlot(subN, 2)-psePlot(subN, 1), aspPlot(subN, 2)-aspPlot(subN, 1), '.', 'color', markerC(subN, :), 'markerSize', 25);
%     fS{subN, 2} = plot(psePlot(subN, 4)-psePlot(subN, 3), aspPlot(subN, 4)-aspPlot(subN, 3), 'p', 'MarkerFaceColor', markerC(subN, :), 'MarkerEdgeColor', 'none', 'markerSize', 10);
% end
% axis square
% xlabel('PSE bias')
% ylabel('Anticipatory pursuit velocity difference (deg/s)')
% legend([fS{3, :}], {'exp1-90%', 'exp3-90%'}, 'box', 'off', 'location', 'northwest')
% % ah1=axes('position',get(gca,'position'), 'visible', 'off');
% % legend(ah1, [fS{:, 1}], names2, 'box', 'off', 'location', 'northeast')
% cd(correlationFolder)
% saveas(gcf, ['PSEvsASP_diff_exp1vs3_all.pdf'])

%% correlation of steady-state pursuit and PSE... discuss

