function PerformANSYS_NonlinearLocalBuckling((blade, config, iLoad, fid, ansysFilename, ii, jj)
%UNSUPPORTED AT THIS TIME 
%                 filename=strcat(ansysFilename,'-',int2str(ii),'-',int2str(jj)); %The name of the next job name
%                 %%%%%%%        Generate Wrinkling Files        %%%%%%%%%%%%%
%                 script_name=strcat('commands4-',int2str(ii),'.mac');
%                 script_out=strcat('output4-',int2str(ii),'-',int2str(jj),'.txt');
% 
%                 fid=fopen(script_name,'w+');
%                 fprintf(fid,strcat('!************   MODE-%i   ************\n'),ii);
%                 fprintf(fid,'/FILNAME,''%s'',1\n',filename);   %From master, change the jobname
%                 fprintf(fid,'resume\n');
%                 fprintf(fid,'/POST1\n');
%                 fprintf(fid,'SET,LAST\n'); 
% 
%                 [app,SkinAreas,compsInModel]=writeANSYSgetFaceStresses(blade,fid,config.ansys.analysisFlags.localBuckling);
% 
%                 fprintf(fid,'/EXIT,NOSAVE\n');
%                 fclose(fid);
% 
%                 ansys_call = sprintf('SET KMP_STACKSIZE=2048k & "%s" -b -p %s -I %s -o %s -np %s',settings.ansys_path,settings.ansys_product,script_name,script_out,int2str(np))    % KMP_STACKSIZE is 512k by default. This is not enough therefore SET
%                 % KMP_STACKSIZE=2048k has been specifed. 2048k may not be enough for other
%                 % simulations. EC
%                 % 
% 
% 
%                 system(ansys_call)  % the windows system call to run the above ansys command
%                 fprintf('%s: Nonlinear Mode-%s Analysis Finished\n',datestr(now),int2str(ii))
end