classdef LLIterator < handle
    %LLITERATOR Iterator for a linked list. Allows arbitrary traversal and list
    %   modification.
    %
    % Note: Calling `ll.getIterator` w/o any args sets `this.node` to the head
    %   sentinel node. Get the first value of the list by calling `this.next`.
    %   Prepend a value to the list by calling `this.add(value)`.
    %   Don't call `this.del` first.
    %
    % Note: Mutating the list with this iterator doesn't invalidate any
    %   iterators, except those that are currently on nodes that get deleted
    %
    % TODO: needs more error checking
    
    properties
        list % the linked list the iterator refers to; needed when the iterator is used to mutate the list
        node % the current node the iterator is on
    end
    
    methods
        
        function this = LLIterator(list, node)
            this.list = list;
            this.node = node;
        end
        
        function value = next(this)
            this.node = this.node.next;
            value = this.node.value;
        end
        
        function value = prev(this)
            this.node = this.node.prev;
            value = this.node.value;
        end
        
        function tf = hasNext(this)
            % Detects whether the next node is a sentinel node
            nextNode = this.node.next;
            if isempty(nextNode.next)
                tf = false;
            else
                tf = true;
            end
        end
        
        function tf = hasPrev(this)
            % Detects whether the prev node is a sentinel node
            prevNode = this.node.prev;
            if isempty(prevNode.prev)
                tf = false;
            else
                tf = true;
            end
        end
        
        function add(this, value)
            % Add `value` right after the current position of the iterator and
            %   move up the iterator to the new value.
            lNode = this.node;
            rNode = this.node.next;
            newNode = LLNode(value, lNode, rNode);
            lNode.next = newNode;
            rNode.prev = newNode;
            this.node = newNode;
            this.list.size = this.list.size + 1;
        end
        
        function value = del(this)
            % Delete the value at the current position of the iterator,
            %   optionally return it, and move up the iterator to the value
            %   after the one that was just deleted.
            value = this.node.value;
            lNode = this.node.prev;
            rNode = this.node.next;
            lNode.next = rNode;
            rNode.prev = lNode;
            this.list.size = this.list.size - 1;
        end
        
    end
    
end

