clc
clear
%directed
%% making a graph
N = 10; %number of nodes

%tree
T = zeros(N); %Adjacency matrix
Tl = zeros(N); %Laplacian matrix
for i = 1:N/2
    for j = 0:1
        if (2*i + j <= N)
            T(i, 2*i + j) = 1;
            T(2*i + j, i) = 1;
            Tl(i, 2*i + j) = 1;
            Tl(2*i + j, i) = 1;
        end
    end
end
for i = 1:N
    for j = 1:N
        if(i ~= j)
            Tl(i, i) = Tl(i, i) - Tl(i, j);
        end
    end
end

%cycle
C = zeros(N); %Adjacency matrix
Cl = zeros(N); %Laplacian matrix
for i = 1:N
    if (i == N)
        C(i, 1) = 1;
        C(1, i) = 1;
        Cl(i, 1) = 1;
        Cl(1, i) = 1;
    else
        C(i, i + 1) = 1;
        C(i + 1, i) = 1;
        Cl(i, i + 1) = 1;
        Cl(i + 1, i) = 1;
    end
end
for i = 1:N
    for j = 1:N
        if(i ~= j)
            Cl(i, i) = Cl(i, i) - Cl(i, j);
        end
    end
end

%random connected graph
P = 0.2; %probability of having an edge ~ sparsity of edges

C2 = zeros(N); %Adjacency matrix
C2l = zeros(N); %Laplacian matrix
for i = 1:N
    if (i == N)
        C2(i, 1) = 1;
        C2(1, i) = 1;
        C2l(i, 1) = 1;
        C2l(1, i) = 1;
    else
        C2(i, i + 1) = 1;
        C2(i + 1, i) = 1;
        C2l(i, i + 1) = 1;
        C2l(i + 1, i) = 1;
    end
end
for i = 1:N
    for j = 1:N
        if(i ~= j)
            C2l(i, i) = C2l(i, i) - C2l(i, j);
        end
    end
end

%random graph
P = 0.2; %probability of having an edge ~ sparsity of edges

A = zeros(N, N); %Adjacency matrix
L = zeros(N); %Laplacian matrix
Ls = zeros(N); %Laplacian matrix
kk = 0;
names = (1:N)'; %node indices
for i = 1:N
    for j = 1:N
        if (rand < P)
            if(i ~= j)
                if(rand < 0.2)
                    k = 1;
                elseif (rand <0.4)
                    k = 2;
                elseif (rand < 0.6)
                    k = 3;
                elseif (rand < 0.8)
                    k = 4;
                else
                    k = 5;
                end
                %k = 1;
                A(i,j) = k;
                A(j,i) = k;
                L(i,j) = k;
                L(j,i) = k;
                Ls(i, j) = k;
                Ls(j, i) = k;
            end
        end
    end
end
for i = 1:N
    for j = 1:N
        if (i ~= j)
            L(i, i) = L(i, i) - L(i, j);
            Ls(i, i) = Ls(i, i) - Ls(i, j);
        end
    end
end

%% applying shift
Shift = L; %can be from the following: T, Tl, C, Cl, C2, C2l, A, L.
m = N; %number of maximum shifts
k = 3; %number of given snapshots
q = 0.2; %sparcity of sources

S = zeros(N, m); %signals over time
while(max(S(:, 1)) == 0)
    for i = 1:N
        if (rand < q)
            S(i, 1) = 1; %initial signal
        end
    end
end
for i = 2:m
    S(:, i) = Shift*S(:, i - 1);
end

