clc; clear; close all;

%% ============================================================
% SMART-Fuse: Proposed Method Only
% Visual analysis included:
% 1. Source images and fused result
% 2. Weight maps W1 and W2
% 3. Foreground mask M
% 4. Histogram of W1 and W2 inside foreground
% 5. Decision-strength map |W1-W2|
% 6. Dominance map
% 7. ROI-level interpretability visualization
%% ============================================================

%% ===================== LOAD INPUT IMAGES =====================
[file1, path1] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Image Files'}, ...
    'Select Source Image I1');

[file2, path2] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff','Image Files'}, ...
    'Select Source Image I2');

if isequal(file1,0) || isequal(file2,0)
    error('Image selection cancelled.');
end

I1 = im2double(imread(fullfile(path1,file1)));
I2 = im2double(imread(fullfile(path2,file2)));

I1 = imresize(I1,[256 256]);
I2 = imresize(I2,[256 256]);

if size(I1,3)==1
    I1 = repmat(I1,[1 1 3]);
end

if size(I2,3)==1
    I2 = repmat(I2,[1 1 3]);
end

%% ===================== APPLY SMART-Fuse =====================
[Fgray, Fcolor, W1, W2, M] = smartFuse(I1,I2);

W1 = mat2gray(W1);
W2 = mat2gray(W2);
M  = logical(M);

DW = abs(W1 - W2);

%% ===================== DOMINANCE MAP =====================
DominanceMap = zeros(size(W1));

DominanceMap((W1 > W2) & M) = 1;   % I1 dominant
DominanceMap((W2 > W1) & M) = 2;   % I2 dominant

%% ===================== SAVE BASIC OUTPUTS =====================
imwrite(Fcolor,'SMART_Fuse_Output_Color.png');
imwrite(Fgray,'SMART_Fuse_Output_Gray.png');
imwrite(mat2gray(W1),'SMART_Fuse_Weight_Map_W1.png');
imwrite(mat2gray(W2),'SMART_Fuse_Weight_Map_W2.png');
imwrite(M,'SMART_Fuse_Foreground_Mask.png');
imwrite(mat2gray(DW),'SMART_Fuse_Decision_Strength_Map.png');
imwrite(mat2gray(DominanceMap),'SMART_Fuse_Dominance_Map.png');

%% ============================================================
% FIGURE 1: INPUT IMAGES AND SMART-Fuse OUTPUT
%% ============================================================

fig1 = figure('Name','SMART-Fuse Output','Color','w','Units','normalized', ...
    'Position',[0.10 0.25 0.80 0.45]);

subplot(1,3,1);
imshow(I1,[]);
title('Source Image I_1','FontName','Times New Roman','FontWeight','bold');

subplot(1,3,2);
imshow(I2,[]);
title('Source Image I_2','FontName','Times New Roman','FontWeight','bold');

subplot(1,3,3);
imshow(Fcolor,[]);
title('SMART-Fuse Output','FontName','Times New Roman','FontWeight','bold');

exportgraphics(fig1,'Fig_1_SMART_Fuse_Output_1000dpi.png','Resolution',1000);

%% ============================================================
% FIGURE 2: BASIC INTERPRETABILITY VISUALIZATION
%% ============================================================

fig2 = figure('Name','SMART-Fuse Basic Interpretability','Color','w', ...
    'Units','normalized','Position',[0.05 0.30 0.90 0.35]);

subplot(1,4,1);
imshow(Fcolor,[]);
title('SMART-Fuse','FontName','Times New Roman','FontSize',12,'FontWeight','bold');

subplot(1,4,2);
imshow(W1,[]);
title('Weight Map W_1','FontName','Times New Roman','FontSize',12,'FontWeight','bold');

subplot(1,4,3);
imshow(W2,[]);
title('Weight Map W_2','FontName','Times New Roman','FontSize',12,'FontWeight','bold');

subplot(1,4,4);
imshow(M,[]);
title('Foreground Mask M','FontName','Times New Roman','FontSize',12,'FontWeight','bold');

exportgraphics(fig2,'Fig_2_SMART_Fuse_Weight_Maps_Mask_1000dpi.png','Resolution',1000);

%% ============================================================
% FIGURE 3: HISTOGRAM OF W1 AND W2 INSIDE FOREGROUND MASK
%% ============================================================

W1_fg = W1(M);
W2_fg = W2(M);

