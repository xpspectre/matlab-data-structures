clear; close all; clc
rng('default');

% TODO: turn this into unit tests

n = 5;
a = 1:5;

%% Make lists
x = LinkedList;
y = LinkedList(a);
z = LinkedList(zeros(ngit,1));
c = LinkedList({'a','b','c'});

lists = [x,y,z,c];

for iL = 1:length(lists)
    list = lists(iL);
    
    % inefficient way of getting values, but useful for testing
    for in = 1:list.size
        list.get(in)
    end
    
    for in = 1:list.size
        list.get(-in)
    end
    
    list.toArray
    
    if iL == 2 || iL == 3
        list.set(99, 2)
        list.toArray
    end
end

%% Test read-only iterators
iter = y.getIterator;
while iter.hasNext
    iter.next
end

iter = y.getIterator(-1);
while iter.hasPrev
    iter.prev
end

%% Test mutating iterators
iter = y.getIterator;
iter.next;
iter.next;
iter.add(11);
iter.add(12);
iter.next;
iter.add(13);
y.toArray

iter.next;
iter.del;
y.toArray