%choosing k random snapshots from all of the possible ones
x1 = S(:, 5); %snapshot 1
x2 = S(:, 8); %snapshot 2
x3 = S(:, 9); %snapshot 3
X = [x1'; x2'; x3'];
%% cvx programming 1
%learning the graph
a = 0;
cvx_setup;
O = ones(1,N);
[a,b] = size(X);

cvx_begin
variable M(N, N) semidefinite
variable cntrl
    minimize((x3'*M*x3)+ trace(O*M*O'))
    trace(M) < 0;
cvx_end

M
Shift
%% cvx programming 2
full(M)
%finding the initial signal
% is_laplacian = 0;
% for i = 1:N
%     if (Shift(i, i) ~= 0)
%         is_laplacian = 1;
%     end
% end
% if (is_laplacian ~= 1)
%     for i = 1:N
%         M(i, i) = 0;
%     end
% end
% 
% x0 = ones(N,1);
% temp = 10^8;
% aaa = 0;
% 
% M_i = Shift;
% for i = 1:m - 2
%     for ii = i:m - 1
%         for iii = ii:m
%             M_1 = M_i^i;
%             M_2 = M_i^ii;
%             M_3 = M_i^iii;
%             cvx_begin
%             One = ones(N,1);
%             variable x_initial(N)
%                 minimize (norm(x1 - (M_1 * x_initial)) + ...
%                     norm(x2 - (M_2 * x_initial)) + norm(x3 - (M_3 * x_initial)))
%                 x_initial >= 0
%                 abs(One'*x_initial) <= 4.5
%             cvx_end
%             aaa = (norm(x1 - (M_1 * x_initial)) + ...
%                     norm(x2 - (M_2 * x_initial)) + norm(x3 - (M_3 * x_initial)));
%             if (aaa <= temp)
%                 temp = aaa;
%                 x0 = x_initial;
%             end
%         end
%     end
% end
% x0
% temp
%% test
notempty = zeros((N^2)/2,2);
k = 0;
tLs = Ls;
for i = 1:N
    for j = i:N
        if (Ls(i, j) ~= 0 && i ~= j)
            k = k+1;
            notempty(k, 1) = i;
            notempty(k, 2) = j;
        end
    end
end

Big_matrix = zeros(k, 3, N, N);
Big_matrix(1,1,:,:) = makezero(tLs, notempty(1,1), notempty(1,2), N);
Big_matrix(1,2,:,:) = makezero(tLs, notempty(1,2), notempty(1,1), N);
Big_matrix(1,3,:,:) = tLs;
for i = 2:k
    c1 = abs(ones(1,N)*abs(x2 - (makezero(Big_matrix(i-1,1,:,:), notempty(i,1), notempty(i,2), N)^3)*x1));
    c2 = abs(ones(1,N)*abs(x2 - (makezero(Big_matrix(i-1,2,:,:), notempty(i,1), notempty(i,2), N)^3)*x1));
    c3 = abs(ones(1,N)*abs(x2 - (makezero(Big_matrix(i-1,3,:,:), notempty(i,1), notempty(i,2), N)^3)*x1));
    c4 = abs(ones(1,N)*abs(x2 - (makezero(Big_matrix(i-1,1,:,:), notempty(i,2), notempty(i,1), N)^3)*x1));
    c5 = abs(ones(1,N)*abs(x2 - (makezero(Big_matrix(i-1,2,:,:), notempty(i,2), notempty(i,1), N)^3)*x1));
    c6 = abs(ones(1,N)*abs(x2 - (makezero(Big_matrix(i-1,3,:,:), notempty(i,2), notempty(i,1), N)^3)*x1));
    c7 = abs(ones(1,N)*abs(x2 - (reshape(Big_matrix(i-1,1,:,:),[N, N])^3)*x1));
    c8 = abs(ones(1,N)*abs(x2 - (reshape(Big_matrix(i-1,2,:,:),[N, N])^3)*x1));
    c9 = abs(ones(1,N)*abs(x2 - (reshape(Big_matrix(i-1,3,:,:),[N, N])^3)*x1));
    
    if c1 < c2 && c1 < c3
        Big_matrix(i, 1, :, :) = makezero(Big_matrix(i-1,1,:,:), notempty(i,1), notempty(i,2), N);
    elseif c2 < c1 && c2 < c3 
        Big_matrix(i, 1, :, :) = makezero(Big_matrix(i-1,2,:,:), notempty(i,1), notempty(i,2), N);
    else
        Big_matrix(i, 1, :, :) = makezero(Big_matrix(i-1,3,:,:), notempty(i,1), notempty(i,2), N);
    end
    
    if c4 < c5 && c4 < c6
        Big_matrix(i, 2, :, :) = makezero(Big_matrix(i-1,1,:,:), notempty(i,2), notempty(i,1), N);
    elseif c5 < c4 && c5 < c6 
        Big_matrix(i, 2, :, :) = makezero(Big_matrix(i-1,2,:,:), notempty(i,2), notempty(i,1), N);
    else
        Big_matrix(i, 2, :, :) = makezero(Big_matrix(i-1,3,:,:), notempty(i,2), notempty(i,1), N);
    end
    
    if c7 < c8 && c7 < c9
        Big_matrix(i, 3, :, :) = Big_matrix(i-1,1,:,:);
    elseif c8 < c7 && c8 < c9 
        Big_matrix(i, 3, :, :) = Big_matrix(i-1,2,:,:);
    else
        Big_matrix(i, 3, :, :) = Big_matrix(i-1,3,:,:);
    end
end

c1 = abs(ones(1,N)*abs(x2 - (reshape(Big_matrix(k,1,:,:),[N, N])^3)*x1));
c2 = abs(ones(1,N)*abs(x2 - (reshape(Big_matrix(k,2,:,:),[N, N])^3)*x1));
c3 = abs(ones(1,N)*abs(x2 - (reshape(Big_matrix(k,3,:,:),[N, N])^3)*x1));
if c1 < c2 && c1 < c3
    tLs = reshape(Big_matrix(k,1,:,:),[N, N]);
elseif c2 < c1 && c2 < c3 
    tLs = reshape(Big_matrix(k,2,:,:),[N, N]);
else
    tLs = reshape(Big_matrix(k,3,:,:),[N, N]);
end
    
Ls
tLs
L

diff = 0;
same = 0;
for i = 1:N
    for j = 1:N
        if (i~=j && tLs(i,j)~= L(i,j))
            diff = diff+1;
        end
        if (i~=j && tLs(i,j)~=0 && tLs(i,j)== L(i,j))
            same = same+1;
        end
    end
end
diff
same

function M = makezero(L, a, b, N)
    M = reshape(L,[N, N]);
    M(a, b) = 0;
    M(a,a) = M(a,a) + 1;
end