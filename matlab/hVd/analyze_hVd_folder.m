% analyze_hVd_folder.m
% [Cmatrices,PcentCor] = analyze_hVd_folder(subjfile)
%
% Purpose: Return vowel confusion matrices for all noise conditions, for
%          all subjects contained in a text file.  The text file is called
%          'all_subjects.txt' generally, though there is nothing special
%          about this name.
%
% Input: subjfile
%
% Output: Cmatrices (cell) (n subjects * 3 noise conditions), PcentCor (double) (n * 3)
%
% Note: 
function [Cmatrices,PcentCor] = analyze_hVd_folder(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[sf] = textread(filename, '%s');
subjects = [sf];
Cmatrices = cell(length(subjects),3);
PcentCor = zeros(length(subjects),3);
all_data = cell(length(subjects)+1,4);
create_headers();


for p = 1:length(subjects)

    [a b c d e f] = read_data_file(subjects{p});

    M = build_data_matrix();
    % M's structure is:
    % trial#, phoneme, response, person speaking, 'correct'/'incorrect', S/N

    [C, cor] = build_confusion_matrices();
    % builds cell array (C) of confusion matrices

    Cmatrices{p,1} = C{1};
    Cmatrices{p,2} = C{2};
    Cmatrices{p,3} = C{3};
    
    PcentCor(p,1) = cor(1);
    PcentCor(p,2) = cor(2);
    PcentCor(p,3) = cor(3);
    
    all_data{1+p,1} = subjects{p};
    all_data{1+p,2} = cor(1);
    all_data{1+p,3} = cor(2);
    all_data{1+p,4} = cor(3);
    
end

output_dest = strcat(curpath, 'hVd_summary_data.xls');
xlswrite(output_dest, all_data);
    

    function [a b c d e f] = read_data_file(subj)
        
        curpath = mfilename('fullpath');
        curmfile = mfilename();
        curpath = curpath(1:(end-length(curmfile)));

        filename = strcat(curpath, 'data\', subj, '.txt');
        [a b c d e f] = textread(filename, '%n %s %s %s %s %n');       
    
    end


    function [M] = build_data_matrix()
            
        % build cell array (M) holding all the pertinent data
        M = cell(length(a),6);

        for i=1:6
            for j=1:length(a)
                if i == 1
                    M{j,i} = a(j);
                elseif i == 2
                    M{j,i} = b{j};
                elseif i == 3
                    M{j,i} = c{j};
                elseif i == 4
                    M{j,i} = d{j};
                elseif i == 5
                    M{j,i} = e{j};
                else  % i == 6
                    M{j,i} = f(j);
                end 
            end
        end
        
        %replace 2nd col with phonemes
        %replace 4th col with person speaking
        phonemes = cell(length(a),1);
        persons = cell(length(a),1);
        for i=1:length(a)
            phonemes{i} = M{i,4}(4:5);
            persons{i} = M{i,4}(1:3);
        end
        for i=1:length(a)
            M{i,2} = phonemes{i};
            M{i,4} = persons{i};
        end
        
    end


    function [C, cor] = build_confusion_matrices()
       
        noise_levels = [1000 5];  % 1000=quiet, 5=noise
        % 5=noise as the original program had +5 SNR, but now it is +7 SNR
        phoneme_labels = {'ae'; 'aw'; 'eh'; 'ei'; 'er'; 'ih'; 'iy'; 'oa'; 'oo'; 'uh'; 'uw'};
        
        % create separate confusion matrices for noise conditions and total
        % order is:    ae aw eh ei er ih iy oa oo uh uw
        C = cell(length(noise_levels)+1,1);
        for i=1:length(C)
           C{i} = zeros(11,11); 
        end
        
        % create % correct matrix
        cor = zeros(length(noise_levels)+1,1);
        
        % will find numeric indices corresponding to all ae, ..., uw
        % i rows: noise level 1, ..., noise level x
        phoneme_indices = cell(length(noise_levels),11);
        for i=1:length(noise_levels)
            for j=1:length(phoneme_indices)
                a = find(strcmp(M(:,2),phoneme_labels(j))==1);
                b = find(cell2mat(M(:,6))==noise_levels(i));
                phoneme_indices{i,j} = intersect(a,b);
            end
        end
        
        % builds confusion matrices for all noise conditions
        for i=1:length(noise_levels)
            for j=1:length(phoneme_labels)
                targ = phoneme_labels{j};
                for k=1:length(phoneme_indices{1,1})
                    resp = M(phoneme_indices{i,j}(k),3);
                    resp_index = find(strcmp(phoneme_labels,resp)==1);
                    C{i}(j,resp_index) = C{i}(j,resp_index)+1;
                end
            end
        end
        
        % builds the total confusion matrix
        C{length(C)} = C{1};
        for i=2:length(C)-1
            C{length(C)} = C{length(C)} + C{i};
        end
        
        % builds %cor matrix
        for i=1:length(cor)
            cor(i) = trace(C{i})/sum(sum(C{i}));
        end
        
    end


    function create_headers()
        all_data{1,1} = 'name';
        all_data{1,2} = 'quiet';
        all_data{1,3} = 'noise';
        all_data{1,4} = 'ovr';
    end
    
end