fig3 = figure('Name','SMART-Fuse Weight Histogram','Color','w', ...
    'Units','normalized','Position',[0.10 0.20 0.75 0.55]);

edges = 0:0.025:1;

histogram(W1_fg,edges,'Normalization','probability', ...
    'FaceAlpha',0.55,'LineWidth',1.2);
hold on;

histogram(W2_fg,edges,'Normalization','probability', ...
    'FaceAlpha',0.55,'LineWidth',1.2);

grid on; box on;
xlabel('Adaptive Weight Value','FontName','Times New Roman','FontSize',13,'FontWeight','bold');
ylabel('Probability','FontName','Times New Roman','FontSize',13,'FontWeight','bold');
title('Histogram-Based Source Contribution Analysis inside Foreground Mask', ...
    'FontName','Times New Roman','FontSize',14,'FontWeight','bold');

legend({'W_1: Contribution of I_1','W_2: Contribution of I_2'}, ...
    'Location','best','FontName','Times New Roman','FontSize',11);

set(gca,'FontName','Times New Roman','FontSize',12,'LineWidth',1.2);

exportgraphics(fig3,'Fig_3_SMART_Fuse_Weight_Histogram_1000dpi.png','Resolution',1000);

%% ============================================================
% FIGURE 4: DECISION-STRENGTH MAP AND DOMINANCE MAP
%% ============================================================

fig4 = figure('Name','SMART-Fuse Decision and Dominance Maps','Color','w', ...
    'Units','normalized','Position',[0.05 0.18 0.90 0.50]);

subplot(1,3,1);
imshow(Fcolor,[]);
title('SMART-Fuse','FontName','Times New Roman','FontSize',12,'FontWeight','bold');

subplot(1,3,2);
imshow(DW,[]);
colormap(gca,'hot');
colorbar;
title('|W_1-W_2| Decision-Strength Map', ...
    'FontName','Times New Roman','FontSize',12,'FontWeight','bold');

subplot(1,3,3);
imagesc(DominanceMap);
axis image off;
colormap(gca,[0.5 0.5 0.5; 0 0.45 1; 1 0.3 0.1]);
caxis([0 2]);
cb = colorbar;
cb.Ticks = [0 1 2];
cb.TickLabels = {'Balanced','I_1 dominant','I_2 dominant'};
title('Dominance Map','FontName','Times New Roman','FontSize',12,'FontWeight','bold');

exportgraphics(fig4,'Fig_4_SMART_Fuse_Decision_Dominance_1000dpi.png','Resolution',1000);

%% ============================================================
% FIGURE 5: ROI-LEVEL INTERPRETABILITY ANALYSIS
%% ============================================================

roi = [90 85 70 70];   % [x y width height]

F_roi  = drawRedRectangle(Fcolor,roi,2);
W1_roi = drawRedRectangle(repmat(W1,[1 1 3]),roi,2);
W2_roi = drawRedRectangle(repmat(W2,[1 1 3]),roi,2);
DW_roi = drawRedRectangle(repmat(DW,[1 1 3]),roi,2);

cropF  = imresize(imcrop(Fcolor,roi),[256 256],'bicubic');
cropW1 = imresize(imcrop(W1,roi),[256 256],'bicubic');
cropW2 = imresize(imcrop(W2,roi),[256 256],'bicubic');
cropDW = imresize(imcrop(DW,roi),[256 256],'bicubic');

fig5 = figure('Name','SMART-Fuse ROI Interpretability','Color','w', ...
    'Units','normalized','Position',[0.02 0.05 0.95 0.75]);

subplot(2,4,1);
imshow(F_roi,[]);
title('SMART-Fuse with ROI','FontName','Times New Roman','FontWeight','bold');

subplot(2,4,2);
imshow(W1_roi,[]);
title('W_1 with ROI','FontName','Times New Roman','FontWeight','bold');

subplot(2,4,3);
imshow(W2_roi,[]);
title('W_2 with ROI','FontName','Times New Roman','FontWeight','bold');

subplot(2,4,4);
imshow(DW_roi,[]);
title('|W_1-W_2| with ROI','FontName','Times New Roman','FontWeight','bold');

subplot(2,4,5);
imshow(drawRedRectangle(cropF,[2 2 252 252],4),[]);
title('ROI: SMART-Fuse','FontName','Times New Roman','FontWeight','bold');

