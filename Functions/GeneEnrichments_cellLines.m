function [enrichment_table] = GeneEnrichments(GeneList,CellLine,inputmodel)
% Select only CRC cell lines
load sample_info.mat
load binaryDepScores_broad_database.mat

rownames = binaryDepScores_broad_database.Gene;
crc = sampleinfo((find(contains(sampleinfo.lineage,'colorectal'))),:);

crc_binaryDepScores = [];
binaryDepScores = [];
for x = 2:size(binaryDepScores_broad_database.Properties.VariableNames,2)
    if ismember((erase(binaryDepScores_broad_database.Properties.VariableNames(x),'ACH')),convertStringsToChars(erase(crc.DepMap_ID,'ACH-')))
        loc = find(ismember(convertStringsToChars(erase(crc.DepMap_ID,'ACH-')),(erase(binaryDepScores_broad_database.Properties.VariableNames(x),'ACH'))));
        crc_binaryDepScores = [crc_binaryDepScores,crc.CCLE_Name(loc)];
        binaryDepScores = [binaryDepScores,binaryDepScores_broad_database(:,x)];
    end
end
binaryDepScores.Properties.VariableNames = crc_binaryDepScores;
binaryDepScores.Properties.RowNames = binaryDepScores_broad_database.Gene;

% for all possible genes in Recon
if strcmp(inputmodel,'Recon')
    load('recon_genes.mat')
    GeneList_all = unique(recon_genes.SYMBOL); %
elseif strcmp(inputmodel,'iHsa')
    load ('dico_iHsa.mat')
    GeneList_all = unique(iHsa_genes.SYMBOL); % 
elseif strcmp(inputmodel,'Recon3D')
    load('dico_recon3D.mat')
    GeneList_all = unique(recon3D_genes.SYMBOL); 
elseif strcmp(inputmodel,'Human1')
    load('dico_Human1.mat')
    GeneList_all = unique(human1_genes.SYMBOL);
elseif strcmp(inputmodel,'HMR')
    load('dico_hmr.mat')
    GeneList_all = unique(hmr_genes.SYMBOL);
end
M = numel(GeneList_all);
enrichment_table = [];
for z = 1:size(CellLine,1)
    if any((ismember(binaryDepScores.Properties.VariableNames,CellLine(z)))==1)
        cell_line = find(ismember(binaryDepScores.Properties.VariableNames,CellLine(z)));

        % for GeneList
        % GeneList = GeneList_all(randi([1 1175],1,50)); %for testing

        N = numel(GeneList{z});

        % We want to check if our predicted essential genes (GeneList) the cell
        % line under study (CellLine)
        cancer_genes = binaryDepScores.Properties.RowNames(find(binaryDepScores{:,cell_line}==1));
        all_genes = lower(cancer_genes);

        K=[];
        x=[];    
        K = [K;sum(ismember(lower(GeneList_all), all_genes))];
        x = [x;sum(ismember(lower(GeneList{z}), all_genes))];


        enrichment = table(binaryDepScores.Properties.VariableNames(cell_line),num2cell(1-hygecdf(x-1,M,K,N)),num2cell(M),num2cell(K),num2cell(N),num2cell(x),...
            'VariableNames',{'Cell_Line','enrichment','Metabolic_genes','Metabolic_cancer_genes','Predicted_EG','Known_EG'});
        enrichment_table = vertcat(enrichment_table,enrichment);

    end
end
end
