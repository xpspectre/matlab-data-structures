clear; close all; clc
rng('default');

% Note: this is pretty slow
% TODO: check tree properties; actual tests
t = RedBlackTree;
n = 100;
vals = rand(n,1);
for in = 1:n
    t.insert(vals(in));
end