subplot(2,4,6);
imshow(drawRedRectangle(repmat(cropW1,[1 1 3]),[2 2 252 252],4),[]);
title('ROI: W_1','FontName','Times New Roman','FontWeight','bold');

subplot(2,4,7);
imshow(drawRedRectangle(repmat(cropW2,[1 1 3]),[2 2 252 252],4),[]);
title('ROI: W_2','FontName','Times New Roman','FontWeight','bold');

subplot(2,4,8);
imshow(drawRedRectangle(repmat(cropDW,[1 1 3]),[2 2 252 252],4),[]);
title('ROI: |W_1-W_2|','FontName','Times New Roman','FontWeight','bold');

exportgraphics(fig5,'Fig_5_SMART_Fuse_ROI_Interpretability_1000dpi.png','Resolution',1000);

%% ============================================================
% FIGURE 6: COMPLETE INTERPRETABILITY PANEL
%% ============================================================

fig6 = figure('Name','SMART-Fuse Complete Interpretability Panel','Color','w', ...
    'Units','normalized','Position',[0.02 0.02 0.96 0.90]);

subplot(3,4,1);
imshow(Fcolor,[]);
title('(a) SMART-Fuse','FontWeight','bold');

subplot(3,4,2);
imshow(W1,[]);
title('W_1','FontWeight','bold');

subplot(3,4,3);
imshow(W2,[]);
title('W_2','FontWeight','bold');

subplot(3,4,4);
imshow(M,[]);
title('M','FontWeight','bold');

subplot(3,4,5:6);
histogram(W1_fg,edges,'Normalization','probability','FaceAlpha',0.55,'LineWidth',1.1);
hold on;
histogram(W2_fg,edges,'Normalization','probability','FaceAlpha',0.55,'LineWidth',1.1);
grid on; box on;
xlabel('Weight Value');
ylabel('Probability');
title('(b) Histogram of W_1 and W_2 inside M','FontWeight','bold');
legend({'W_1','W_2'},'Location','best');

subplot(3,4,7);
imshow(DW,[]);
colormap(gca,'hot');
colorbar;
title('(c) |W_1-W_2|','FontWeight','bold');

subplot(3,4,8);
imagesc(DominanceMap);
axis image off;
colormap(gca,[0.5 0.5 0.5; 0 0.45 1; 1 0.3 0.1]);
caxis([0 2]);
title('Dominance Map','FontWeight','bold');

subplot(3,4,9);
imshow(cropF,[]);
title('(d) ROI: Fused','FontWeight','bold');

subplot(3,4,10);
imshow(cropW1,[]);
title('ROI: W_1','FontWeight','bold');

subplot(3,4,11);
imshow(cropW2,[]);
title('ROI: W_2','FontWeight','bold');

subplot(3,4,12);
imshow(cropDW,[]);
title('ROI: |W_1-W_2|','FontWeight','bold');

sgtitle('SMART-Fuse Interpretability Analysis Using Adaptive Weight Maps and Foreground Mask', ...
    'FontName','Times New Roman','FontSize',15,'FontWeight','bold');

exportgraphics(fig6,'Fig_6_SMART_Fuse_Complete_Interpretability_1000dpi.png','Resolution',1000);

disp('SMART-Fuse proposed-method visual analysis completed successfully.');
disp('All output figures and maps have been saved.');

%% =================================================================
%% ======================= FUNCTIONS BELOW ==========================
%% =================================================================

function [Fgray, Fcolor, W1, W2, M] = smartFuse(I1,I2)

    G1 = rgb2gray(I1);
    G2 = rgb2gray(I2);

    M = makeMask(max(G1,G2));

    S1 = semanticActivityMap(G1,M);
    S2 = semanticActivityMap(G2,M);

    W1 = exp(S1);
    W2 = exp(S2);

    S = W1 + W2 + eps;
    W1 = W1 ./ S;
    W2 = W2 ./ S;

    W1(~M) = 0.5;
    W2(~M) = 0.5;

    W1 = min(max(W1,0),1);
    W2 = 1 - W1;

    YCC1 = rgb2ycbcr(I1);
    YCC2 = rgb2ycbcr(I2);

    Y1 = im2double(YCC1(:,:,1));
    Y2 = im2double(YCC2(:,:,1));

    B1 = rollingGuidanceApprox(Y1);
    B2 = rollingGuidanceApprox(Y2);

    D1 = Y1 - B1;
    D2 = Y2 - B2;

    BF = W1 .* B1 + W2 .* B2;
    DF = detailFusion(D1,D2,W1,W2,M);

    YF = BF + DF;
    YF = mat2gray(YF);
    YF = imadjust(YF);

    if colorfulnessMetric(I2) >= colorfulnessMetric(I1)
        YCCF = rgb2ycbcr(I2);
    else
        YCCF = rgb2ycbcr(I1);
    end

    YCCF(:,:,1) = YF;

    Fcolor = ycbcr2rgb(YCCF);
    Fcolor = min(max(Fcolor,0),1);

    for c = 1:3
        temp = Fcolor(:,:,c);
        temp(~M) = 0;
        Fcolor(:,:,c) = temp;
    end

    Fgray = mat2gray(YF);
