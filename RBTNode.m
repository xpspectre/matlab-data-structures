classdef RBTNode < handle
    %RBTNODE Red black tree node
    
    properties
        value
        p % parent, shortened for convenience
        left
        right
        color % red = true, black = false
    end
    
    methods
        function this = RBTNode(value, parent, left, right)
            if nargin < 4
                right = [];
                if nargin < 3
                    left = [];
                    if nargin < 2
                        parent = [];
                        if nargin < 1
                            value = [];
                        end
                    end
                end
            end
            this.value = value;
            this.p = parent;
            this.left = left;
            this.right = right;
            this.color = false;
        end
    end
    
end

