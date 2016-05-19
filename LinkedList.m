classdef LinkedList < handle
    %LINKEDLIST Doubly-linked list. Indexing starts at 1.
    %   Can contain "empty" (value = []) nodes.
    %   Can mix and match types of objects stored in list (but calling functions
    %       have to handle this)
    %   Negative indexes counts backwards from the end, where index =
    %       -1 is the last position.
    %
    % The head and tail sentinel nodes have [] as their prev and next
    %   properties, respectively, and [] as their dummy values. 
    
    properties
        head = []
        tail = []
        size = 0
    end
    
    methods
        
        function this = LinkedList(values)
            % Construct list. Reshapes matrices and higher order arrays by
            %   columns.
            %
            % Usage:
            %   ll = LinkedList(): Constrct an empty list
            %   ll = LinkedList(values): Construct a list containing the
            %       elements from the array, cell array, or LinkedList `values`,
            %       keeping their order. Copies the values of the LinkedList.
            %
            % Note: Use this to directly construct a list from an array (with
            %   O(1) time lookups) or other LinkedList (with O(n) time lookups).
            
            if nargin < 1
                values = [];
            end
            
            this.head = LLNode;
            this.tail = LLNode;
            this.head.next = this.tail;
            this.tail.prev = this.head;
            
            if isa(values, 'LinkedList')
                iter = values.getIterator;
                while iter.hasNext
                    this.add(iter.next);
                end
            else % an array of some sort
                size = numel(values);
                values = reshape(values, [size,1]);
                for i = 1:size
                    if iscell(values)
                        this.add(values{i});
                    else
                        this.add(values(i));
                    end
                end
            end
            
        end
        
        function value = get(this, index)
            % Get `value` in list at `index`.
            %
            % Usage:
            %   value = ll.get()
            %   value = ll.get(index)
            
            if nargin < 2
                index = this.size;
            end
            
            this.checkBounds(index);
            index = this.fixIndex(index);
            
            node = this.getNode(index);
            
            value = node.value;
        end
        
        function set(this, value, index)
            % Replace `value` at `index`. Can only replace values, i.e., cannot
            %   add a value.
            %
            % Usage:
            %   ll.set(value, index)
            
            this.checkBounds(index);
            index = this.fixIndex(index);
            
            assert(isscalar(value), 'LinkedList:set:NonScalarValue', 'Value to be inserted must be scalar')
            
            node = this.getNode(index);
            
            node.value = value;
        end
        
        function add(this, value, index)
            % Add `value` to list, inserting the position `index` and
            %   pushing all subsequent indices up. (Use `set` method to
            %   replace value). `value` can be a scalar or an array, cell array,
            %   or LinkedList. If nonscalar, the new values are added in order.
            %   Copies the values of the LinkedList.
            %
            % Can only add contiguously, i.e., can't set
            %   the index to m values above the current size and fill in the
            %   intermediates with blanks.
            %
            % Runs in O(1) time when adding to beginning (index = 0) or end
            %   of list (no index specified or index = ll.size). Runs in O(n)
            %   time when adding in the middle.
            %
            % Usage:
            %   ll.add(value): Add value to end of list
            %   ll.add(value, index): Add value at position index.
            
            if nargin < 3
                index = this.size + 1; % default is on the end
            end
            
            assert(mod(index,1) == 0, 'LinkedList:add:NonIntegerIndex', 'Index %g not an integer', index)
            
            % Validate index and convert reverse index to forward index
            %   The extra this.size + 1 allows adding the element to the
            %   beginning or end
            if index > 0
                assert(index <= this.size + 1, 'LinkedList:add:IndexOutOfBounds', 'Index %g out of bounds for list of length %g', index, this.size)
            elseif index < 0
                assert(-index <= this.size + 1, 'LinkedList:add:IndexOutOfBounds', 'Reverse index %g out of bounds for list of length %g', index, this.size)
                index = this.size + index + 1; % convert to forward index
            else % index == 0 is not allowed
                error('LinkedList:add:ZeroIndexNotAllowed', 'Indexing starts at 1')
            end
            
            % Go to index where insertion will happen
            if index < this.size/2 % closer to head
                offset = index;
                node = this.head;
                for i = 1:offset
                    node = node.next;
                end
            else % closer to tail
                offset = this.size - index;
                node = this.tail;
                for i = 1:offset
                    node = node.prev;
                end
            end
            
            % Insert new value(s)
            lNode = node.prev;
            rNode = node;
            
            if isscalar(value)
                newNode = LLNode(value, lNode, rNode);
                lNode.next = newNode;
                rNode.prev = newNode;
                this.size = this.size + 1;
            else
                if isa(value, 'LinkedList')
                    iter = value.getIterator;
                    size = 0;
                    % invariant: `size` entries have been added to this so far
                    %   and newNode is ready to be inserted between lNode and
                    %   rNode
                    while iter.hasNext
                        size = size + 1;
                        newNode = LLNode(iter.next, lNode, rNode);
                        lNode.next = newNode;
                        rNode.prev = newNode;
                        lNode = newNode;
                    end
                else % an array of some sort
                    size = numel(value);
                    values = reshape(value, [size,1]);
                    for i = 1:size
                        if iscell(values)
                            newValue = values{i};
                        else
                            newValue = values(i);
                        end
                        newNode = LLNode(newValue, lNode, rNode);
                        lNode.next = newNode;
                        rNode.prev = newNode;
                        lNode = newNode;
                    end
                end
                this.size = this.size + size;
            end

        end
        
        function value = del(this, index)
            % Delete value at `index`. Optionally returns the `value` deleted, if
            %   this is assigned to something.
            %
            % TODO: implement deleting a range of indices
            
            this.checkBounds(index);
            index = this.fixIndex(index);
            
            node = this.getNode(index);
            
            value = node.value;
            
            lNode = node.prev;
            rNode = node.next;
            lNode.next = rNode;
            rNode.prev = lNode;
            this.size = this.size - 1;
        end
        
        function array = toArray(this)
            % Convert list to array (if values are numeric) or cell array (if
            %   and of the values aren't numeric). `array` is a column vector.
            
            % Initial pass to determine type of array
            numeric = true(this.size,1);
            node = this.head;
            for i = 1:this.size
                node = node.next;
                if ~isnumeric(node.value)
                    numeric(i) = false;
                end
            end
            
            % Actually populate the array
            if all(numeric)
                array = zeros(this.size,1);
                node = this.head;
                for i = 1:this.size
                    node = node.next;
                    array(i) = node.value;
                end
            else
                array = cell(this.size,1);
                node = this.head;
                for i = 1:this.size
                    node = node.next;
                    array{i} = node.value;
                end
            end
        end
        
        function iterator = getIterator(this, index)
            % Get an iterator (actual a more general "traverser") for the list.
            %   `index` is the element that the iterator starts on, defaulting
            %   to `this.head` (call `iterator.next` to get the first value).
            
            if nargin < 2
                iterator = LLIterator(this, this.head);
                return
            end
            
            this.checkBounds(index);
            index = this.fixIndex(index);
            
            node = this.getNode(index);
            
            iterator = LLIterator(this, node);
        end
        
    end
    
    methods (Access = private)
        
        function node = getNode(this, index)
            % Get the node at `index`. Starts from the head or tail, whichever is
            %   closer.
            if index < this.size/2 % closer to head
                offset = index;
                node = this.head;
                for i = 1:offset
                    node = node.next;
                end
            else % closer to tail
                offset = this.size - index + 1;
                node = this.tail;
                for i = 1:offset
                    node = node.prev;
                end
            end
        end
        
        function checkBounds(this, index)
            % Validate whether `index` is an integer and in the list. Throws
            %   exception if invalid.
            assert(mod(index,1) == 0, 'LinkedList:NonIntegerIndex', 'Index %g not an integer', index)
            
            if index > 0
                assert(index <= this.size, 'LinkedList:IndexOutOfBounds', 'Index %g out of bounds for list of length %g', index, this.size)
            elseif index < 0
                assert(-index <= this.size, 'LinkedList:IndexOutOfBounds', 'Reverse index %g out of bounds for list of length %g', index, this.size)
            else % index == 0 is not allowed
                error('LinkedList:get:ZeroIndexNotAllowed', 'Indexing starts at 1')
            end
        end
        
        function index = fixIndex(this, index)
            % Convert negative index to positive index.
            if index < 0
                index = this.size + index + 1;
            end
        end
        
    end
    
end