end

function M = makeMask(G)

    G = mat2gray(G);

    t = graythresh(G);
    M = G > max(0.03,0.6*t);

    M = imfill(M,'holes');
    M = bwareaopen(M,200);
    M = imclose(M,strel('disk',4));
    M = imgaussfilt(double(M),1) > 0.5;
end

function S = semanticActivityMap(I,M)

    I = mat2gray(I);

    E = mat2gray(imgradient(I));

    h = fspecial('average',7);
    localMean = imfilter(I,h,'replicate');
    localVar  = imfilter(I.^2,h,'replicate') - localMean.^2;
    localVar  = mat2gray(localVar);

    L = abs(imfilter(I,fspecial('laplacian',0.2),'replicate'));
    L = mat2gray(L);

    R = entropyfilt(I,true(5));
    R = mat2gray(R);

    S = E + localVar + L + R;
    S(~M) = 0;

    S = imgaussfilt(S,2);
    S = mat2gray(S);
end

function B = rollingGuidanceApprox(I)

    I = im2double(I);

    B = imgaussfilt(I,1);

    for k = 1:4
        B = imguidedfilter(I,B);
    end
end

function DF = detailFusion(D1,D2,W1,W2,M)

    A1 = imgaussfilt(abs(D1),1);
    A2 = imgaussfilt(abs(D2),1);

    G1 = mat2gray(imgradient(D1));
    G2 = mat2gray(imgradient(D2));

    P1 = A1 .* W1 + G1;
    P2 = A2 .* W2 + G2;

    H = P1 >= P2;

    DH = H .* D1 + (~H) .* D2;
    DS = W1 .* D1 + W2 .* D2;

    DF = 0.5 * DH + 0.5 * DS;
    DF = imgaussfilt(DF,0.3);
    DF(~M) = 0;
end

function c = colorfulnessMetric(I)

    I = im2double(I);

    if size(I,3)==1
        I = repmat(I,[1 1 3]);
    end

    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);

    rg = R - G;
    yb = 0.5*(R + G) - B;

    c = std(rg(:)) + std(yb(:)) + 0.3*(mean(abs(rg(:))) + mean(abs(yb(:))));
end

function Iout = drawRedRectangle(I,roi,lineWidth)

    Iout = im2double(I);

    if size(Iout,3)==1
        Iout = repmat(Iout,[1 1 3]);
    end

    x = round(roi(1));
    y = round(roi(2));
    w = round(roi(3));
    h = round(roi(4));

    [H,W,~] = size(Iout);

    x1 = max(1,x);
    y1 = max(1,y);
    x2 = min(W,x+w);
    y2 = min(H,y+h);

    for k = 0:lineWidth-1

        yy1 = min(H,y1+k);
        yy2 = max(1,y2-k);
        xx1 = min(W,x1+k);
        xx2 = max(1,x2-k);

        Iout(yy1,xx1:xx2,1) = 1;
        Iout(yy1,xx1:xx2,2) = 0;
        Iout(yy1,xx1:xx2,3) = 0;

        Iout(yy2,xx1:xx2,1) = 1;
        Iout(yy2,xx1:xx2,2) = 0;
        Iout(yy2,xx1:xx2,3) = 0;

        Iout(yy1:yy2,xx1,1) = 1;
        Iout(yy1:yy2,xx1,2) = 0;
        Iout(yy1:yy2,xx1,3) = 0;

        Iout(yy1:yy2,xx2,1) = 1;
        Iout(yy1:yy2,xx2,2) = 0;
        Iout(yy1:yy2,xx2,3) = 0;
    end
end