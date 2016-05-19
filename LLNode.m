classdef LLNode < handle
    %LLNODE Node of a linked list
    %
    % Note: this class is intentionally simple, allowing direct access to its
    %   properties. The containing class needs to handle [] prev or next to
    %   indicate beginning and end of the list.
    
    properties
        value
        prev % class: LLNode
        next % class: LLNode
    end
    
    methods
        function this = LLNode(value, prev, next)
            if nargin < 3
                next = [];
                if nargin < 2
                    prev = [];
                    if nargin < 1
                        value = [];
                    end
                end
            end
            this.value = value;
            this.prev = prev;
            this.next = next;
        end
    end
    
end
