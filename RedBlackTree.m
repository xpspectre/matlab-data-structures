classdef RedBlackTree < handle
    %REDBLACKTREE Summary of this class goes here
    %   All leaves + parent of root node share the sentinel node `this.nil`
    %   node.color: RED = true, BLACK = false
    %
    % See :
    %   - Cormen, Leiserson, Rivest, Stein 2nd edition pg 273
    %   - https://code.activestate.com/recipes/576817-red-black-tree/
    
    properties
        root
        nil % shared sentinel node
    end
    
    methods
        
        function this = RedBlackTree()
            this.nil = RBTNode;
            this.root = this.nil;
        end
        
        function x = find(this, value, root)
            % Look for value in tree. Returns the node if it finds it or
            %   this.nil otherwise.
            if nargin < 3
                root = this.root;
            end
            x = root;
            while x ~= this.nil && value ~= x.value
                if value < x.value
                    x = x.left;
                else
                    x = x.right;
                end
            end
        end
        
        function x = minimum(this, root)
            if nargin < 2
                root = this.root;
            end
            x = root;
            while x.left ~= this.nil
                x = x.left;
            end
        end
        
        function x = maximum(this, root)
            if nargin < 2
                root = this.root;
            end
            x = root;
            while x.right ~= this.nil
                x = x.right;
            end
        end
        
        function insert(this, value)
            z = RBTNode(value);
            this.insert_(z);
        end
        
        function delete(this, value)
            z = this.find(this, value);
            if z ~= this.nil
                this.delete_(z);
            end
        end
        
    end
    
    methods (Access = private)
        
        function insert_(this, z)
            y = this.nil;
            x = this.root;
            while x ~= this.nil
                y = x;
                if z.value < x.value
                    x = x.left;
                else
                    x = x.right;
                end
            end
            z.p = y;
            if y == this.nil
                this.root = z;
            elseif z.value < y.value
                y.left = z;
            else
                y.right = z;
            end
            z.left = this.nil;
            z.right = this.nil;
            z.color = true;
            this.insertFixup(z);
        end
        
        function insertFixup(this, z)
            while z.p.color
                if z.p == z.p.p.left
                    y = z.p.p.right;
                    if y.color
                        z.p.color = false;
                        y.color = false;
                        z.p.p.color = true;
                        z = z.p.p;
                    else
                        if z == z.p.right
                            z = z.p;
                            this.leftRotate(z);
                        end
                        z.p.color = false;
                        z.p.p.color = true;
                        this.rightRotate(z.p.p);
                    end
                else
                    y = z.p.p.left;
                    if y.color
                        z.p.color = false;
                        y.color = false;
                        z.p.p.color = true;
                        z = z.p.p;
                    else
                        if z == z.p.left
                            z = z.p;
                            this.rightRotate(z);
                        end
                        z.p.color = false;
                        z.p.p.color = true;
                        this.leftRotate(z.p.p);
                    end
                end
            end
            this.root.color = false;
        end
        
        function transplant(this, u, v)
            if u.p == this.nil
                this.root = v;
            elseif u == u.p.left
                u.p.left = v;
            else
                u.p.right = v;
            end
            v.p = u.p;
        end
        
        function delete_(this, z)
            y = z;
            yOriginalColor = y.color;
            if z.left == this.nil
                x = z.right;
                this.transplant(z, z.right);
            elseif z.right == this.nil
                x = z.left;
                this.transplant(z, z.left);
            else
                y = this.minimum(z.right);
                yOriginalColor = y.color;
                x = y.right;
                if y.p == z
                    x.p = y;
                else
                    this.transplant(y, y.right);
                    y.right = z.right;
                    y.right.p = y;
                end
                this.transplant(z, y);
                y.left = z.left;
                y.left.p = y;
                y.color = z.color;
            end
            if ~yOriginalColor
                this.deleteFixup(x);
            end
        end
        
        function deleteFixup(this, x)
            while x ~= this.root && ~x.color
                if x == x.p.left
                    w = x.p.right;
                    if w.color
                        w.color = false;
                        x.p.color = true;
                        this.leftRotate(x.p);
                        w = x.p.right;
                    end
                    if ~w.left.color && ~w.right.color
                        w.color = true;
                        x = x.p;
                    else
                        if ~w.right.color
                            w.left.color = false;
                            w.color = true;
                            this.rightRotate(w);
                            w = x.p.right;
                        end
                        w.color = x.p.color;
                        x.p.color = false;
                        w.right.color = false;
                        this.leftRotate(x.p);
                        x = this.root;
                    end
                else
                    w = x.p.left;
                    if w.color
                        w.color = false;
                        x.p.color = true;
                        this.rightRotate(x.p);
                        w = x.p.left;
                    end
                    if ~w.right.color && ~w.left.color
                        w.color = true;
                        x = x.p;
                    else
                        if ~w.left.color
                            w.right.color = false;
                            w.color = true;
                            this.leftRotate(w);
                            w = x.p.left;
                        end
                        w.color = x.p.color;
                        x.p.color = false;
                        w.left.color = false;
                        this.rightRotate(x.p);
                        x = this.root;
                    end
                end
            end
            x.color = false;
        end
        
        function leftRotate(this, x)
            y = x.right;
            x.right = y.left;
            if y.left ~= this.nil
                y.left.p = x;
            end
            y.p = x.p;
            if x.p == this.nil
                this.root = y;
            elseif x == x.p.left
                x.p.left = y;
            else
                x.p.right = y;
            end
            y.left = x;
            x.p = y;
        end
        
        function rightRotate(this, y)
            x = y.left;
            y.left = x.right;
            if x.right ~= this.nil
                x.right.p = y;
            end
            x.p = y.p;
            if y.p == this.nil
                this.root = x;
            elseif y == y.p.right
                y.p.right = x;
            else
                y.p.left = x;
            end
            x.right = y;
            y.p = x;
        end
        
    end
    
end

