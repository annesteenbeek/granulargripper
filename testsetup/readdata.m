% postprocess all the test data
clc
close all
load('testdata.mat');

minvolt = 0;
calvolt = 650;
calforce = 2*9.81;
calfac = calforce/calvolt;

grainsizes = {testdata.Grainsize};
rows = length(grainsizes);
for i = 1:rows % loop for all the grainsizes
 
    for j = 1:length(testdata(i).tests) % loop for all the different tests
        
        [strain, I] = max(testdata(i).tests(j).data.Strain*calfac);
        pullpressure(i,j) = testdata(i).tests(j).data.Pressure(I);
        allstrains(i, j) = strain;


    end
    

end


[allstrainssort sortindex] = sort(allstrains,2); % sort all the peak strains from the tests
for i = 1:size(pullpressure,1)
    PullPressure(i,:) = pullpressure(i,sortindex(i,2:9));
end
MinStrain = min(allstrainssort(:,2:9),[],2); % find smallest strain, leave out first lowest
MaxStrain = max(allstrainssort(:,2:9),[],2); % find maximum strain, leave out first highest
MeanStrain = mean(allstrainssort(:,2:9),2); % find mean strain, leave out first highest and lowest
MeanPressure = mean(PullPressure,2); % find mean pressure leaving out pressure from highest and lowest strain
StandardDeviationStrain = std(allstrainssort,0,2);
StandardDeviationPressure = std(PullPressure,0,2);
resultdata = table(MeanStrain,MeanPressure,StandardDeviationStrain, MinStrain,MaxStrain,allstrains, 'RowNames', grainsizes)

% writetable(resultdata, 'testresults.xlsx');

%% plot result data
figure
bar([MeanStrain, MeanPressure-50], 'grouped');
hold on
errorbar(0.85:1:(rows-0.15), MeanStrain, StandardDeviationStrain, 'rx', 'LineWidth', 2, 'MarkerSize', 0.1)
hold on
errorbar(1.15:1:(rows+0.15), MeanPressure-50, StandardDeviationPressure, 'kx', 'LineWidth', 2, 'MarkerSize', 0.1);
set(gca,'XTickLabel', grainsizes);
ylabel('Peak holding force [N]')
set(gca,'Box','off');   %# Turn off the box surrounding the whole axes
axesPosition = get(gca,'Position');          %# Get the current axes position
hNewAxes = axes('Position',axesPosition,...  %# Place a new axes on top...
                'Color','none',...           %#   ... with no background color
                'YLim',[50 75],...            %#   ... and a different scale
                'YAxisLocation','right',...  %#   ... located on the right
                'XTick',[],...               %#   ... with no x tick marks
                'FontSize', 14,...           % # .. font size
                'FontWeight', 'bold',...
                'Box','off');                %#   ... and no surrounding box
ylabel(hNewAxes,'Pressure [Kpa]');  %# Add a label to the right y axis

legend('Peak holding Force', 'Pressure at release');


title('Peak holding force for different materials')




