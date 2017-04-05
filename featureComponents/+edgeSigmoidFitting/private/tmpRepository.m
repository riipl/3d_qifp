%     figure
%     t = trisurf(faces,verts(:,1),verts(:,2),verts(:,3), ...
%          'FaceColor', 'cyan', 'faceAlpha', 0.8);
%     axis equal;
%      hold on;
%      quiver3(centers(:,1),centers(:,2),centers(:,3), ...
%       -normals(:,1),-normals(:,2),-normals(:,3),0.8, 'color','r');
%      hold off;

% 
%         if (mod(i, 50) == 1) 
%              aaa = aaa + 1;
%              subplot(6,4,aaa); plot(pixelValues, 'r*'); hold on; 
%              plot(1:0.1:21, f(fitSigmoid(pixelValues), 1:0.1:21));
%              title(['T:' num2str(rad2deg(theta)) ' R:' num2str(rad2deg(rho)), ' SF:', num2str(scale_factor)])
%              axis([0, 21, -900, 400]);
%          end
        